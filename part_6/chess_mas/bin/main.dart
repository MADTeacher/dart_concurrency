import 'package:chess_mas/chess_mas.dart';

void main(List<String> arguments) async {
  var console = CLIConsole(
    notationParser: FenNotationParser(),
  );
  await console.run();
}
