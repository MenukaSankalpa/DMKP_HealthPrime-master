import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/core/providers/tournament_provider.dart';
import 'package:healthprime/core/providers/friends_provider.dart';
import 'package:healthprime/data/models/tournament.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/avatar_utils.dart';

// Add / Edit Tournament Overlay
class AddEditTournamentOverlay extends StatefulWidget {
  final Tournament? tournament;

  const AddEditTournamentOverlay({super.key, this.tournament});

  @override
  State<AddEditTournamentOverlay> createState() =>
      _AddEditTournamentOverlayState();
}

class _AddEditTournamentOverlayState extends State<AddEditTournamentOverlay> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _minValueController;
  late TextEditingController _durationController;
  late TextEditingController _startDateController;

  String _tournamentType = 'public';
  String _selectedMetric = 'steps';
  DateTime _selectedStartDate = DateTime.now();
  List<String> _selectedFriendIds = [];

  bool get isEditing => widget.tournament != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tournament;

    _nameController = TextEditingController(text: t?.name ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _minValueController = TextEditingController(
      text: t?.minValue.toString() ?? '10000',
    );
    _durationController = TextEditingController(
      text: t?.duration.toString() ?? '7',
    );

    if (t != null) {
      _selectedStartDate = t.startDate;
      _tournamentType = t.type;
      _selectedMetric = t.metric;
      if (t.invitedUsers != null) {
        _selectedFriendIds = List.from(t.invitedUsers!);
      }
    } else {
      final now = DateTime.now();
      _selectedStartDate =
          DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }

    _startDateController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(_selectedStartDate),
    );
  }

  // Save Tournament
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_tournamentType == 'private' && _selectedFriendIds.isEmpty) {
        Helpers.showSnackBar(
            context, "Select at least one friend for private tournaments",
            isError: true);
        return;
      }

      final provider = Provider.of<TournamentProvider>(context, listen: false);

      try {
        if (isEditing) {
          // Update
          await provider.updateTournament(
            tournamentId: widget.tournament!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _tournamentType,
            metric: _selectedMetric,
            minValue: int.parse(_minValueController.text),
            duration: int.parse(_durationController.text),
            startDate: _selectedStartDate,
            invitedUserIds: _selectedFriendIds,
          );
          if (mounted) {
            Navigator.pop(context);
            Helpers.showSnackBar(context, "Tournament Updated!",
                isError: false);
          }
        } else {
          // Create
          await provider.createTournament(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _tournamentType,
            metric: _selectedMetric,
            minValue: int.parse(_minValueController.text),
            duration: int.parse(_durationController.text),
            startDate: _selectedStartDate,
            invitedUserIds: _selectedFriendIds,
          );
          if (mounted) {
            Navigator.pop(context);
            Helpers.showSnackBar(context, "Tournament Created!",
                isError: false);
          }
        }
      } catch (e) {
        if (mounted) Helpers.showSnackBar(context, "Error: $e", isError: true);
      }
    }
  }

  // Delete Tournament
  Future<void> _delete() async {
    bool confirm = await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Delete Tournament?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm && mounted) {
      try {
        await Provider.of<TournamentProvider>(
          context,
          listen: false,
        ).deleteTournament(widget.tournament!.id);
        if (mounted) {
          Navigator.pop(context);
          Helpers.showSnackBar(context, "Tournament Deleted", isError: false);
        }
      } catch (e) {
        if (mounted) Helpers.showSnackBar(context, "Error: $e", isError: true);
      }
    }
  }

  // Pick Date
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 1),
    );

    DateTime initialDate = _selectedStartDate;
    if (initialDate.isBefore(tomorrow)) {
      initialDate = tomorrow;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: tomorrow,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFff7e5f),
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        _startDateController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  // Validators
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return 'Please enter $fieldName';
    return null;
  }

  String? _validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return 'Please enter $fieldName';
    final number = int.tryParse(value);
    if (number == null || number <= 0) return 'Valid number required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final friends = Provider.of<FriendsProvider>(context).friends;

    bool canEditDate = true;
    if (isEditing) {
      canEditDate = widget.tournament!.startDate.isAfter(DateTime.now());
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.add_circle,
                      color: const Color(0xFFff7e5f),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Edit Tournament' : 'Create Tournament',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name
                _buildFormField(
                  label: 'Tournament Name',
                  icon: Icons.flag,
                  controller: _nameController,
                  validator: (v) => _validateRequired(v, 'name'),
                ),
                const SizedBox(height: 12),

                // Description
                _buildFormField(
                  label: 'Description',
                  icon: Icons.description,
                  controller: _descriptionController,
                  isTextArea: true,
                  validator: (v) => _validateRequired(v, 'description'),
                ),
                const SizedBox(height: 12),

                // Type Dropdown
                _buildDropdownField(
                  label: 'Tournament Type',
                  icon: Icons.people,
                  value: _tournamentType,
                  items: ['public', 'friends', 'private'],
                  onChanged: (v) => setState(() => _tournamentType = v!),
                ),

                // Friend Selector
                if (_tournamentType == 'private') ...[
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select Friends:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFfff9f2),
                      border: Border.all(color: const Color(0xFFffe8d6)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: friends.isEmpty
                        ? const Center(
                            child: Text(
                              "No friends available",
                              style: TextStyle(color: Color(0xFF999999)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: friends.length,
                            itemBuilder: (c, i) {
                              final f = friends[i];
                              final uid = f['uid'];
                              final name = f['name'] ?? 'Unknown';
                              final isSelected = _selectedFriendIds.contains(
                                uid,
                              );

                              return CheckboxListTile(
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                value: isSelected,
                                activeColor: const Color(0xFFff7e5f),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                onChanged: (v) => setState(
                                  () => v!
                                      ? _selectedFriendIds.add(uid)
                                      : _selectedFriendIds.remove(uid),
                                ),
                              );
                            },
                          ),
                  ),
                ],

                const SizedBox(height: 12),
                // Date Picker
                GestureDetector(
                  onTap: canEditDate ? _pickDate : null,
                  child: AbsorbPointer(
                    child: _buildFormField(
                      label: 'Start Date',
                      icon: Icons.calendar_today,
                      controller: _startDateController,
                      isDate: true,
                      enabled: canEditDate,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Metric Dropdown
                _buildDropdownField(
                  label: 'Competition Metric',
                  icon: Icons.bar_chart,
                  value: _selectedMetric,
                  items: ['steps', 'calories', 'water', 'sleep', 'workout'],
                  onChanged: (v) => setState(() => _selectedMetric = v!),
                ),
                const SizedBox(height: 12),

                // Target Value
                _buildFormField(
                  label: 'Minimum Target Value',
                  icon: Icons.track_changes,
                  controller: _minValueController,
                  isNumber: true,
                  validator: (v) => _validatePositiveNumber(v, 'target'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is the total goal participants should aim for during the tournament',
                  style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Duration Dropdown
                _buildDropdownField(
                  label: 'Duration (Days)',
                  icon: Icons.timer,
                  value: _durationController.text,
                  items: ['1', '3', '7', '14', '30'],
                  onChanged: (v) =>
                      setState(() => _durationController.text = v!),
                ),
                const SizedBox(height: 25),

                // Buttons
                Row(
                  children: [
                    if (isEditing) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _delete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF333333),
                          backgroundColor: const Color(0xFFffe8d6),
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFff7e5f),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          isEditing ? Icons.save : Icons.add,
                          size: 16,
                        ),
                        label: Text(isEditing ? 'Update' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isNumber = false,
    bool isTextArea = false,
    bool isDate = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFff7e5f)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: isTextArea ? 3 : 1,
          readOnly: isDate,
          style: TextStyle(
            fontSize: 14,
            color: enabled
                ? const Color(0xFF333333)
                : Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText:
                isTextArea ? 'Describe the tournament...' : 'Enter $label',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: enabled
                ? const Color(0xFFfff9f2)
                : const Color(0xFFf0f0f0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFffe8d6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFffe8d6)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFe0e0e0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFff7e5f), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isTextArea ? 12 : 10,
            ),
            suffixIcon: isDate
                ? Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: enabled
                        ? const Color(0xFFff7e5f)
                        : Colors.grey,
                  )
                : null,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFff7e5f)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFfff9f2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFffe8d6)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                fontWeight: FontWeight.normal,
              ),
              items: items.map((e) {
                String text = e;
                if (label.contains('Type')) {
                  text = e == 'public'
                      ? 'Public (Anyone)'
                      : e == 'friends'
                          ? 'Friends Only'
                          : 'Private';
                }
                if (label.contains('Metric'))
                  text = e[0].toUpperCase() + e.substring(1);
                if (label.contains('Duration'))
                  text = '$e Day${e == '1' ? '' : 's'}';
                return DropdownMenuItem(value: e, child: Text(text));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minValueController.dispose();
    _durationController.dispose();
    _startDateController.dispose();
    super.dispose();
  }
}

// View Tournament Overlay
class ViewTournamentOverlay extends StatefulWidget {
  final String tournamentId;
  final Tournament? tournament;
  final bool isEnded;
  final int? userRank;
  final String? userScore;
  final String? targetValue;
  final List<Map<String, dynamic>>? leaderboard;

  const ViewTournamentOverlay({
    super.key,
    required this.tournamentId,
    this.tournament,
    this.isEnded = false,
    this.userRank,
    this.userScore,
    this.targetValue,
    this.leaderboard,
  });

  @override
  State<ViewTournamentOverlay> createState() => _ViewTournamentOverlayState();
}

class _ViewTournamentOverlayState extends State<ViewTournamentOverlay> {
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  bool _isJoining = false;
  bool _isWithdrawing = false;

  @override
  void initState() {
    super.initState();
    if (widget.leaderboard != null) {
      _isLoading = false;
      return;
    }

    if (widget.tournament != null) {
      if (widget.tournament!.isJoined) {
        _loadDetails();
      } else {
        _isLoading = false;
      }
    }
  }

  // Load Details
  Future<void> _loadDetails() async {
    try {
      final provider = Provider.of<TournamentProvider>(context, listen: false);
      final data = await provider.getTournamentDetails(widget.tournament!);
      if (mounted) {
        setState(() {
          _details = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Join Tournament
  Future<void> _join() async {
    setState(() => _isJoining = true);
    try {
      await Provider.of<TournamentProvider>(context, listen: false)
          .joinTournament(widget.tournamentId);
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Joined!', isError: false);
      }
    } catch (e) {
      setState(() => _isJoining = false);
      if (mounted)
        Helpers.showSnackBar(context, 'Failed to join: $e', isError: true);
    }
  }

  // Withdraw From Tournament
  Future<void> _withdraw() async {
    setState(() => _isWithdrawing = true);
    try {
      await Provider.of<TournamentProvider>(context, listen: false)
          .withdrawTournament(widget.tournamentId);
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Withdrawn', isError: false);
      }
    } catch (e) {
      setState(() => _isWithdrawing = false);
      if (mounted)
        Helpers.showSnackBar(context, 'Failed to withdraw: $e', isError: true);
    }
  }

  // Format Number
  String _formatNumber(int number) {
    return NumberFormat.decimalPattern().format(number);
  }

  // Get Metric Icon
  IconData _getDynamicMetricIcon(String metric) {
    switch (metric.toLowerCase()) {
      case 'steps':
        return FontAwesomeIcons.shoePrints;
      case 'calories':
        return FontAwesomeIcons.fire;
      case 'water':
        return FontAwesomeIcons.droplet;
      case 'sleep':
        return FontAwesomeIcons.bed;
      case 'workout':
        return FontAwesomeIcons.dumbbell;
      default:
        return FontAwesomeIcons.chartLine;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tournament == null) return const SizedBox.shrink();

    final t = widget.tournament!;
    final isEnded = widget.isEnded || t.status == 'ended';
    final isActive = t.status == 'active';
    final isUpcoming = t.status == 'upcoming';

    final statusText = isEnded
        ? 'Ended'
        : isUpcoming
            ? 'Upcoming'
            : 'Active';
    final statusColor = isEnded
        ? const Color(0xFFf44336)
        : isUpcoming
            ? const Color(0xFFff9800)
            : const Color(0xFF4caf50);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.emoji_events,
                    color: Color(0xFFff7e5f), size: 24),
                const SizedBox(width: 8),
                Flexible(
                    child: Text(isEnded ? '${t.name} - Results' : t.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333))))
              ]),
              const SizedBox(height: 10),

              // Description
              if (!isEnded)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(t.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF666666), fontSize: 13)),
                ),

              // Results
              if (isEnded && _details != null && t.isJoined) ...[
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                        color: const Color(0xFF4caf50).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4caf50))),
                    child: Column(children: [
                      const Text('Your Result',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333))),
                      const SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(children: [
                              const Text('Rank',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF666666))),
                              const SizedBox(height: 5),
                              Text('#${_details?['userRank'] ?? '-'}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFff7e5f)))
                            ]),
                            Column(children: [
                              const Text('Score',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF666666))),
                              const SizedBox(height: 5),
                              Text('${_details?['userProgress'] ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFff7e5f)))
                            ])
                          ])
                    ])),
              ],

              // Stats
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildStatBox('Metric', t.metric.capitalize(),
                        icon: _getDynamicMetricIcon(t.metric)),
                    _buildStatBox('Target', _formatNumber(t.minValue),
                        icon: Icons.track_changes),
                    _buildStatBox('Type', t.type.capitalize(),
                        icon: Icons.people),
                    _buildStatBox('Status', statusText,
                        textColor: statusColor,
                        icon: Icons.circle,
                        iconColor: statusColor),
                  ],
                ),
              ),

              // Date Range
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: const Color(0xFFfff9f2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFffe8d6))),
                child: Column(children: [
                  const Text('Date Range',
                      style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                  const SizedBox(height: 5),
                  Text(
                      '${DateFormat('MMM dd').format(t.startDate)} - ${DateFormat('MMM dd').format(t.endDate)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                          fontSize: 13))
                ]),
              ),

              if (_isLoading)
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(color: Color(0xFFff7e5f)))
              else if (isEnded && _details != null) ...[
                // Final Leaderboard
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Final Leaderboard',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333)))),
                const SizedBox(height: 10),
                ...(_details!['leaderboard'] as List)
                    .cast<LeaderboardEntry>()
                    .map((e) => _buildLeaderboardItem(
                          rank: e.rank,
                          avatar: e.avatar,
                          name: e.name,
                          value: e.value,
                          isYou: e.isYou,
                          avatarId: e.avatarId,
                        )),
              ],
              const SizedBox(height: 25),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF333333),
                            backgroundColor: const Color(0xFFffe8d6),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Close'))),
                if (!isEnded && !t.isJoined && (isUpcoming || isActive)) ...[
                  const SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _join,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFff7e5f),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    icon: _isJoining
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.login, size: 16),
                    label: _isJoining
                        ? const Text('Joining...')
                        : const Text('Join'),
                  )),
                ] else if (!isEnded && t.isJoined) ...[
                  const SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton.icon(
                    onPressed: _isWithdrawing ? null : _withdraw,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf44336),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    icon: _isWithdrawing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.exit_to_app, size: 16),
                    label: _isWithdrawing
                        ? const Text('Withdrawing...')
                        : const Text('Withdraw'),
                  )),
                ]
              ])
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value,
      {IconData? icon, Color? textColor, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: const Color(0xFFfff9f2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFffe8d6))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[
            FaIcon(icon, size: 14, color: iconColor ?? const Color(0xFFff7e5f)),
            const SizedBox(width: 5)
          ],
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? const Color(0xFF333333),
                  fontSize: 14))
        ])
      ]),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String avatar,
    required String name,
    required int value,
    required bool isYou,
    String? avatarId,
  }) {
    Color rankColor = const Color(0xFFff7e5f);
    Color avatarBgStart = const Color(0xFFff7e5f);
    Color avatarBgEnd = const Color(0xFFfeb47b);
    Color avatarTextColor = Colors.white;
    FontWeight rankFontWeight = FontWeight.w700;

    if (rank == 1) {
      rankColor = const Color(0xFFffd700);
      avatarBgStart = const Color(0xFFffd700);
      avatarBgEnd = const Color(0xFFffed4e);
      avatarTextColor = const Color(0xFF333333);
    } else if (rank == 2) {
      rankColor = const Color(0xFFc0c0c0);
      avatarBgStart = const Color(0xFFc0c0c0);
      avatarBgEnd = const Color(0xFFe0e0e0);
      avatarTextColor = const Color(0xFF333333);
    } else if (rank == 3) {
      rankColor = const Color(0xFFcd7f32);
      avatarBgStart = const Color(0xFFcd7f32);
      avatarBgEnd = const Color(0xFFe39e5a);
      avatarTextColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isYou ? const Color(0xFFff7e5f).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isYou ? const Color(0xFFff7e5f) : const Color(0xFFffe8d6),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: rankFontWeight,
                      color: rankColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (rank <= 3)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [avatarBgStart, avatarBgEnd],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: rankColor.withOpacity(0.3),
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          rank == 1
                              ? '🥇'
                              : rank == 2
                                  ? '🥈'
                                  : '🥉',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: avatarId != null ? Colors.white : null,
              gradient: avatarId != null
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [avatarBgStart, avatarBgEnd],
                    ),
              shape: BoxShape.circle,
              border: avatarId != null
                  ? Border.all(color: const Color(0xFFff7e5f), width: 1.5)
                  : null,
              boxShadow: rank <= 3 && avatarId == null
                  ? [
                      BoxShadow(
                        color: rankColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: avatarId != null
                  ? Icon(
                      AvatarUtils.getIcon(avatarId),
                      color: const Color(0xFFff7e5f),
                      size: 18,
                    )
                  : Text(
                      avatar,
                      style: TextStyle(
                        color: avatarTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    isYou ? const Color(0xFFff7e5f) : const Color(0xFF333333),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            _formatNumber(value),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: rank <= 3 ? rankColor : const Color(0xFFff7e5f),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Tournament Progress Overlay
class TournamentProgressOverlay extends StatefulWidget {
  final String tournamentId;
  final Tournament tournament;

  const TournamentProgressOverlay({
    super.key,
    required this.tournamentId,
    required this.tournament,
  });

  @override
  State<TournamentProgressOverlay> createState() =>
      _TournamentProgressOverlayState();
}

class _TournamentProgressOverlayState extends State<TournamentProgressOverlay> {
  Map<String, dynamic>? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  // Load Details
  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<TournamentProvider>(context, listen: false);
      final data = await provider.getTournamentDetails(widget.tournament);

      if (mounted) {
        setState(() {
          _details = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  // Get Milestone Targets
  List<int> _getMilestoneTargets(int minValue) {
    final quarter = minValue ~/ 4;
    return [quarter, quarter * 2, quarter * 3, minValue];
  }

  // Get Milestone Titles
  String _getMilestoneTitle(String metric, int value, int index) {
    final isFinal = index == 3;
    String unit = '';
    String action = '';

    String valStr =
        value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value';

    switch (metric.toLowerCase()) {
      case 'steps':
        unit = '$valStr Steps';
        action = isFinal ? 'Complete' : 'Reach';
        break;
      case 'calories':
        unit = '$value Calories';
        action = isFinal ? 'Burn' : 'Burn';
        break;
      case 'water':
        unit = value >= 1000
            ? '${(value / 1000).toStringAsFixed(1)}L Water'
            : '${value}ml Water';
        action = isFinal ? 'Drink' : 'Drink';
        break;
      case 'sleep':
        unit = '$value Hours';
        action = isFinal ? 'Achieve' : 'Get';
        break;
      case 'workout':
        unit = '$value Mins';
        action = isFinal ? 'Complete' : 'Complete';
        break;
      default:
        unit = '$valStr';
        action = isFinal ? 'Complete' : 'Reach';
    }
    return '$action $unit';
  }

  // Get Metric Icon
  IconData _getMetricIcon(String metric) {
    switch (metric.toLowerCase()) {
      case 'steps':
        return FontAwesomeIcons.shoePrints;
      case 'calories':
        return FontAwesomeIcons.fire;
      case 'water':
        return FontAwesomeIcons.droplet;
      case 'sleep':
        return FontAwesomeIcons.bed;
      case 'workout':
        return FontAwesomeIcons.dumbbell;
      default:
        return FontAwesomeIcons.chartLine;
    }
  }

  // Format Number
  String _formatNumber(int number) {
    return NumberFormat.decimalPattern().format(number);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    final userProgress = _details?['userProgress'] ?? 0;
    final milestones = _getMilestoneTargets(t.minValue);
    final metricIcon = _getMetricIcon(t.metric);

    int completedMilestones =
        milestones.where((target) => userProgress >= target).length;
    final overallProgress = ((userProgress / t.minValue) * 100).clamp(
      0.0,
      100.0,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.chartLine,
                    color: Color(0xFFff7e5f),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${t.name} - Progress',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Color(0xFFff7e5f)),
                )
              else ...[
                // Overall Progress
                Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFfff9f2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFffe8d6)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Overall Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${overallProgress.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFff7e5f),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: overallProgress / 100,
                        backgroundColor: const Color(0xFFffe8d6),
                        color: const Color(0xFFff7e5f),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_formatNumber(userProgress)} / ${_formatNumber(t.minValue)} ${t.metric}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Milestones Completed: $completedMilestones/${milestones.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4caf50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Milestones List
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Milestones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(milestones.length, (index) {
                  final target = milestones[index];
                  final isCompleted = userProgress >= target;
                  final isCurrent = !isCompleted &&
                      (index == 0 || userProgress >= milestones[index - 1]);

                  final prevTarget = index == 0 ? 0 : milestones[index - 1];
                  final milestoneRange = target - prevTarget;
                  final currentRangeProgress = userProgress - prevTarget;
                  final milestoneProgress = milestoneRange > 0
                      ? (currentRangeProgress / milestoneRange).clamp(0.0, 1.0)
                      : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF4caf50).withOpacity(0.05)
                          : isCurrent
                              ? const Color(0xFFff7e5f).withOpacity(0.05)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFF4caf50)
                            : isCurrent
                                ? const Color(0xFFff7e5f)
                                : const Color(0xFFffe8d6),
                        width: isCurrent ? 2 : 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFFff7e5f).withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  metricIcon,
                                  size: 14,
                                  color: isCompleted
                                      ? const Color(0xFF4caf50)
                                      : isCurrent
                                          ? const Color(0xFFff7e5f)
                                          : const Color(0xFF666666),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getMilestoneTitle(t.metric, target, index),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isCompleted
                                        ? const Color(0xFF4caf50)
                                        : isCurrent
                                            ? const Color(0xFF333333)
                                            : const Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFF4caf50).withOpacity(0.1)
                                    : isCurrent
                                        ? const Color(0xFFff7e5f)
                                            .withOpacity(0.1)
                                        : const Color(0xFF999999)
                                            .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isCompleted
                                    ? 'Completed'
                                    : isCurrent
                                        ? 'In Progress'
                                        : 'Upcoming',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted
                                      ? const Color(0xFF4caf50)
                                      : isCurrent
                                          ? const Color(0xFFff7e5f)
                                          : const Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 12),
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFffe8d6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: milestoneProgress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFff7e5f),
                                      Color(0xFFfeb47b),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currentRangeProgress.clamp(0, milestoneRange).toStringAsFixed(0)} / $milestoneRange',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ] else if (isCompleted) ...[
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF4caf50),
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Completed!',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4caf50),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Leaderboard
                if (_details != null &&
                    (_details!['leaderboard'] as List).isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Current Leaderboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...(_details!['leaderboard'] as List)
                      .cast<LeaderboardEntry>()
                      .map(
                        (entry) => _buildLeaderboardItem(
                          rank: entry.rank,
                          avatar: entry.avatar,
                          name: entry.name,
                          value: entry.value,
                          isYou: entry.isYou,
                          avatarId: entry.avatarId,
                        ),
                      ),
                ],
                const SizedBox(height: 25),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF333333),
                        backgroundColor: const Color(0xFFffe8d6),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String avatar,
    required String name,
    required int value,
    required bool isYou,
    String? avatarId,
  }) {
    Color rankColor = const Color(0xFFff7e5f);
    Color avatarBgStart = const Color(0xFFff7e5f);
    Color avatarBgEnd = const Color(0xFFfeb47b);
    Color avatarTextColor = Colors.white;
    FontWeight rankFontWeight = FontWeight.w700;

    if (rank == 1) {
      rankColor = const Color(0xFFffd700);
      avatarBgStart = const Color(0xFFffd700);
      avatarBgEnd = const Color(0xFFffed4e);
      avatarTextColor = const Color(0xFF333333);
    } else if (rank == 2) {
      rankColor = const Color(0xFFc0c0c0);
      avatarBgStart = const Color(0xFFc0c0c0);
      avatarBgEnd = const Color(0xFFe0e0e0);
      avatarTextColor = const Color(0xFF333333);
    } else if (rank == 3) {
      rankColor = const Color(0xFFcd7f32);
      avatarBgStart = const Color(0xFFcd7f32);
      avatarBgEnd = const Color(0xFFe39e5a);
      avatarTextColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isYou ? const Color(0xFFff7e5f).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isYou ? const Color(0xFFff7e5f) : const Color(0xFFffe8d6),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: rankFontWeight,
                      color: rankColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (rank <= 3)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [avatarBgStart, avatarBgEnd],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: rankColor.withOpacity(0.3),
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          rank == 1
                              ? '🥇'
                              : rank == 2
                                  ? '🥈'
                                  : '🥉',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: avatarId != null ? Colors.white : null,
              gradient: avatarId != null
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [avatarBgStart, avatarBgEnd],
                    ),
              shape: BoxShape.circle,
              border: avatarId != null
                  ? Border.all(color: const Color(0xFFff7e5f), width: 1.5)
                  : null,
              boxShadow: rank <= 3 && avatarId == null
                  ? [
                      BoxShadow(
                        color: rankColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: avatarId != null
                  ? Icon(
                      AvatarUtils.getIcon(avatarId),
                      color: const Color(0xFFff7e5f),
                      size: 18,
                    )
                  : Text(
                      avatar,
                      style: TextStyle(
                        color: avatarTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    isYou ? const Color(0xFFff7e5f) : const Color(0xFF333333),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            _formatNumber(value),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: rank <= 3 ? rankColor : const Color(0xFFff7e5f),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// String Capitalization Extension
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
