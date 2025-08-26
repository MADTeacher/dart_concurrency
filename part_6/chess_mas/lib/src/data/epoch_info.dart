import 'package:equatable/equatable.dart';

class EpochInfo extends Equatable {
  // Количество конфликтов, зафиксированных в данной эпохе
  // Конфликт — это ситуация, когда две фигуры угрожают друг другу
  final int numberOfConflicts;

  const EpochInfo(this.numberOfConflicts);

  @override
  String toString() {
    return 'EpochInfo(numberOfConflicts: $numberOfConflicts)';
  }

  // Свойства, используемые для сравнения объектов EpochInfo
  @override
  List<Object?> get props => [numberOfConflicts];
}
