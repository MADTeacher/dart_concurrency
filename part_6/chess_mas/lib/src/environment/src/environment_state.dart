import '../../board/board.dart';

// Базовый класс для представления различных
// состояний среды выполнения
sealed class EnvironmentState {
  // Текущая шахматная доска
  final Board board;

  const EnvironmentState({required this.board});
}

// Состояние, указывающее, что среда в данный момент
// выполняет вычисления или обрабатывает логику
//(например, ожидает ответы от агентов)
class RunningEnvState extends EnvironmentState {
  RunningEnvState({required super.board});
}

// Состояние, указывающее, что среда готова к
// следующему шагу или эпохе. Может содержать
// [event], которое привело к этому состоянию
// (например, ход фигуры)
class ReadyEnvState extends EnvironmentState {
  final BoardEvent? event;

  ReadyEnvState({
    required super.board,
    required this.event,
  });
}

// Состояние, указывающее, что работа среды завершена.
// Это происходит, когда достигается равновесное
// состояние системы (например, нет конфликтов),
// либо достигнут лимит максимального количества
// эпох моделирования
class FinishEnvState extends EnvironmentState {
  // Номер эпохи, на которой завершилось моделирование
  final int epochNumber;

  const FinishEnvState({
    required super.board,
    required this.epochNumber,
  });
}
