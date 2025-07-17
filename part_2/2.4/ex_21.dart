import 'dart:async';

class Score {
  final String studentId;
  final String subject;
  final int value; // 0-100
  final bool archived;
  Score(this.studentId, this.subject, this.value, {this.archived = false});

  @override
  String toString() =>
      'Score(studentId: $studentId, subject: $subject,'
      'value: $value, archived: $archived)';
}

Stream<Score> duplicateAlerts(Stream<Score> scores) =>
    Stream.eventTransformed(scores, (sink) => _DupSink(sink));

class _DupSink implements EventSink<Score> {
  final EventSink<Score> _sink;
  _DupSink(this._sink);

  @override
  void add(Score score) {
    if (score.value < 55 || score.value > 100) {
      _sink.addError(
        'Invalid score (studentId: ${score.studentId}, '
        'subject: ${score.subject}, value: ${score.value})',
      );
    } else {
      _sink.add(score); // рассылка всем
      _sink.add(
        Score(
          score.studentId, score.subject, 
          score.value, archived: true,
        ),
      ); // запись в журнал
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
  duplicateAlerts(src).listen(
    (ok) => print('✓ $ok'),
    onError: (e) => print('⚠ $e'),
    onDone: () => print('done'),
  );
}
