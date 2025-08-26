import 'i_notation_parser.dart';

import '../board/board.dart';
import '../data/chess_piece.dart';
import '../data/position.dart';
import '../data/vector2.dart';
import '../utils/piece_storage.dart';

class FenNotationParser implements NotationParser {

  // Разбираем FEN-строку  и создаем на ее основе объект Board
  @override
  Board parse(String fenString, PieceStorage storage) {
    int id = 1;
    List<ChessPiece> pieces = [];
    Vector2 size = Vector2(vertical: 8, horizontal: 8);

    List<String> rows = fenString.split('/').reversed.toList();
    size = Vector2(vertical: rows.length, horizontal: rowLength(rows[0]));

    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      List<ChessPiece> rowPieces =
          getChessPiecesInRow(rows[rowIndex], rowIndex + 1, storage);

      for (int i = 0; i < rowPieces.length; i++) {
        rowPieces[i] = rowPieces[i].copyWith(id: id.toString());
        id++;
      }

      pieces.addAll(rowPieces);
    }

    return Board(pieces: pieces, size: size);
  }

  // Сериализуем объект Board в строку формата FEN
  @override
  String serialize(Board board) {
    String fen = "";

    List<List<ChessPiece>> chessPiecesByRow =
        List.generate(board.size.vertical, (index) => []);

    for (var piece in board.pieces) {
      chessPiecesByRow[piece.position.position.vertical - 1].add(piece);
    }

    chessPiecesByRow = chessPiecesByRow.reversed.toList();

    for (var piecesInRow in chessPiecesByRow) {
      piecesInRow.sort(((a, b) {
        return a.position.position.horizontal.compareTo(
          b.position.position.horizontal,
        );
      }));

      int visited = 0;
      for (int pieceIndex = 0; pieceIndex < piecesInRow.length; pieceIndex++) {
        var piece = piecesInRow[pieceIndex];

        if (piece.position.position.horizontal - visited - 1 > 0) {
          fen += (piece.position.position.horizontal - visited - 1).toString();
        }

        fen += piece.name;
        visited = piece.position.position.horizontal;

        if (pieceIndex == piecesInRow.length - 1) {
          if (board.size.horizontal - visited > 0) {
            fen += (board.size.horizontal - visited).toString();
          }
        }
      }

      if (piecesInRow.isEmpty) {
        fen += board.size.horizontal.toString();
      }

      if (piecesInRow != chessPiecesByRow.last) {
        fen += "/";
      }
    }

    return fen;
  }

  // Вычисляем длину ряда на доске по его представлению в FEN
  // [row] - строка, представляющая один ряд в нотации FEN, где
  // цифры обозначают количество пустых клеток, а буквы - фигуры
  int rowLength(String row) {
    int length = 0;

    List<String> symbols = row.split('');

    int numberAccumulator = 0;

    for (String symbol in symbols) {
      int? digit = int.tryParse(symbol);

      if (digit is int) {
        numberAccumulator = numberAccumulator * 10 + digit;
      } else {
        if (numberAccumulator != 0) {
          length += numberAccumulator + 1;
          numberAccumulator = 0;
        } else {
          length++;
        }
      }
    }

    length += numberAccumulator;

    return length;
  }

  // Извлекаем шахматные фигуры из строки и 
  // возвращаем список объектов ChessPiece для данного ряда
  // [row] - строка FEN для одного ряда
  // [rowNumber] - номер ряда на доске (начиная с 1)
  // [storage] - хранилище для создания экземпляров шахматных фигур
  List<ChessPiece> getChessPiecesInRow(
      String row, int rowNumber, PieceStorage storage) {
    List<ChessPiece> pieces = [];
    int length = 0;

    List<String> symbols = row.split('');

    int numberAccumulator = 0;

    for (String symbol in symbols) {
      int? digit = int.tryParse(symbol);

      if (digit is int) {
        numberAccumulator = numberAccumulator * 10 + digit;
      } else {
        if (numberAccumulator != 0) {
          length += numberAccumulator + 1;
          numberAccumulator = 0;
        } else {
          length++;
        }

        ChessPiece piece = storage.get(symbol.toUpperCase())(
          Position(
            position: Vector2(vertical: rowNumber, horizontal: length),
          ),
        );
        pieces.add(piece);
      }
    }

    length += numberAccumulator;

    return pieces;
  }
}
