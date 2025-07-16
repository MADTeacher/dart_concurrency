import 'dart:async';

class Schedule {
  final String info;
  const Schedule(this.info);
}

// Метод на запрос расписания преподавателя
Stream<Schedule> professorScheduleStream({required bool hasSchedule}) {
  // Если расписание отсутствует, возвращаем заглушку
  if (!hasSchedule) {
    return Stream.value(const Schedule('Расписание отсутствует'));
  }
  // В реальном случае здесь был бы поток с расписанием
  return Stream.value(
    const Schedule('Понедельник: Лекции, Вторник: Практика'),
    );
}

void main() async {
  print('--- нет расписания ---');
  await for (final s in professorScheduleStream(hasSchedule: false)) {
    print(s.info);
  }

  print('');

  print('--- есть расписание ---');
  await for (final s in professorScheduleStream(hasSchedule: true)) {
    print(s.info);
  }
}
