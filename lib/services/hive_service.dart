import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:solo_test/models/game_history.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1))
      Hive.registerAdapter(GameHistoryAdapter());
    await Hive.openBox<GameHistory>('game_history_box');
  }

  Box<GameHistory> get box => Hive.box<GameHistory>('game_history_box');
}
