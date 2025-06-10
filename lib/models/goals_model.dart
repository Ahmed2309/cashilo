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

  @HiveField(5)
  String priority; // 'Low', 'Medium', 'High'

  @HiveField(6)
  bool stopped; // Add this field

  Goal({
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.startDate,
    this.endDate,
    required this.priority,
    this.stopped = false, // default to false
  });
}
