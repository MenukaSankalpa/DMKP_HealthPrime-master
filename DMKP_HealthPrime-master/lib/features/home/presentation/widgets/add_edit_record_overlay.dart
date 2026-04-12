import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/core/providers/records_provider.dart';
import 'package:healthprime/data/models/health_record.dart';
import '../../../../core/utils/helpers.dart';

class AddEditRecordOverlay extends StatefulWidget {
  final bool isEditing;
  final HealthRecord? record;

  const AddEditRecordOverlay({
    super.key,
    this.isEditing = false,
    this.record,
  });

  @override
  State<AddEditRecordOverlay> createState() => _AddEditRecordOverlayState();
}

class _AddEditRecordOverlayState extends State<AddEditRecordOverlay> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _stepsController;
  late TextEditingController _caloriesController;
  late TextEditingController _waterController;
  late TextEditingController _sleepController;
  late TextEditingController _weightController;
  late TextEditingController _heartRateController;
  late TextEditingController _fruitsController;
  late TextEditingController _workoutController;
  late TextEditingController _moodController;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.record?.date ?? DateTime.now();

    final r = widget.record;

    _dateController = TextEditingController(
      text: DateFormat('MMM d, yyyy').format(_selectedDate),
    );
    _stepsController = TextEditingController(text: r?.steps.toString() ?? '');
    _caloriesController = TextEditingController(text: r?.calories.toString() ?? '');
    _waterController = TextEditingController(text: r?.water.toString() ?? '');
    _sleepController = TextEditingController(text: r?.sleep.toString() ?? '');
    _weightController = TextEditingController(text: r?.weight?.toString() ?? '');
    _heartRateController = TextEditingController(text: r?.heartRate.toString() ?? '');
    _fruitsController = TextEditingController(text: r?.fruits?.toString() ?? '');
    _workoutController = TextEditingController(text: r?.workout?.toString() ?? '');
    _moodController = TextEditingController(text: r?.mood.toString() ?? '5');
  }

  // Select Date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  // Save Record
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newRecord = HealthRecord(
          id: widget.record?.id ?? '',
          date: _selectedDate,
          steps: int.tryParse(_stepsController.text) ?? 0,
          calories: int.tryParse(_caloriesController.text) ?? 0,
          water: int.tryParse(_waterController.text) ?? 0,
          sleep: double.tryParse(_sleepController.text) ?? 0.0,
          weight: double.tryParse(_weightController.text),
          heartRate: int.tryParse(_heartRateController.text) ?? 0,
          fruits: int.tryParse(_fruitsController.text),
          workout: int.tryParse(_workoutController.text),
          mood: int.tryParse(_moodController.text) ?? 5,
        );

        await Provider.of<RecordsProvider>(context, listen: false).saveRecord(newRecord);

        if (mounted) {
          Navigator.pop(context);
          Helpers.showSnackBar(context, 'Record saved successfully!', isError: false);
        }
      } catch (e) {
        if (mounted) {
          Helpers.showSnackBar(context, 'Error saving: $e', isError: true);
        }
      }
    }
  }

  // Delete Record
  Future<void> _delete() async {
    if (widget.record != null) {
      try {
        await Provider.of<RecordsProvider>(context, listen: false).deleteRecord(widget.record!.id);
        if (mounted) {
          Navigator.pop(context);
          Helpers.showSnackBar(context, 'Record deleted', isError: false);
        }
      } catch (e) {
        if (mounted) {
          Helpers.showSnackBar(context, 'Error deleting: $e', isError: true);
        }
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isEditing ? Icons.edit : Icons.add_circle,
                      color: const Color(0xFFff7e5f),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEditing ? 'Edit Health Record' : 'Add Health Record',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildFormField(
                        context: context,
                        label: 'Date',
                        icon: Icons.calendar_today,
                        controller: _dateController,
                        isDate: true,
                      ),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Steps Walked', icon: Icons.directions_walk, controller: _stepsController, isNumber: true),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Calories Burned', icon: Icons.local_fire_department, controller: _caloriesController, isNumber: true),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Water Intake (ml)', icon: Icons.water_drop, controller: _waterController, isNumber: true),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Sleep (hours)', icon: Icons.bedtime, controller: _sleepController, isNumber: true, isDecimal: true),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Weight (kg)', icon: Icons.monitor_weight, controller: _weightController, isNumber: true, isDecimal: true),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Heart Rate (bpm)', icon: Icons.favorite, controller: _heartRateController, isNumber: true),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Fruits/Vegetables', icon: Icons.apple, controller: _fruitsController, isNumber: true),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Workout (minutes)', icon: Icons.fitness_center, controller: _workoutController, isNumber: true),
                      const SizedBox(height: 12),
                      _buildFormField(context: context, label: 'Mood (1-10)', icon: Icons.sentiment_satisfied, controller: _moodController, isNumber: true),

                      const SizedBox(height: 25),

                      // Action Buttons
                      Row(
                        children: [
                          if (widget.isEditing)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _delete,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFff6b6b),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Delete'),
                              ),
                            ),
                          if (widget.isEditing) const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF333333),
                                backgroundColor: const Color(0xFFffe8d6),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isNumber = false,
    bool isDecimal = false,
    bool isDate = false,
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFff7e5f)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF555555), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber
              ? isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number
              : TextInputType.text,
          readOnly: isDate,
          onTap: isDate ? () => _selectDate(context) : null,
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          decoration: InputDecoration(
            hintText: isDate ? 'Select a date' : 'Enter $label',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            filled: true,
            fillColor: const Color(0xFFfff9f2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFffe8d6))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFffe8d6))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFff7e5f), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: isDate ? const Icon(Icons.calendar_today, size: 18, color: Color(0xFFff7e5f)) : null,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    _sleepController.dispose();
    _weightController.dispose();
    _heartRateController.dispose();
    _fruitsController.dispose();
    _workoutController.dispose();
    _moodController.dispose();
    super.dispose();
  }
}