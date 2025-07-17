import 'dart:async';

typedef ArchiveCallback = void Function(Score score);

class Score {
  final String studentId;
  final String subject;
  final int value;

  Score(this.studentId, this.subject, this.value);

  @override
  String toString() =>
      'Score(studentId: $studentId, subject: $subject,'
      'value: $value)';
}

Stream<Score> duplicateAlerts(Stream<Score> scores, [ArchiveCallback? archive]) {
  return Stream.eventTransformed(scores, (sink) => _DupSink(sink, archive));
}

class _DupSink implements EventSink<Score> {
  // callback-функция для записи в журнал
  final ArchiveCallback? _toArchive;
  final EventSink<Score> _sink;
  _DupSink(this._sink, this._toArchive);

  @override
  void add(Score score) {
    if (score.value < 55 || score.value > 100) {
      _sink.addError(
        'Invalid score (studentId: ${score.studentId}, '
        'subject: ${score.subject}, value: ${score.value})',
      );
    } else {
      _sink.add(score); // рассылка всем
      if (_toArchive != null) {
        _toArchive(score); // запись в журнал
      }
    }
  }

  @override
  void addError(Object e, [StackTrace? st]) => _sink.addError(e, st);

  @override
  void close() => _sink.close();
}

void main() {
  final src = Stream.fromIterable([
    Score('stu1', 'math', 95),
    Score('stu2', 'physics', 88),
    Score('stu3', 'chemistry', 35),
    Score('stu4', 'biology', 55),
    Score('stu5', 'chemistry', 101),
  ]);

  duplicateAlerts(src, (score) {
    print('Archived: $score');
  }).listen(
    (ok) => print('✓ $ok'),
    onError: (e) => print('⚠ $e'),
    onDone: () => print('done'),
  );
}
