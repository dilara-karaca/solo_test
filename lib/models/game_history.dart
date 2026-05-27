import 'package:hive/hive.dart';
import 'dart:convert';

class GameHistory {
  final String gameId;
  final DateTime startedAt;
  final DateTime updatedAt;
  final String boardJson; // serialized board state as JSON
  final int moveCount;
  final int remainingPegs;
  final String gameStatus; // inProgress, won, lost
  final String? theme;

  GameHistory({
    required this.gameId,
    required this.startedAt,
    required this.updatedAt,
    required this.boardJson,
    required this.moveCount,
    required this.remainingPegs,
    required this.gameStatus,
    this.theme,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'startedAt': startedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'boardJson': boardJson,
      'moveCount': moveCount,
      'remainingPegs': remainingPegs,
      'gameStatus': gameStatus,
      'theme': theme,
    };
  }

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      gameId: json['gameId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      boardJson: json['boardJson'] as String,
      moveCount: json['moveCount'] as int,
      remainingPegs: json['remainingPegs'] as int,
      gameStatus: json['gameStatus'] as String,
      theme: json['theme'] as String?,
    );
  }
}

class GameHistoryAdapter extends TypeAdapter<GameHistory> {
  @override
  final int typeId = 1;

  @override
  GameHistory read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(jsonDecode(reader.readString()));
    return GameHistory.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, GameHistory obj) {
    writer.writeString(jsonEncode(obj.toJson()));
  }
}
