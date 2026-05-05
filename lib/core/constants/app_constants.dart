class AppConstants {
  // Game Rules
  static const int BOARD_SIZE = 7; // 7x7 board for English Solitaire
  static const int INITIAL_PIECES = 32;
  static const int TARGET_PIECES = 1;

  // Game Scoring
  static const Map<int, String> SCORE_GRADES = {
    1: 'SOLO TEST',
    2: 'EXCELLENT',
    3: 'GOOD',
    4: 'AVERAGE',
    5: 'POOR',
    6: 'TERRIBLE',
    32: 'FAILED',
  };

  static const Map<int, int> SCORE_POINTS = {
    1: 10000,
    2: 8000,
    3: 6000,
    4: 4000,
    5: 2000,
    6: 1000,
    32: 0,
  };

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
