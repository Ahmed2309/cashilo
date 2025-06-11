import 'package:hive/hive.dart';

part 'goals_model.g.dart';

@HiveType(typeId: 1)
class Goal extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double savedAmount;

  @HiveField(3)
  DateTime? startDate;

  @HiveField(4)
  DateTime? endDate;

  @HiveField(6)
  bool stopped; // Add this field

  // Add a weight field or getter. Adjust the logic as needed.
  double get weight =>
      targetAmount - savedAmount > 0 ? targetAmount - savedAmount : 1;

  Goal({
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.startDate,
    this.endDate,
    this.stopped = false, // default to false
  });
}
