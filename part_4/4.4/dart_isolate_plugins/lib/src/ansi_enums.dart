// Перечисление, определяющее ANSI-коды для цвета фона консоли
enum AnsiBackgroundColors {
  black('\u001b[40m'),
  red('\u001b[41m'),
  green('\u001b[42m'),
  yellow('\u001b[43m'),
  blue('\u001b[44m'),
  magenta('\u001b[45m'),
  cyan('\u001b[46m'),
  white('\u001b[47m');

  // Строка, содержащая ANSI-код для установки
  // соответствующего цвета фона
  final String ansiText;

  const AnsiBackgroundColors(this.ansiText);
}

// Перечисление, определяющее ANSI-коды для цвета текста консоли
enum AnsiTextColors {
  black('\u001b[30m'),
  red('\u001b[31m'),
  green('\u001b[32m'),
  yellow('\u001b[33m'),
  blue('\u001b[34m'),
  magenta('\u001b[35m'),
  cyan('\u001b[36m'),
  white('\u001b[37m');

  // Строка, содержащая ANSI-код для установки
  // соответствующего цвета текста
  final String ansiText;

  const AnsiTextColors(this.ansiText);
}
