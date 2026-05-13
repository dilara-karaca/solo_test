class GameResult {
  final int remainingPieces;
  final int score;
  final String grade;
  final int totalMoves;
  final DateTime playedAt;
  final Duration gameDuration;

  GameResult({
    required this.remainingPieces,
    required this.score,
    required this.grade,
    required this.totalMoves,
    required this.playedAt,
    required this.gameDuration,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      remainingPieces: json['remainingPieces'] as int,
      score: json['score'] as int,
      grade: json['grade'] as String,
      totalMoves: json['totalMoves'] as int,
      playedAt: DateTime.parse(json['playedAt'] as String),
      gameDuration: Duration(seconds: json['gameDurationSeconds'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remainingPieces': remainingPieces,
      'score': score,
      'grade': grade,
      'totalMoves': totalMoves,
      'playedAt': playedAt.toIso8601String(),
      'gameDurationSeconds': gameDuration.inSeconds,
    };
  }

  @override
  String toString() =>
      'GameResult(remaining: $remainingPieces, score: $score, grade: $grade, moves: $totalMoves)';
}
