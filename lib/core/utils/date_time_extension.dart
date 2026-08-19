import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toDayMonth() => DateFormat('d MMM').format(this);
  String toDayMonthYear() => DateFormat('d MMM yyyy').format(this);
  String toFullDate() => DateFormat('EEEE, d MMM yyyy').format(this);
  String toTime() => DateFormat('HH:mm').format(this);
  String toDateTime() => DateFormat('d MMM yyyy, HH:mm').format(this);

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isPast() => isBefore(DateTime.now());

  /// "2 hari lagi", "Besok", "Hari ini", "Terlambat 3 hari"
  String toRelativeDeadline() {
    final now = DateTime.now();
    final diff = difference(DateTime(now.year, now.month, now.day));

    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Besok';
    if (diff.inDays > 1) return '${diff.inDays} hari lagi';
    return 'Terlambat ${diff.inDays.abs()} hari';
  }
}