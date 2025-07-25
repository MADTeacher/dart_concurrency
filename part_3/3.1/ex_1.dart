import 'dart:async';
import 'dart:isolate';

void main() {
  print(Zone.root);
  print(Zone.current);
  print(Zone.current.parent);
  print(Zone.current.hashCode);
  print(Isolate.current.debugName);

  print('');
  runZonedGuarded(() {
    print(Zone.current);
    print(Zone.current.parent); // у этой зоны есть родительская
    print('');
    // для изолята будет создана своя корневая зона 
    Isolate.run(() { 
      print(Zone.current);
      print(Zone.current.hashCode);
      print(Isolate.current.debugName);
    }, debugName: 'NewIsolate');
  }, (e, _) => print(e));
}