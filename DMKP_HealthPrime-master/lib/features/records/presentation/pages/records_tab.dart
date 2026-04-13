import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/core/utils/helpers.dart';
import 'package:healthprime/core/providers/records_provider.dart';
import 'package:healthprime/features/home/presentation/widgets/add_edit_record_overlay.dart';
import 'package:healthprime/features/records/presentation/widgets/record_item.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../data/models/health_record.dart';

class RecordsPage extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const RecordsPage({
    super.key,
    this.onNotificationTap,
    this.onAccountTap,
  });

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  DateTime? _selectedDate;

  // Select Date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      });
    }
  }

  // Clear Date
  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  // Is Same Day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfef9f5),
      body: Column(
        children: [
          AppHeader(
            title: 'Health Records',
            showNotification: true,
            showAccount: true,
            onNotificationTap: widget.onNotificationTap,
            onAccountTap: widget.onAccountTap,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history,
                              color: Color(0xFFff7e5f), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Health Records',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                              color: const Color(0xFFff7e5f), width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                              const AddEditRecordOverlay(),
                            );
                          },
                          icon: const Icon(Icons.add,
                              color: Color(0xFFff7e5f), size: 16),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Color(0xFFff7e5f), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Search by date'
                                  : Helpers.formatDisplayDate(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? const Color(0xFF999999)
                                    : const Color(0xFF333333),
                                fontSize: 14,
                                fontWeight: _selectedDate == null
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_selectedDate != null)
                            GestureDetector(
                              onTap: _clearDate,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFff7e5f),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 10),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: Consumer<RecordsProvider>(
                      builder: (context, provider, child) {
                        List<HealthRecord> listToShow;
                        bool showLoadMore = false;

                        if (_selectedDate != null) {
                          // Search Mode
                          listToShow = provider.allRecordsForSearch
                              .where((r) => _isSameDay(r.date, _selectedDate!))
                              .toList();
                        } else {
                          // Default Mode
                          listToShow = provider.displayedRecords;
                          showLoadMore = provider.hasMoreRecords;
                        }

                        if (listToShow.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.note_alt_outlined,
                                    size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 10),
                                Text(
                                  _selectedDate == null
                                      ? "No records yet"
                                      : "No records found for this date",
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: listToShow.length + (_selectedDate == null ? 1 : 0),
                          separatorBuilder: (c, i) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == listToShow.length) {
                              if (showLoadMore) {
                                return TextButton(
                                  onPressed: () => provider.loadMoreRecords(),
                                  child: const Text('Show More',
                                      style: TextStyle(color: Color(0xFFff7e5f), fontWeight: FontWeight.bold)),
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Text('No more records',
                                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ),
                                );
                              }
                            }

                            final record = listToShow[index];
                            return RecordItem(record: record);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}