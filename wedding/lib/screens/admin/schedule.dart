import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wedding/services/api_service.dart';

class ScheduleScreen extends StatefulWidget {
  final String elementId;

  const ScheduleScreen({super.key, required this.elementId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  Set<DateTime> _markedDates = {};
  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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

  Future<void> _toggleDate(DateTime date) async {
    try {
      // Always use UTC date for server communication
      final utcDate = DateTime.utc(date.year, date.month, date.day);
      await ApiService.toggleMarkedDate(widget.elementId, utcDate);
      
      setState(() {
        if (_markedDates.contains(date)) {
          _markedDates.remove(date);
        } else {
          _markedDates.add(date);
        }
      });
    } catch (e) {
      _showErrorSnackbar('Operation failed: $e');
    }
  }

  Future<void> _unmarkDate(DateTime date) async {
    try {
      // Always use UTC date for server communication
      final utcDate = DateTime.utc(date.year, date.month, date.day);
      await ApiService.unmarkDate(widget.elementId, utcDate);
      setState(() => _markedDates.remove(date));
    } catch (e) {
      _showErrorSnackbar('Failed to unmark date: $e');
      // Refresh dates if unmarking fails
      _loadMarkedDates();
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

  void _showUnmarkConfirmation(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unmark Date'),
        content: Text(
          'Are you sure you want to unmark ${DateFormat.yMMMMd().format(date)}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unmarkDate(date);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmMarkedDate() async {
    final input = _dateController.text.trim();
    try {
      final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(input);
      // Normalize to local date without time
      final normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      
      await _toggleDate(normalizedDate);
      _dateController.clear();
      
      setState(() {
        _focusedMonth = DateTime(normalizedDate.year, normalizedDate.month);
      });
    } catch (e) {
      _showErrorSnackbar('Invalid date format! Use dd/MM/yyyy');
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            hintText: 'dd/MM/yyyy',
                            labelText: 'Mark dates',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _confirmMarkedDate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
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
        final isSelected =
            day == _selectedDate.day &&
            _focusedMonth.month == _selectedDate.month &&
            _focusedMonth.year == _selectedDate.year;
        final isToday =
            day == DateTime.now().day &&
            _focusedMonth.month == DateTime.now().month &&
            _focusedMonth.year == DateTime.now().year;
        final isMarked = _markedDates.any(
          (d) => d.year == date.year && d.month == date.month && d.day == date.day,
        );

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDate = date);
            
            // Show unmark confirmation for marked dates
            if (isMarked) {
              _showUnmarkConfirmation(date);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.black87
                      : isMarked
                      ? Colors.red
                      : isToday
                      ? Colors.grey[200]
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              border:
                  isToday && !isSelected && !isMarked
                      ? Border.all(color: Colors.black38, width: 1)
                      : null,
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    isToday || isSelected || isMarked
                        ? FontWeight.bold
                        : FontWeight.normal,
                color: isSelected || isMarked ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}