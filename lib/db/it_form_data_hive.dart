import 'package:hive/hive.dart';

part 'it_form_data_hive.g.dart';

@HiveType(typeId: 0)
class ItFormDataHive extends HiveObject {
  ItFormDataHive({
    required this.name,
    required this.pen,
    required this.pan,
    required this.designation,
    required this.institution,
    required this.localBodyType,
    required this.basicPayMarch2026,
    required this.nextIncrementMonth,
    required this.bpAfterIncrement,
    required this.otherIncome,
    required this.taxAlreadyPaid,
    required this.daPercent,
    required this.remainingMonths,
    required this.relief,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  String pen;

  @HiveField(2)
  String pan;

  @HiveField(3)
  String designation;

  @HiveField(4)
  String institution;

  @HiveField(5)
  String localBodyType;

  @HiveField(6)
  String basicPayMarch2026;

  /// Calendar month (1–12); -1 means "not selected".
  @HiveField(7)
  int nextIncrementMonth;

  @HiveField(8)
  String bpAfterIncrement;

  @HiveField(9)
  String otherIncome;

  @HiveField(10)
  String taxAlreadyPaid;

  @HiveField(11)
  String daPercent;

  @HiveField(12)
  String remainingMonths;

  /// Relief for Salary Arrears u/s 89(1). Stored as String to match controller.
  @HiveField(13)
  String relief;
}