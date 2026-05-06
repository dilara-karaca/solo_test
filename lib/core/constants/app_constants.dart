class AppConstants {
  // Game Rules
  static const int BOARD_SIZE = 7; // 7x7 board for English Solitaire
  static const int INITIAL_PIECES = 32;
  static const int TARGET_PIECES = 1;

  // Game Scoring (remaining pieces -> level)
  static const Map<int, String> SCORE_GRADES = {
    1: 'BILGIN',
    2: 'ZEKI',
    3: 'KURNAZ',
    4: 'BASARILI',
    5: 'NORMAL',
    6: 'TECRUBESIZ',
    7: 'APTAL',
    8: 'GERIZEKALI',
    9: 'BEYINSIZ',
  };

  static const Map<int, int> SCORE_POINTS = {
    1: 200,
    2: 175,
    3: 150,
    4: 125,
    5: 100,
    6: 75,
    7: 50,
    8: 25,
    9: 0,
  };

  static String getGradeForRemainingPieces(int remainingPieces) {
    if (remainingPieces <= 1) return 'BILGIN';
    if (remainingPieces == 2) return 'ZEKI';
    if (remainingPieces == 3) return 'KURNAZ';
    if (remainingPieces == 4) return 'BASARILI';
    if (remainingPieces == 5) return 'NORMAL';
    if (remainingPieces == 6) return 'TECRUBESIZ';
    if (remainingPieces == 7) return 'APTAL';
    if (remainingPieces == 8) return 'GERIZEKALI';
    return 'BEYINSIZ';
  }

  static int getScoreForRemainingPieces(int remainingPieces) {
    if (remainingPieces <= 1) return 200;
    if (remainingPieces == 2) return 175;
    if (remainingPieces == 3) return 150;
    if (remainingPieces == 4) return 125;
    if (remainingPieces == 5) return 100;
    if (remainingPieces == 6) return 75;
    if (remainingPieces == 7) return 50;
    if (remainingPieces == 8) return 25;
    return 0;
  }

  static String getAvatarForRemainingPieces(int remainingPieces) {
    if (remainingPieces <= 1) return '👑';
    if (remainingPieces <= 3) return '😎';
    if (remainingPieces <= 5) return '🙂';
    if (remainingPieces == 6) return '😐';
    if (remainingPieces == 7) return '🤪';
    if (remainingPieces == 8) return '😵';
    if (remainingPieces <= 10) return '🤯';
    return '🥴';
  }

  // Piece Types
  static const int EMPTY = 0;
  static const int PEG = 1;
  static const int EMPTY_HOLE = 2;

  // Game States
  static const String STATE_HOME = 'home';
  static const String STATE_PLAYING = 'playing';
  static const String STATE_FINISHED = 'finished';

  // Animation Durations
  static const Duration SHORT_ANIMATION = Duration(milliseconds: 200);
  static const Duration MEDIUM_ANIMATION = Duration(milliseconds: 400);
  static const Duration LONG_ANIMATION = Duration(milliseconds: 800);

  // Storage Keys
  static const String PREF_BEST_SCORE = 'best_score';
  static const String PREF_GAMES_PLAYED = 'games_played';
  static const String PREF_TOTAL_SCORE = 'total_score';
  static const String PREF_BEST_GRADE = 'best_grade';
}
