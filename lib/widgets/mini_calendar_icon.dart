import 'package:flutter/material.dart';
import '../theme.dart';

class MiniCalendarIcon extends StatelessWidget {
  final DateTime date;
  final double size;

  const MiniCalendarIcon({
    super.key,
    required this.date,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate which week of the month this date falls in (0-indexed)
    // Simple approximation: (day - 1) / 7
    // A more accurate one would consider the first day of the month's weekday.
    
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    // Weekday of 1st day: Mon=1...Sun=7
    // Adjust to 0-indexed where Mon=0...Sun=6
    final firstWeekday = firstDayOfMonth.weekday - 1; 
    
    // Day of month (1-31)
    final day = date.day;
    
    // Calculate row index (0 to 5)
    // (day + firstWeekday - 1) ~/ 7
    final rowIndex = (day + firstWeekday - 1) ~/ 7;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).toInt()),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header
          Container(
            height: size * 0.3,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.month}월',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
          // Calendar Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(size * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (col) {
                      final isCurrentRow = row == rowIndex;
                      // We only highlight the row, not specific day, as requested "visualize week"
                      // Or maybe just the row is enough to show "which week".
                      
                      return Container(
                        width: size * 0.08,
                        height: size * 0.08,
                        decoration: BoxDecoration(
                          color: isCurrentRow 
                              ? AppTheme.primaryColor.withAlpha((255 * 0.6).toInt()) 
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
