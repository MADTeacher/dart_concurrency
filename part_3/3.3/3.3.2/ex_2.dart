import 'dart:async';

// Модели данных
class Student {
  final String id;
  final String name;
  final String group;

  Student(this.id, this.name, this.group);

  @override
  String toString() => '$name ($group)';
}

class Grade {
  final String id;
  final String studentId;
  final String subject;
  final int score;
  final DateTime timestamp;
  final String professorId;

  Grade(
    this.id,
    this.studentId,
    this.subject,
    this.score,
    this.timestamp,
    this.professorId,
  );

  @override
  String toString() => '$subject: $score баллов (выставил: $professorId)';
}

// Контекстный класс для транзакционного выставления оценок
class GradingContext {
  final String professor; // Преподаватель
  final String subject; // Предмет
  final String action; // Действие
  bool shouldRollback = false; // Флаг отката
  // список с ID выставленных оценок
  final List<String> _assignedGradeIds = [];

  GradingContext(this.professor, this.subject, this.action);

  // Помечает контекст для отката
  void markForRollback() {
    shouldRollback = true;
    print('⚠️  Контекст помечен для отката');
  }

  // Добавляет ID выставленной оценки
  void addAssignedGrade(String gradeId) {
    _assignedGradeIds.add(gradeId);
  }

  // Возвращает немодифицируемый список ID выставленных оценок
  List<String> get assignedGradeIds => List.unmodifiable(_assignedGradeIds);

  @override
  String toString() =>
      'GradingContext(professor: $professor, subject:'
      ' $subject, rollback: $shouldRollback)';
}

// Контекстный ключ для транзакционного выставления оценок
const Symbol gradingContextKey = #gradingContext;

// Сервис с транзакционной поддержкой
class TransactionalGradingService {
  // Список выставленных оценок
  final List<Grade> _grades = [];
  int _gradeIdCounter = 1;

  Future<String> assignGrade(Student student, int score) async {
    final context = Zone.current[gradingContextKey] as GradingContext;

    print('📝 ${context.action}:');
    print('   Преподаватель: ${context.professor}');
    print('   Предмет: ${context.subject}');
    print('   Студент: $student');
    print('   Оценка: $score баллов');

    final gradeId = 'G${_gradeIdCounter++}';
    final grade = Grade(
      gradeId,
      student.id,
      context.subject,
      score,
      DateTime.now(),
      context.professor,
    );

    _grades.add(grade);
    context.addAssignedGrade(gradeId); // Регистрируем в контексте
    print('✅ Оценка выставлена (ID: $gradeId)\n');
    return gradeId;
  }

  void rollbackGrades(List<String> gradeIds) {
    print('🔄 Откатываем оценки: ${gradeIds.join(', ')}');
    _grades.removeWhere((grade) => gradeIds.contains(grade.id));
    print('✅ Откат завершен');
  }

  List<Grade> getAllGrades() => List.unmodifiable(_grades);
}

// Функция для выполнения транзакционного выставления оценок
Future<T> runGradingTransaction<T>(
  GradingContext context, // Контекст транзакции
  Future<T> Function() operation, // Выполняемая операция
  TransactionalGradingService service, // Транзакционный сервис
) async {
  print('Начинаем транзакцию: ${context.action}\n');

  try {
    // запускаем операцию в создаваемой дочерней зоне
    final result = await runZoned(
      operation,
      zoneValues: {gradingContextKey: context},
    );

    // После завершения зоны проверяем флаг отката
    if (context.shouldRollback) {
      print('❌ Транзакция помечена для отката');
      service.rollbackGrades(context.assignedGradeIds);
    } else {
      print('✅ Транзакция успешно завершена');
    }

    return result;
  } catch (e) {
    print('💥 Ошибка в транзакции: $e');
    print('🔄 Автоматический откат...');
    service.rollbackGrades(context.assignedGradeIds);
    rethrow;
  }
}

void main() async {
  final service = TransactionalGradingService();
  final student1 = Student('001', 'Анна Петрова', '4313');
  final student2 = Student('002', 'Иван Сидоров', '4313');

  // Транзакция с откатом по условию
  await runGradingTransaction(
    GradingContext(
      'доц. Чернышев С.А.',
      'Информатика',
      'Экзамен по информатике',
    ),
    () async {
      final context = Zone.current[gradingContextKey] as GradingContext;

      await service.assignGrade(student1, 78);
      await service.assignGrade(student2, 45); // Низкая оценка

      // Условие для отката: если есть оценки ниже 55
      if (service.getAllGrades().any((g) => g.score < 55)) {
        context.markForRollback();
        print('📋 Обнаружена оценка ниже 55 баллов - помечаем для отката');
      }
    },
    service,
  );

  // Показываем финальное состояние
  print('Итоговый список оценок:');
  final grades = service.getAllGrades();
  if (grades.isEmpty) {
    print('Нет сохраненных оценок');
  } else {
    for (final grade in grades) {
      print('${grade.id}: $grade');
    }
  }
}
