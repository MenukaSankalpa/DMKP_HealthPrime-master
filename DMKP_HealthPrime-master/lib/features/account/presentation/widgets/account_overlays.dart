import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/avatar_utils.dart';
import '../../../../core/utils/helpers.dart';

// Edit Profile Overlay
class EditProfileOverlay extends StatefulWidget {
  final String? initialName;
  final String? initialAge;
  final String? initialGender;
  final String? initialHeight;

  const EditProfileOverlay({
    super.key,
    this.initialName,
    this.initialAge,
    this.initialGender,
    this.initialHeight,
  });

  @override
  State<EditProfileOverlay> createState() => _EditProfileOverlayState();
}

class _EditProfileOverlayState extends State<EditProfileOverlay> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  String _gender = 'Not specified';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final data = auth.userData;

    _nameController = TextEditingController(text: data?['name'] ?? '');
    _emailController = TextEditingController(text: auth.user?.email ?? '');
    _ageController =
        TextEditingController(text: data?['age']?.toString() ?? '');
    _heightController =
        TextEditingController(text: data?['height']?.toString() ?? '');

    String dbGender = data?['gender'] ?? 'Not specified';
    const validGenders = ['Male', 'Female', 'Other', 'Not specified'];
    _gender = validGenders.contains(dbGender) ? dbGender : 'Not specified';
  }

  // Save Profile Changes
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Provider.of<AuthProvider>(context, listen: false).updateProfile(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text),
          gender: _gender,
          height: double.tryParse(_heightController.text),
        );
        if (mounted) {
          Navigator.of(context).pop();
          Helpers.showSnackBar(context, 'Profile updated successfully!',
              isError: false);
        }
      } catch (e) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userData = auth.userData;
    final initial = userData?['avatarInitial'] ?? 'U';
    final avatarId = userData?['avatarId'];

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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      color: Color(0xFFff7e5f),
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarId != null
                        ? Colors.white
                        : const Color(0xFFff7e5f),
                    border:
                        Border.all(color: const Color(0xFFff7e5f), width: 3),
                    gradient: avatarId == null
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
                          )
                        : null,
                  ),
                  child: Center(
                    child: avatarId != null
                        ? Icon(
                            AvatarUtils.getIcon(avatarId),
                            size: 60,
                            color: const Color(0xFFff7e5f),
                          )
                        : Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildFormField(
                        label: 'Full Name',
                        icon: Icons.person,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: 0.7,
                        child: _buildFormField(
                          label: 'Email Address',
                          icon: Icons.email,
                          controller: _emailController,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFormField(
                        label: 'Age',
                        icon: Icons.cake,
                        controller: _ageController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownField(
                        label: 'Gender',
                        icon: Icons.person_outline,
                        value: _gender,
                        items: const [
                          'Male',
                          'Female',
                          'Other',
                          'Not specified'
                        ],
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      const SizedBox(height: 12),
                      _buildFormField(
                        label: 'Height (cm)',
                        icon: Icons.straighten,
                        controller: _heightController,
                        isNumber: true,
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF333333),
                                backgroundColor: const Color(0xFFffe8d6),
                                side: BorderSide.none,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.save, size: 16),
                              label: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFff7e5f)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF555555),
                    fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            hintText: readOnly ? '' : 'Enter your $label',
            hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
                fontWeight: FontWeight.normal),
            filled: true,
            fillColor:
                readOnly ? const Color(0xFFf5f5f5) : const Color(0xFFfff9f2),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFffe8d6))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFffe8d6))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFff7e5f), width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
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
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF555555),
                    fontSize: 14)),
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
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                fontWeight: FontWeight.normal),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item,
                    style: const TextStyle(fontWeight: FontWeight.normal)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}

// Notification Settings Overlay
class NotificationSettingsOverlay extends StatefulWidget {
  const NotificationSettingsOverlay({super.key});

  @override
  State<NotificationSettingsOverlay> createState() =>
      _NotificationSettingsOverlayState();
}

class _NotificationSettingsOverlayState
    extends State<NotificationSettingsOverlay> {
  bool _friends = true;
  bool _tournaments = true;
  bool _publicTournaments = true;
  bool _reminders = true;

  @override
  void initState() {
    super.initState();
    final settings =
        Provider.of<AuthProvider>(context, listen: false).notificationSettings;
    _friends = settings['friendRequests'] ?? true;
    _tournaments = settings['tournamentUpdates'] ?? true;
    _publicTournaments = settings['publicTournaments'] ?? true;
    _reminders = settings['tournamentReminders'] ?? true;
  }

  // Save Notification Settings
  Future<void> _save() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .updateNotificationSettings({
        'friendRequests': _friends,
        'tournamentUpdates': _tournaments,
        'publicTournaments': _publicTournaments,
        'tournamentReminders': _reminders,
      });
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Notification settings saved!',
            isError: false);
      }
    } catch (e) {
      Helpers.showSnackBar(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications, color: Color(0xFFff7e5f), size: 24),
                  SizedBox(width: 8),
                  Text('Notification Settings',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333))),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  _buildNotificationItem(
                    title: 'New Friend Request',
                    description:
                        'Get notified when someone sends you a friend request',
                    value: _friends,
                    onChanged: (value) => setState(() => _friends = value!),
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationItem(
                    title: 'Tournament Invitation',
                    description:
                        "Get notified when you're invited to a tournament",
                    value: _tournaments,
                    onChanged: (value) => setState(() => _tournaments = value!),
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationItem(
                    title: 'New Public Tournament',
                    description:
                        'Get notified when new public tournaments are created',
                    value: _publicTournaments,
                    onChanged: (value) =>
                        setState(() => _publicTournaments = value!),
                  ),
                  const SizedBox(height: 10),
                  _buildNotificationItem(
                    title: 'Tournament Reminder',
                    description: 'Get reminders about ongoing tournaments',
                    value: _reminders,
                    onChanged: (value) => setState(() => _reminders = value!),
                  ),
                ],
              ),
              const SizedBox(height: 25),
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
                            borderRadius: BorderRadius.circular(12)),
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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text('Save'),
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

  Widget _buildNotificationItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFfff9f2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFffe8d6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF666666))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 50,
            height: 26,
            child: Switch(
              value: value,
              activeColor: const Color(0xFFff7e5f),
              inactiveTrackColor: Colors.white,
              inactiveThumbColor: Colors.grey.shade400,
              trackOutlineColor: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? Colors.transparent
                    : const Color(0xFFffe8d6),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Health Goals Overlay
class HealthGoalsOverlay extends StatefulWidget {
  const HealthGoalsOverlay({super.key});

  @override
  State<HealthGoalsOverlay> createState() => _HealthGoalsOverlayState();
}

class _HealthGoalsOverlayState extends State<HealthGoalsOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();
  final _sleepController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _fruitsController = TextEditingController();
  final _workoutController = TextEditingController();
  final _moodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final goals =
        Provider.of<AuthProvider>(context, listen: false).healthGoals ?? {};

    _stepsController.text = goals['steps']?.toString() ?? '10000';
    _caloriesController.text = goals['calories']?.toString() ?? '500';
    _waterController.text = goals['water']?.toString() ?? '2000';
    _sleepController.text = goals['sleep']?.toString() ?? '8';
    _heartRateController.text = goals['heartRate']?.toString() ?? '70';
    _weightController.text = goals['weight']?.toString() ?? '70';
    _fruitsController.text = goals['fruits']?.toString() ?? '5';
    _workoutController.text = goals['workout']?.toString() ?? '60';
    _moodController.text = goals['mood']?.toString() ?? '10';
  }

  // Save Health Goals
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final newGoals = {
        'steps': int.tryParse(_stepsController.text) ?? 10000,
        'calories': int.tryParse(_caloriesController.text) ?? 500,
        'water': int.tryParse(_waterController.text) ?? 2000,
        'sleep': double.tryParse(_sleepController.text) ?? 8.0,
        'heartRate': int.tryParse(_heartRateController.text) ?? 70,
        'weight': double.tryParse(_weightController.text) ?? 70.0,
        'fruits': int.tryParse(_fruitsController.text) ?? 5,
        'workout': int.tryParse(_workoutController.text) ?? 60,
        'mood': int.tryParse(_moodController.text) ?? 10,
      };

      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .updateHealthGoals(newGoals);
        if (mounted) {
          Navigator.pop(context);
          Helpers.showSnackBar(context, 'Health goals saved!', isError: false);
        }
      } catch (e) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        constraints: const BoxConstraints(maxHeight: 600),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flag, color: Color(0xFFff7e5f), size: 24),
                    SizedBox(width: 8),
                    Text('Set Health Goals',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333))),
                  ],
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildGoalItem(
                          icon: Icons.directions_walk,
                          title: 'Daily Steps Goal',
                          controller: _stepsController,
                          unit: 'steps'),
                      const SizedBox(height: 12),
                      _buildGoalItem(
                          icon: Icons.local_fire_department,
                          title: 'Daily Calories Goal',
                          controller: _caloriesController,
                          unit: 'kcal'),
                      const SizedBox(height: 12),
                      _buildGoalItem(
                          icon: Icons.water_drop,
                          title: 'Daily Water Goal',
                          controller: _waterController,
                          unit: 'ml'),
                      const SizedBox(height: 12),
                      _buildGoalItem(
                          icon: Icons.bedtime,
                          title: 'Daily Sleep Goal',
                          controller: _sleepController,
                          unit: 'hours',
                          isDecimal: true),
                      const SizedBox(height: 12),
                      _buildGoalItem(
                          icon: Icons.favorite,
                          title: 'Heart Rate Goal',
                          controller: _heartRateController,
                          unit: 'bpm'),
                      const SizedBox(height: 12),
                      _buildGoalItem(
                          icon: Icons.monitor_weight,
                          title: 'Weight Goal',
                          controller: _weightController,
                          unit: 'kg',
                          isDecimal: true),
                      const SizedBox(height: 12),
                      _buildGoalItem(
                          icon: Icons.apple,
                          title: 'Daily Fruits Goal',
                          controller: _fruitsController,
                          unit: 'servings'),
                      const SizedBox(height: 12),
                      _buildGoalItem(
                          icon: Icons.fitness_center,
                          title: 'Daily Workout Goal',
                          controller: _workoutController,
                          unit: 'minutes'),
                      const SizedBox(height: 12),
                      _buildGoalItem(
                          icon: Icons.sentiment_satisfied,
                          title: 'Mood Goal',
                          controller: _moodController,
                          unit: '/10'),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF333333),
                                backgroundColor: const Color(0xFFffe8d6),
                                side: BorderSide.none,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.save, size: 16),
                              label: const Text('Save Goals'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String unit,
    bool isDecimal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFfff9f2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFffe8d6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFff7e5f).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFff7e5f), size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: isDecimal
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.number,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFffe8d6))),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 60,
                child: Text(unit,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF666666))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    _sleepController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _fruitsController.dispose();
    _workoutController.dispose();
    _moodController.dispose();
    super.dispose();
  }
}

// Change Password Overlay
class ChangePasswordOverlay extends StatefulWidget {
  const ChangePasswordOverlay({super.key});

  @override
  State<ChangePasswordOverlay> createState() => _ChangePasswordOverlayState();
}

class _ChangePasswordOverlayState extends State<ChangePasswordOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Save New Password
  Future<void> _change() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        Helpers.showSnackBar(context, 'New passwords do not match!',
            isError: true);
        return;
      }

      try {
        await Provider.of<AuthProvider>(context, listen: false).changePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );
        if (mounted) {
          Navigator.pop(context);
          Helpers.showSnackBar(context, 'Password changed successfully!',
              isError: false);
        }
      } catch (e) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Color(0xFFff7e5f), size: 24),
                  SizedBox(width: 8),
                  Text('Change Password',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333))),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPasswordField(
                        label: 'Current Password',
                        icon: Icons.lock,
                        controller: _currentPasswordController),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                        label: 'New Password',
                        icon: Icons.vpn_key,
                        controller: _newPasswordController),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                        label: 'Confirm New Password',
                        icon: Icons.vpn_key,
                        controller: _confirmPasswordController),
                    const SizedBox(height: 25),
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
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _change,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFff7e5f),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.save, size: 16),
                            label: const Text('Confirm'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFff7e5f)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF555555),
                    fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
                fontWeight: FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFfff9f2),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFffe8d6))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFffe8d6))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFff7e5f), width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Delete Account Overlay
class DeleteAccountOverlay extends StatefulWidget {
  const DeleteAccountOverlay({super.key});

  @override
  State<DeleteAccountOverlay> createState() => _DeleteAccountOverlayState();
}

class _DeleteAccountOverlayState extends State<DeleteAccountOverlay> {
  final _confirmationController = TextEditingController();
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_updateConfirmationStatus);
  }

  void _updateConfirmationStatus() {
    setState(() {
      _isConfirmed = _confirmationController.text == 'DELETE';
    });
  }

  // Delete Account
  Future<void> _deleteAccount() async {
    if (_isConfirmed) {
      try {
        await Provider.of<AuthProvider>(context, listen: false).deleteAccount();
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Color(0xFFf44336), size: 24),
                  SizedBox(width: 8),
                  Text('Delete Account',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333))),
                ],
              ),
              const SizedBox(height: 20),
              const Column(
                children: [
                  Icon(Icons.delete, color: Color(0xFFf44336), size: 48),
                  SizedBox(height: 15),
                  Text('Are you sure?',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333))),
                  SizedBox(height: 10),
                  Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                  SizedBox(height: 5),
                  Text(
                      'Including health records, friends, tournament history, and achievements.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error, size: 16, color: Color(0xFFff7e5f)),
                      SizedBox(width: 6),
                      Text('Type "DELETE" to confirm',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF555555),
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmationController,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                      hintText: 'Type DELETE to confirm',
                      hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.normal),
                      filled: true,
                      fillColor: const Color(0xFFfff9f2),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFffe8d6))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFFffe8d6))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFff7e5f), width: 2)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  if (_confirmationController.text.isNotEmpty && !_isConfirmed)
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                          'Please type DELETE exactly as shown to confirm deletion.',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFFf44336))),
                    ),
                ],
              ),
              const SizedBox(height: 25),
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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isConfirmed ? _deleteAccount : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf44336),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Proceed'),
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

  @override
  void dispose() {
    _confirmationController.removeListener(_updateConfirmationStatus);
    _confirmationController.dispose();
    super.dispose();
  }
}
