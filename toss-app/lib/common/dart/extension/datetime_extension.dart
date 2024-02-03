import 'package:easy_localization/easy_localization.dart';

extension DateTimeExtension on DateTime {
  String get formattedDate => DateFormat('yyyy년 MM월 dd일').format(this);

  String get formattedTime => DateFormat('HH:mm').format(this);

  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);

  String get relativeDays {
    final diffDays = difference(DateTime.now().onlyDate).inDays;
    final isNegative = diffDays.isNegative;

    final checkCondition = (diffDays, isNegative);

    return switch (checkCondition) {
      (0, _) => _tillToday,
      (1, _) => _tillTomorrow,
      (_, true) => _daysPassed,
      _ => _daysLeft
    };
  }

  DateTime get onlyDate {
    return DateTime(year, month, day);
  }

  String get _daysLeft => 'daysLeft'
    .tr(namedArgs: {"daysCount": difference(DateTime.now().onlyDate).inDays.toString()})
  ;

  String get _tillToday => 'dayLeft';

  String get _tillTomorrow => 'dayLeft';

  String get _daysPassed => 'daysPassed'
      .tr(namedArgs: {"daysCount": difference(DateTime.now().onlyDate).inDays.toString()})
  ;
}
