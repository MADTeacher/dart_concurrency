import 'package:collection/collection.dart';

import 'board_event.dart';
import '../../data/chess_piece.dart';
import '../../data/conflict.dart';
import '../../data/move.dart';
import '../../data/move_suggestion.dart';
import '../../data/position.dart';
import '../../data/vector2.dart';

class Board {
  // Список всех фигур на доске
  final List<ChessPiece> pieces;

  // Размеры доски (например, 8x8)
  final Vector2 size;

  // Создаем доску с заданным списком фигур и размером
  Board({required this.pieces, required this.size});

  // Создаем полную (глубокую) копию доски
  // Это важно для симуляции ходов без изменения исходного состояния
  Board fullCopy() {
    return Board(
      pieces: pieces.map((e) => e.fullCopy()).toList(),
      size: size.fullCopy(),
    );
  }

  // Проверяем корректность состояния доски.
  // Убеждаемся, что ни одна фигура не находится за ее пределами и
  // что на одной клетке не стоит более одной фигуры
  bool validate() {
    Set<Position> takenPositions = {};

    for (var piece in pieces) {
      var isAdded = takenPositions.add(piece.position);

      if (!isAdded || !hasPosition(piece.position)) {
        return false;
      }
    }

    return true;
  }

  // Возвращаем список всех конфликтов (атак) на доске
  List<Conflict> getConflicts() {
    List<Conflict> conflicts = [];

    for (ChessPiece piece in pieces) {
      List<Position> positions = getChessPieceAttacks(piece);

      for (var position in positions) {
        if (hasPosition(position)) {
          ChessPiece? victim = getChessPiece(position);
          if (victim != null) {
            conflicts.add(
              Conflict(source: piece, victim: victim),
            );
          }
        }
      }
    }

    return conflicts;
  }

  // Возвращаем список всех пустых клеток,
  // на которые может переместиться фигура
  List<Position> getMovablePositions(ChessPiece piece) {
    return getChessPieceMoves(piece).where((position) {
      return positionEmpty(position);
    }).toList();
  }

  // Возвращаем список всех позиций, которые атакует данная фигура
  // Здесь мы учитываем как обычные ходы, так и
  // специальные правила атаки (например, для пешек)
  List<Position> getChessPieceAttacks(ChessPiece piece) {
    List<Position> positions = [];

    for (Move move in piece.additionalAttacks) {
      Position position = piece.position.copyWith();
      if (move.isDirection) {
        while (true) {
          position = position.copyWith(
            position: position.position + move.change,
          );

          if (hasPosition(position)) {
            if (!positionEmpty(position)) {
              positions.add(position);
              break;
            }
          } else {
            break;
          }
        }
      } else {
        position = position.copyWith(
          position: position.position + move.change,
        );

        if (hasPosition(position)) {
          if (!positionEmpty(position)) {
            positions.add(position);
          }
        }
      }
    }

    return [...positions, ...getChessPieceMoves(piece)];
  }

  // Возвращаем список всех позиций, на которые 
  // может переместиться фигура, включая клетки, 
  // занятые фигурами противника
  List<Position> getChessPieceMoves(ChessPiece piece) {
    List<Position> positions = [];

    for (Move move in piece.moves) {
      Position position = piece.position.copyWith();
      if (move.isDirection) {
        while (true) {
          position = position.copyWith(
            position: position.position + move.change,
          );

          if (hasPosition(position)) {
            positions.add(position);

            if (!positionEmpty(position)) {
              break;
            }
          } else {
            break;
          }
        }
      } else {
        position = position.copyWith(
          position: position.position + move.change,
        );

        if (hasPosition(position)) {
          positions.add(position);
        }
      }
    }

    return positions;
  }

  // Применяем предложенный ход к доске
  BoardEvent apply(MoveSuggestion message) {
    ChessPiece? piece = findPieceById(message.pieceId);

    if (piece is ChessPiece && canMove(piece, message.newPosition)) {
      Position position = piece.position;
      ChessPiece? newPiece = move(piece, message.newPosition);

      if (newPiece is! ChessPiece) {
        return const BoardInactivity();
      }

      return BoardPieceMoved(
        pieceId: piece.id,
        position: position,
        newPosition: newPiece.position,
      );
    }

    return const BoardInactivity();
  }

  // Применяем событие доски, изменяя ее состояние
  // и возвращаем новое событие
  BoardEvent applyBoardEvent(BoardEvent event) {
    switch (event) {
      case BoardPieceMoved():
        ChessPiece? piece = findPieceById(event.pieceId);

        if (piece is ChessPiece && canMove(piece, event.newPosition)) {
          Position position = piece.position;
          ChessPiece? newPiece = move(piece, event.newPosition);

          if (newPiece is! ChessPiece) {
            return const BoardInactivity();
          }

          return BoardPieceMoved(
            pieceId: piece.id,
            position: position,
            newPosition: newPiece.position,
          );
        }
      case _:
        return const BoardInactivity();
    }
    return const BoardInactivity();
  }

  // Находим фигуру на доске по ее уникальному идентификатору
  ChessPiece? findPieceById(String id) {
    return pieces.firstWhereOrNull((element) => element.id == id);
  }

  // Перемещаем фигуру на новую позицию, если это возможно.
  // Метод возвращает обновленный объект фигуры 
  // или `null`, если ход невозможен
  ChessPiece? move(ChessPiece piece, Position newPosition) {
    if (canMove(piece, newPosition)) {
      final newPiece = piece.copyWith(position: newPosition);
      pieces[pieces.indexOf(piece)] = newPiece;
      return newPiece;
    }

    return null;
  }

  // Проверяем, может ли фигура совершить ход на указанную позицию
  bool canMove(ChessPiece piece, Position newPosition) {
    if (!hasPosition(newPosition)) {
      return false;
    }

    if (!positionEmpty(newPosition)) {
      return false;
    }

    List<Position> positions = getChessPieceMoves(piece);

    for (var position in positions) {
      if (hasPosition(position)) {
        if (position == newPosition) {
          return true;
        }
      }
    }

    return false;
  }

  // Проверяем, является ли указанная позиция пустой
  bool positionEmpty(Position position) {
    for (var piece in pieces) {
      if (piece.position == position) {
        return false;
      }
    }

    return true;
  }

  // Проверяем, находится ли указанная позиция в пределах доски
  bool hasPosition(Position position) {
    return position.position.vertical >= 1 &&
        position.position.vertical <= size.vertical &&
        position.position.horizontal >= 1 &&
        position.position.horizontal <= size.horizontal;
  }

  // Возвращаем фигуру, находящуюся на указанной позиции, 
  // или `null`, если клетка пуста
  ChessPiece? getChessPiece(Position position) {
    return pieces.firstWhereOrNull((element) => element.position == position);
  }
}
