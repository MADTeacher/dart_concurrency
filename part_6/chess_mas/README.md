# Chess_MAS

Queen gambit is an app that solves "Zero pieces intersection" chess problem. It finds a position in which pieces have no intersections with each other by moving them

## Console interface

1. Run `dart run bin/main.dart`
2. Initialize board by entering posiition in FEN notation. You can generate FEN string [here](http://www.netreal.de/Forsyth-Edwards-Notation/index.php). Then enter the following command `init --notation fenString` (insert your generated FEN string instead of fenString, e.g. 7P/1N3N2/8/3QB3/3QB3/1K1NR3/5N2/8)
3. Enter `step` command to run next epoch and see updated position
4. Enter `stop` to exit
