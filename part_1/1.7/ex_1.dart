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

void main() async {
  IDBService localService = LocalService();
  IDBService remoteService = RemoteService();

  print(await remoteService.fetch()); // remote data
  print(localService.fetch()); // local data
}
