import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/friends_provider.dart';
import '../../../../core/providers/records_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/avatar_utils.dart';

class ComparisonOverlay extends StatefulWidget {
  final String friendUid;
  final String friendName;
  final String friendAvatar;
  final String? friendAvatarId;

  const ComparisonOverlay({
    super.key,
    required this.friendUid,
    required this.friendName,
    required this.friendAvatar,
    this.friendAvatarId,
  });

  @override
  State<ComparisonOverlay> createState() => _ComparisonOverlayState();
}

class _ComparisonOverlayState extends State<ComparisonOverlay> {
  Map<String, dynamic>? _friendStats;
  bool _isLoading = true;
  String? _latestFriendAvatarId;

  @override
  void initState() {
    super.initState();
    _latestFriendAvatarId = widget.friendAvatarId;
    _loadData();
  }

  // Load Data
  Future<void> _loadData() async {
    final provider = Provider.of<FriendsProvider>(context, listen: false);

    final stats = await provider.getFriendStats(widget.friendUid);

    final profile = await provider.getFriendProfile(widget.friendUid);

    if (mounted) {
      setState(() {
        _friendStats = stats;
        if (profile != null && profile['avatarId'] != null) {
          _latestFriendAvatarId = profile['avatarId'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final myRecordsProvider =
        Provider.of<RecordsProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final myAvatarId = auth.userData?['avatarId'];
    final myInitial = auth.userData?['avatarInitial'] ?? 'U';

    double myVal(String metric) {
      try {
        return double.parse(myRecordsProvider.getAverage(metric));
      } catch (e) {
        return 0;
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text('Compare with Friend',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(
                      text: myInitial,
                      color: Colors.orange,
                      avatarId: myAvatarId
                  ),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text('VS',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  _buildAvatar(
                      text: widget.friendAvatar,
                      color: Colors.blue,
                      avatarId: _latestFriendAvatarId
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats List
              Flexible(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildComparisonStat('Steps', Icons.directions_walk,
                                myVal('steps'), _friendStats!['steps'], 10000),
                            _buildComparisonStat(
                                'Calories',
                                Icons.local_fire_department,
                                myVal('calories'),
                                _friendStats!['calories'],
                                600),
                            _buildComparisonStat('Water', Icons.water_drop,
                                myVal('water'), _friendStats!['water'], 3000),
                            _buildComparisonStat('Sleep', Icons.bedtime,
                                myVal('sleep'), _friendStats!['sleep'], 10),
                            _buildComparisonStat(
                                'Heart Rate',
                                Icons.favorite,
                                myVal('heartRate'),
                                _friendStats!['heartRate'],
                                120),
                            _buildComparisonStat('Weight', Icons.monitor_weight,
                                myVal('weight'), _friendStats!['weight'], 100),
                            _buildComparisonStat(
                                'Fruits',
                                Icons.apple,
                                myVal('fruits'),
                                _friendStats!['fruits'],
                                10),
                            _buildComparisonStat(
                                'Workout',
                                Icons.fitness_center,
                                myVal('workout'),
                                _friendStats!['workout'],
                                90),
                            _buildComparisonStat(
                                'Mood',
                                Icons.sentiment_satisfied,
                                myVal('mood'),
                                _friendStats!['mood'],
                                10),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF333333),
                    backgroundColor: const Color(0xFFffe8d6),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({
    required String text,
    required Color color,
    String? avatarId
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: avatarId != null ? Colors.white : color,
        shape: BoxShape.circle,
        border: avatarId != null ? Border.all(color: color, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: avatarId != null
          ? Icon(
        AvatarUtils.getIcon(avatarId),
        color: color,
        size: 30,
      )
          : Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildComparisonStat(
      String metric, IconData icon, num myValue, num friendValue, double max) {
    double myV = myValue.toDouble();
    double frV = friendValue.toDouble();

    double myPct = (myV / max).clamp(0.0, 1.0);
    double frPct = (frV / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: const Color(0xFFff7e5f)),
            const SizedBox(width: 5),
            Text(metric, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(child: _buildBar(myPct, myV, const Color(0xFFff7e5f))),
              const SizedBox(width: 10),
              Expanded(child: _buildBar(frPct, frV, Colors.blue)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBar(double pct, double val, Color color) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          FractionallySizedBox(
              widthFactor: pct == 0 ? 0.01 : pct,
              child: Container(
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(10)))),
          Center(
              child: Text(val.toInt().toString(),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
