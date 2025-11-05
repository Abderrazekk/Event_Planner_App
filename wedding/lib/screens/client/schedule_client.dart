import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wedding/services/api_service.dart';

class ScheduleClientScreen extends StatefulWidget {
  final String elementId;

  const ScheduleClientScreen({super.key, required this.elementId});

  @override
  State<ScheduleClientScreen> createState() => _ScheduleClientScreenState();
}

class _ScheduleClientScreenState extends State<ScheduleClientScreen> {
  late DateTime _focusedMonth;
  Set<DateTime> _markedDates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _loadMarkedDates();
  }

  Future<void> _loadMarkedDates() async {
    setState(() => _isLoading = true);
    try {
      final dates = await ApiService.getMarkedDates(widget.elementId);
      setState(() => _markedDates = dates);
    } catch (e) {
      _showErrorSnackbar('Failed to load dates: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthSelector(),
                _buildWeekdayHeader(),
                Expanded(child: _buildCalendarGrid()),
                // Removed the date input and confirmation button
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'View-only mode: Clients cannot modify dates',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black87),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            DateFormat.yMMMM().format(_focusedMonth),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black87),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            weekdays
                .map(
                  (day) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final dayOffset = (firstDayOfMonth.weekday - 1) % 7;

    final days = List.generate(42, (index) {
      final day = index - dayOffset + 1;
      if (day < 1 || day > daysInMonth) return null;
      return day;
    });

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        if (day == null) return Container();

        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final isToday =
            day == DateTime.now().day &&
            _focusedMonth.month == DateTime.now().month &&
            _focusedMonth.year == DateTime.now().year;
        final isMarked = _markedDates.any(
          (d) => d.year == date.year && d.month == date.month && d.day == date.day,
        );

        return Container(
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color:
                isMarked
                    ? Colors.red
                    : isToday
                    ? Colors.grey[200]
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            border:
                isToday && !isMarked
                    ? Border.all(color: Colors.black38, width: 1)
                    : null,
          ),
          alignment: Alignment.center,
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  isToday || isMarked
                      ? FontWeight.bold
                      : FontWeight.normal,
              color: isMarked ? Colors.white : Colors.black87,
            ),
          ),
        );
      },
    );
  }
}