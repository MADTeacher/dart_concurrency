import 'dart:async';

class Group {
  final String name;
  final int medianScore;

  Group(this.name, this.medianScore);

  @override
  String toString() => 'Group($name, $medianScore)';
}

/// Трансформер: medianScore ∈ 0‒100, иначе error
Stream<Group> validateExamScores(Stream<Group> groups) =>
    Stream.eventTransformed(groups, (sink) => _GroupScoreValidator(sink));

class _GroupScoreValidator implements EventSink<Group> {
  final EventSink<Group> _out;
  _GroupScoreValidator(this._out);

  @override
  void add(Group group) {
    // Проверяем медианную оценку в группе
    if (group.medianScore < 55 || group.medianScore > 100) {
      // если оценка выходит за допустимые пределы
      _out.addError( // отправляем ошибку в выходной поток
        ArgumentError.value(
          group.medianScore,
          'medianScore',
          'Group(${group.name})',
        ),
      );
    } else {
      _out.add(group);
    }
  }

  @override
  void addError(Object e, [StackTrace? st]) {
    _out.addError(e, st);
  }

  @override
  void close() => _out.close();
}

void main() {
  final groups = Stream.fromIterable([
    Group('4313', 95),
    Group('4314', 107),
    Group('4315', 88),
    Group('4316', 55),
    Group('4317', 50),
  ]);
  validateExamScores(groups).listen(
    (ok) => print('✓ $ok'),
    onError: (e) => print('⚠ $e'),
    onDone: () => print('done'),
  );
}
