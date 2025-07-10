import 'dart:async';

abstract class IDBService {
  FutureOr<String> fetch();
}

class LocalService implements IDBService {
  @override
  String fetch() => 'local data';
}

class RemoteService implements IDBService {
  @override
  Future<String> fetch() async {
    await Future.delayed(Duration(seconds: 1));
    return 'remote data';
  }
}

IDBService createService() => LocalService();

void main() async {
  final service = createService();
  final result = service.fetch();
  if (result is Future) {
    print('Result is Future: ${await result}');
  } else {
    print('Result is not Future: $result');
  }
}
