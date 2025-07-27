import 'dart:async';

void main() async {
  await runZoned(
    () async {
      throw ArgumentError('^_^');
    },
    zoneSpecification: ZoneSpecification(
      // перехватываем исключения, не обработанные в зоне
      handleUncaughtError:
          (
            Zone self,
            ZoneDelegate parent,
            Zone zone,
            Object error,
            StackTrace stackTrace,
          ) {
            try {
              // обработка просочившегося исключения, которая
              // не будет полноценно работать с синхронно 
              // сгенерированными исключениями
              print('error: $error');
            } catch (e, s) {
              // проверяем, является ли новое исключение 'e' точно 
              // тем же объектом, что и исходное исключение 'error'
              if (identical(e, error)) {
                // Если да, то передаем родительской зоне
                // исключение error с его оригинальным stackTrace.
                // По сути это означает, что при обработке не 
                // возникло нового исключения
                parent.handleUncaughtError(zone, error, stackTrace);
              } else {
                // Иначе передаем родительской зоне исключение
                // 'e' с его stackTrace. Это означает, что при
                // обработке исключения в теле блока try
                // возникло совершенно новое исключение
                parent.handleUncaughtError(zone, e, s);
              }
            }
          },
    ),
  );
  print('Завершение программы'); // не выполнится
}
