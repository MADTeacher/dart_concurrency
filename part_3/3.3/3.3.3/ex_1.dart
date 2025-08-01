import 'dart:async';

const zoneName = #zoneName;

void main() {
  print('Корневая зона');
  runZoned(
    () {
      print('Дочерняя зона');
      runZoned(
        () {
          print('Вложенная дочерняя зона');
        },
        zoneSpecification: ZoneSpecification(
          print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
            final prefix = zone[zoneName] as String;
            parent.print(zone, '[$prefix] $line');
          },
        ),
        zoneValues: {zoneName: '┬─┬ノ(ಠ_ಠノ)'},
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        final prefix = zone[zoneName] as String;
        parent.print(zone, '[$prefix] $line');
      },
    ),
    zoneValues: {zoneName: '( °□°) ︵ ┻━┻'},
  );
}
