import 'dart:io';

import 'ansi_enums.dart';
export 'ansi_enums.dart';

// Синглтон для управления выводом в консоль с использованием
// ANSI-последовательностей. Позволяет управлять курсором,
// цветами и положением текста
final class AnsiCliHelper {
  // Приватный экземпляр синглтона
  static AnsiCliHelper? _instance;
  // Флаг для отслеживания скрыт курсор или нет
  bool _isHideCursor = false;

  AnsiCliHelper._(); // приватный конструктор

  // Фабричный конструктор, который возвращает
  // единственный экземпляр класса
  factory AnsiCliHelper() {
    return _instance ??= AnsiCliHelper._();
  }

  // Возвращаем true, если курсор скрыт
  bool get isHideCursor => _isHideCursor;

  // Показываем курсор в консоли, если он был скрыт
  void showCursor() {
    if (_isHideCursor) {
      stdout.write('\u001b[?25h');
      _isHideCursor = false;
    }
  }

  // Скрываем курсор в консоли, если он был видим
  void hideCursor() {
    if (!_isHideCursor) {
      stdout.write('\u001b[?25l');
      _isHideCursor = true;
    }
  }

  // Очищаем экран консоли и перемещаем курсор
  // в левый верхний угол (0,0)
  void clear() {
    stdout.write('\u001b[2J\u001b[0;0H');
  }

  // Сбрасываем состояние консоли к значениям по умолчанию:
  // белый текст, черный фон, очистка экрана и показ курсора
  void reset() {
    setTextColor(AnsiTextColors.white);
    setBackgroundColor(AnsiBackgroundColors.black);
    clear();
    showCursor();
  }

  // Выводим указанный [text] в консоль без перевода строки
  void write(String text) {
    stdout.write(text);
  }

  // Выводим указанный [text] в консоль с
  // последующим переводом строки
  void writeLine(String text) {
    stdout.writeln(text);
  }

  // Устанавливаем цвет текста в консоли
  void setTextColor(AnsiTextColors color) {
    stdout.write(color.ansiText);
  }

  // Устанавливаем цвет фона в консоли
  void setBackgroundColor(AnsiBackgroundColors color) {
    stdout.write(color.ansiText);
  }

  // Перемещаем курсор в указанные координаты [x] (столбец) и [y] (строка)
  void gotoxy(int x, int y) {
    if (x < 0 || y < 0) {
      return;
    }
    // ANSI-код для перемещения курсора
    stdout.write('\u001b[$y;${x}H');
  }
}
