import 'dart:async';

void main() async {
  // поток с единичной подпиской
  final single = const Stream.empty(broadcast: false);

  single.listen(
    (data) => print('✔ data: $data'),
    onDone: () => print('✔ no data, only onDone() 1'),
  );

  single.listen(
    (data) => print('✔ data: $data'),
    onDone: () => print('✔ no data, only onDone() 2'),
  );

  print('Single stream is broadcast? ${single.isBroadcast}');

  // широковещательный поток
  final broadcast = const Stream.empty();

  broadcast.listen(
    (data) => print('✔ data: $data'),
    onDone: () => print('✔ no data, only onDone() 3'),
  );

  broadcast.listen(
    (data) => print('✔ data: $data'),
    onDone: () => print('✔ no data, only onDone() 4'),
  );

  print('Broadcast stream is broadcast? ${broadcast.isBroadcast}');
}

// ✔ no data, only onDone()
