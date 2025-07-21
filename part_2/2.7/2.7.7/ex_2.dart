import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Генераторная функция используется для моделирования
// чтения большого файла или получение данных по сети.
// Она возвращает поток, который генерирует порции
// данных (chunks) в виде списка байтов (List<int>)
Stream<List<int>> createByteStream() async* {
  // Преобразуем строки в байты с помощью кодировки UTF-8
  yield utf8.encode('(ง•_•)ง \n');
  await Future.delayed(const Duration(milliseconds: 500));
  yield utf8.encode('(งಠ_ಠ)ง \n');
  await Future.delayed(const Duration(milliseconds: 500));
  yield utf8.encode('(╯°□°）╯︵ ┻━┻ \n');
}

void main() async {
  final sourceByteStream = createByteStream();

  final file = File('output.txt');
  final IOSink sink = file.openWrite();

  print('Запускаем pipe');
  // записываем данные из потока в файл
  await sourceByteStream.pipe(sink);
  print('Pipe завершил работу');

  // закрываем поток записи в файл
  await sink.close();

  // читаем данные из файла и выводим в терминал
  print('Содержимое файла:');
  print(file.readAsStringSync());
}
