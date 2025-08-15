import 'dart:io';

import 'src/ansi_background_colors.dart';
import 'src/ansi_text_colors.dart';

/// Экспортирует перечисления и классы, связанные с цветами фона и текста ANSI,
/// делая их доступными для файлов, которые импортируют `ansi_cli_helper.dart`.
export 'src/ansi_background_colors.dart';
export 'src/ansi_text_colors.dart';

/// Утилитарный класс-синглтон для управления выводом в консоль с использованием
/// ANSI-последовательностей. Позволяет управлять курсором, цветами и положением текста.
final class AnsiCliHelper {
  // Приватный экземпляр синглтона.
  static AnsiCliHelper? _instance;
  // Флаг, отслеживающий, скрыт ли курсор.
  bool _isHideCursor = false;

  // Приватный конструктор для реализации паттерна синглтон.
  AnsiCliHelper._();

  /// Фабричный конструктор, который возвращает единственный экземпляр класса.
  factory AnsiCliHelper() {
    return _instance ??= AnsiCliHelper._();
  }

  /// Возвращает true, если курсор скрыт.
  bool get isHideCursor => _isHideCursor;

  /// Показывает курсор в консоли, если он был скрыт.
  void showCursor() {
    if (_isHideCursor) {
      stdout.write('\u001b[?25h'); // ANSI-код для показа курсора.
      _isHideCursor = false;
    }
  }

  /// Скрывает курсор в консоли, если он был видим.
  void hideCursor() {
    if (!_isHideCursor) {
      stdout.write('\u001b[?25l'); // ANSI-код для скрытия курсора.
      _isHideCursor = true;
    }
  }

  /// Очищает экран консоли и перемещает курсор в левый верхний угол (0,0).
  void clear() {
    stdout.write('\u001b[2J\u001b[0;0H'); // ANSI-код для очистки экрана.
  }

  /// Сбрасывает состояние консоли к значениям по умолчанию:
  /// белый текст, черный фон, очистка экрана и показ курсора.
  void reset() {
    setTextColor(AnsiTextColors.white);
    setBackgroundColor(AnsiBackgroundColors.black);
    clear();
    showCursor();
  }

  /// Выводит указанный [text] в консоль без перевода строки.
  void write(String text) {
    stdout.write(text);
  }

  /// Выводит указанный [text] в консоль с последующим переводом строки.
  void writeLine(String text) {
    stdout.writeln(text);
  }

  /// Устанавливает цвет текста в консоли.
  void setTextColor(AnsiTextColors color) {
    stdout.write(color.ansiText);
  }

  /// Устанавливает цвет фона в консоли.
  void setBackgroundColor(AnsiBackgroundColors color) {
    stdout.write(color.ansiText);
  }

  /// Перемещает курсор в указанные координаты [x] (столбец) и [y] (строка).
  void gotoxy(int x, int y) {
    if (x < 0 || y < 0) {
      return;
    }
    // ANSI-код для перемещения курсора.
    stdout.write('\u001b[$y;${x}H');
  }
}
