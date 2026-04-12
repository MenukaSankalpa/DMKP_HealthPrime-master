import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:healthprime/core/providers/records_provider.dart';
import 'package:healthprime/core/providers/auth_provider.dart';
import 'package:healthprime/core/services/ai_service.dart';
import 'package:healthprime/shared/widgets/app_header.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/health_record.dart';

class AiInsightsPage extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const AiInsightsPage({
    super.key,
    this.onNotificationTap,
    this.onAccountTap,
  });

  @override
  State<AiInsightsPage> createState() => _AiInsightsPageState();
}

class _AiInsightsPageState extends State<AiInsightsPage> {
  final AiService _aiService = AiService();
  String? _result;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _noData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInsights());
  }

  // Fetch Insights
  Future<void> _fetchInsights() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isOffline = false;
      _noData = false;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        setState(() {
          _isOffline = true;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final recordsProvider =
          Provider.of<RecordsProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check if Data is Available
      if (recordsProvider.records.isEmpty) {
        if (mounted) {
          setState(() {
            _noData = true;
            _isLoading = false;
          });
        }
        return;
      }

      // Get Height
      double? height;
      final hVal = authProvider.userData?['height'];
      if (hVal != null) {
        height = double.tryParse(hVal.toString());
      }

      // Get Latest Weight from Records
      double? weight;
      try {
        final latestRecord = recordsProvider.records.firstWhere(
            (r) => r.weight != null && r.weight! > 0,
            orElse: () => HealthRecord(id: '', date: DateTime.now()));
        if (latestRecord.id.isNotEmpty) {
          weight = latestRecord.weight;
        }
      } catch (e) {
        // Ignore
      }

      // Call AI
      final response =
          await _aiService.getHealthInsights(recordsProvider, height, weight);

      if (mounted) {
        setState(() {
          _result = response;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Helpers.showSnackBar(
            context, "Error: Could not fetch insights. Please try again.",
            isError: true);
      }
    }
  }

  // Update Height
  Future<void> _updateHeight(double height) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userData;

      await authProvider.updateProfile(
          name: user?['name'] ?? '',
          age: user?['age'],
          gender: user?['gender'] ?? 'Not specified',
          height: height);

      if (mounted) {
        Helpers.showSnackBar(context, "Height updated successfully!",
            isError: false);
        _fetchInsights();
      }
    } catch (e) {
      Helpers.showSnackBar(context, "Failed to save height.", isError: true);
    }
  }

  // Show Height Entry Form
  void _showHeightDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Height"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Height (cm)",
            border: OutlineInputBorder(),
            suffixText: "cm",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                _updateHeight(val);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff7e5f),
              foregroundColor: Colors.white,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfef9f5),
      body: Column(
        children: [
          AppHeader(
            title: 'AI Insights',
            showNotification: true,
            showAccount: true,
            onNotificationTap: widget.onNotificationTap,
            onAccountTap: widget.onAccountTap,
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  // No Internet View
  Widget _buildContent() {
    if (_isOffline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 60, color: Colors.orange.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text("You are currently offline",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333))),
            const SizedBox(height: 10),
            const Text(
                "Please connect to the internet\nto see your AI insights.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _fetchInsights,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff7e5f),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFff7e5f)),
            const SizedBox(height: 20),
            Text("Analyzing your health data...",
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    // No Data View
    if (_noData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                size: 60, color: Colors.orange.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text("No Health Data Found",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333))),
            const SizedBox(height: 10),
            const Text(
                "Start logging your daily health records\nto receive personalized AI insights.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _fetchInsights,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff7e5f),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Refresh"),
            )
          ],
        ),
      );
    }

    if (_result == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 60, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text("Unable to load insights",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333))),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _fetchInsights,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff7e5f),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    // Parse Sections
    String summary = "";
    String strengths = "";
    String improvements = "";
    String suggestions = "";
    String motivation = "";

    if (_result != null) {
      final parts = _result!.split(
          RegExp(r'SUMMARY|STRENGTHS|IMPROVEMENTS|SUGGESTIONS|MOTIVATION'));
      if (parts.length >= 6) {
        summary = parts[1].trim();
        strengths = parts[2].trim();
        improvements = parts[3].trim();
        suggestions = parts[4].trim();
        motivation = parts[5].trim();
      } else {
        summary = _result!;
      }
    }

    // Get Data for BMI Section
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recordsProvider =
        Provider.of<RecordsProvider>(context, listen: false);

    double? height;
    if (authProvider.userData?['height'] != null) {
      height = double.tryParse(authProvider.userData!['height'].toString());
    }

    double? weight;
    try {
      final latestRecord = recordsProvider.records.firstWhere(
          (r) => r.weight != null && r.weight! > 0,
          orElse: () => HealthRecord(id: '', date: DateTime.now()));
      if (latestRecord.id.isNotEmpty) weight = latestRecord.weight;
    } catch (e) {
      // Ignore
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary
          _buildInsightCard("Summary", Icons.analytics, summary, Colors.blue),

          // BMI Section
          _buildBmiSection(height, weight),

          // Strengths
          _buildInsightCard("Strengths & Achievements", Icons.emoji_events,
              strengths, Colors.green),

          // Improvements
          _buildInsightCard("Areas for Improvement", Icons.trending_up,
              improvements, Colors.orange),

          // Suggestions
          _buildInsightCard("Personalized Recommendations", Icons.lightbulb,
              suggestions, Colors.purple),

          // Motivation
          _buildInsightCard(
              "Motivation", Icons.favorite, motivation, Colors.red),
        ],
      ),
    );
  }

  Widget _buildBmiSection(double? height, double? weight) {
    if (height == null || height == 0) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFff7e5f).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFff7e5f).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          children: [
            const Icon(Icons.monitor_weight_outlined,
                size: 48, color: Color(0xFFff7e5f)),
            const SizedBox(height: 15),
            const Text("BMI Insights Unavailable",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF333333))),
            const SizedBox(height: 8),
            const Text(
                "Enter your height to calculate BMI and unlock personalized weight insights.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showHeightDialog,
              icon: const Icon(Icons.add, size: 18),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff7e5f),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              label: const Text("Add Height"),
            )
          ],
        ),
      );
    }

    if (weight == null || weight == 0) {
      return const SizedBox.shrink();
    }

    // Calculate BMI
    double bmi = weight / ((height / 100) * (height / 100));
    String category = "";
    Color catColor = Colors.grey;
    String message = "";

    if (bmi < 18.5) {
      category = "Underweight";
      catColor = const Color(0xFFff7e5f);
      message = "Focus on nutrient-rich foods to build strength.";
    } else if (bmi < 25) {
      category = "Normal Weight";
      catColor = Colors.green;
      message = "Great job! Maintain your balanced routine.";
    } else if (bmi < 30) {
      category = "Overweight";
      catColor = Colors.orange;
      message = "Regular exercise and mindful eating can help.";
    } else {
      category = "Obese";
      catColor = Colors.red;
      message = "Consulting a health professional is recommended.";
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: catColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
        border: Border.all(color: catColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("BMI Analysis",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF555555))),
                  const SizedBox(height: 4),
                  Text(category,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: catColor)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: catColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Text(bmi.toStringAsFixed(1),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: catColor)),
              )
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: catColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: catColor),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(message,
                        style: TextStyle(
                            fontSize: 13,
                            color: catColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      String title, IconData icon, String content, Color color) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 15),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color.withOpacity(0.8)))),
            ],
          ),
          const SizedBox(height: 15),
          Text(content,
              style: const TextStyle(
                  fontSize: 15, height: 1.5, color: Color(0xFF444444))),
        ],
      ),
    );
  }
}
