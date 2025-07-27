import 'dart:async';

final censored = '( ˇ෴ˇ )';

void main() async {
  await runZoned(
      () async {
        await Future.delayed(
          Duration(milliseconds: 300),
          () {
            print('Hello Zone: ${Zone.current}');
            print('qwerty'); // выводим пароль в терминал
          },
        );
      },
      zoneValues: {#_secret: 'qwerty'}, // тип ключа - symbol
      zoneSpecification: ZoneSpecification(print: (
        Zone self,
        ZoneDelegate parent,
        Zone zone,
        String line,
      ) {
        if (line.contains(Zone.current[#_secret] as String)) {
          line = censored;
        }
        parent.print(zone, '${DateTime.now()} $line');
      }));

  print(Zone.current[#_secret]);
}
