import 'package:flutter/material.dart';

enum GameTheme { classic, cat, hellokitty, cars, fruits }

class GameThemeData {
  final String id;
  final String name;
  final String emoji;
  final String description;

  // Background
  final Color backgroundColor;
  final Color backgroundGlow1;
  final Color backgroundGlow2;

  // Board
  final Color boardBackground;
  final Color boardBorder;
  final Color boardHole;
  final Color boardEmpty;

  // Pieces
  final Color piecePrimary;
  final Color pieceDark;
  final Color pieceHighlight;
  final Color pieceSelected;

  // Asset-based piece
  final String? pieceAsset; // path to image asset, null = use gradient ball
  final String pieceEmoji; // fallback emoji
  final List<String> particles; // floating particles
  final bool useAssetPiece;

  // UI
  final Color primaryColor;
  final Color primaryDark;
  final Color primaryLight;
  final Color accentColor;
  final Color surfaceColor;
  final Color surfaceLight;
  final Color borderLight;
  final Color borderGlow;
  final Color validMoveColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color glassColor;
  final Color glassBorder;

  const GameThemeData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.backgroundColor,
    required this.backgroundGlow1,
    required this.backgroundGlow2,
    required this.boardBackground,
    required this.boardBorder,
    required this.boardHole,
    required this.boardEmpty,
    required this.piecePrimary,
    required this.pieceDark,
    required this.pieceHighlight,
    required this.pieceSelected,
    this.pieceAsset,
    required this.pieceEmoji,
    required this.particles,
    required this.useAssetPiece,
    required this.primaryColor,
    required this.primaryDark,
    required this.primaryLight,
    required this.accentColor,
    required this.surfaceColor,
    required this.surfaceLight,
    required this.borderLight,
    required this.borderGlow,
    required this.validMoveColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.glassColor,
    required this.glassBorder,
  });
}

const classicTheme = GameThemeData(
  id: 'classic',
  name: 'KLASİK',
  emoji: '♟️',
  description: 'Derin uzay — koyu mor',
  pieceAsset: null,
  pieceEmoji: '🟣',
  particles: ['✨', '💫', '⭐', '🌟'],
  useAssetPiece: false,
  backgroundColor: Color(0xFF070712),
  backgroundGlow1: Color(0xFF7C3AED),
  backgroundGlow2: Color(0xFF06B6D4),
  boardBackground: Color(0xFF0C0A28),
  boardBorder: Color(0xFF2D1F5E),
  boardHole: Color(0xFF06041A),
  boardEmpty: Color(0xFF04030F),
  piecePrimary: Color(0xFF7C3AED),
  pieceDark: Color(0xFF5B21B6),
  pieceHighlight: Color(0xFFA78BFA),
  pieceSelected: Color(0xFF06B6D4),
  primaryColor: Color(0xFF7C3AED),
  primaryDark: Color(0xFF5B21B6),
  primaryLight: Color(0xFFA78BFA),
  accentColor: Color(0xFF06B6D4),
  surfaceColor: Color(0xFF0F0F23),
  surfaceLight: Color(0xFF1A1A35),
  borderLight: Color(0xFF1E2040),
  borderGlow: Color(0x557C3AED),
  validMoveColor: Color(0xFF10B981),
  textPrimary: Color(0xFFE2E8F0),
  textSecondary: Color(0xFF94A3B8),
  glassColor: Color(0x12FFFFFF),
  glassBorder: Color(0x20FFFFFF),
);

const hellokittyTheme = GameThemeData(
  id: 'hellokitty',
  name: 'HELLO KİTTY',
  emoji: '🎀',
  description: 'Toz pembe — kawaii dünya',
  pieceAsset: 'assets/images/hellokitty/kitty.png',
  pieceEmoji: '🐱',
  particles: ['🎀', '💕', '🌸', '⭐', '🍭', '💗'],
  useAssetPiece: true,
  backgroundColor: Color(0xFFFDF0F5),
  backgroundGlow1: Color(0xFFFFB7D5),
  backgroundGlow2: Color(0xFFFF80AB),
  boardBackground: Color(0xFFFFF0F6),
  boardBorder: Color(0xFFFFB7D5),
  boardHole: Color(0xFFFCE4EC),
  boardEmpty: Color(0x00000000),
  piecePrimary: Color(0xFFE91E8C),
  pieceDark: Color(0xFFC2185B),
  pieceHighlight: Color(0xFFF48FB1),
  pieceSelected: Color(0xFFFF4081),
  primaryColor: Color(0xFFE91E8C),
  primaryDark: Color(0xFFC2185B),
  primaryLight: Color(0xFFF48FB1),
  accentColor: Color(0xFFFF80AB),
  surfaceColor: Color(0xFFFFF0F6),
  surfaceLight: Color(0xFFFFE4F0),
  borderLight: Color(0xFFFFB7D5),
  borderGlow: Color(0x55E91E8C),
  validMoveColor: Color(0xFFFF4081),
  textPrimary: Color(0xFF880E4F),
  textSecondary: Color(0xFFAD1457),
  glassColor: Color(0x18E91E8C),
  glassBorder: Color(0x30E91E8C),
);

const carsTheme = GameThemeData(
  id: 'cars',
  name: 'ARABALAR',
  emoji: '🏎️',
  description: 'Lightning McQueen — pist heyecanı',
  pieceAsset: 'assets/images/cars/mcqueen.png',
  pieceEmoji: '🚗',
  particles: ['🏎️', '💨', '🔥', '⚡', '🏁', '💥'],
  useAssetPiece: true,
  backgroundColor: Color(0xFF0D0503),
  backgroundGlow1: Color(0xFFD32F2F),
  backgroundGlow2: Color(0xFFFF6F00),
  boardBackground: Color(0xFF1A0800),
  boardBorder: Color(0xFF5D1A00),
  boardHole: Color(0xFF0D0500),
  boardEmpty: Color(0xFF080300),
  piecePrimary: Color(0xFFD32F2F),
  pieceDark: Color(0xFFB71C1C),
  pieceHighlight: Color(0xFFFF5252),
  pieceSelected: Color(0xFFFF6F00),
  primaryColor: Color(0xFFD32F2F),
  primaryDark: Color(0xFFB71C1C),
  primaryLight: Color(0xFFFF5252),
  accentColor: Color(0xFFFF6F00),
  surfaceColor: Color(0xFF180600),
  surfaceLight: Color(0xFF241000),
  borderLight: Color(0xFF3D1500),
  borderGlow: Color(0x55D32F2F),
  validMoveColor: Color(0xFFFFC107),
  textPrimary: Color(0xFFFFF8F0),
  textSecondary: Color(0xFFFFAB91),
  glassColor: Color(0x15FF5252),
  glassBorder: Color(0x25FF5252),
);

const fruitsTheme = GameThemeData(
  id: 'fruits',
  name: 'MEYVELER',
  emoji: '🍎',
  description: 'Renkli meyve sepeti — taze ve canlı',
  pieceAsset: null,
  pieceEmoji: '🍎',
  particles: ['🍎', '🍌', '🫐', '🥝', '🍓', '🌱', '✨'],
  useAssetPiece: false,
  backgroundColor: Color(0xFFF8F8F0),
  backgroundGlow1: Color(0xFFFF6B6B),
  backgroundGlow2: Color(0xFFFFD93D),
  boardBackground: Color(0xFFFBFBF5),
  boardBorder: Color(0xFFE8D5C4),
  boardHole: Color(0xFFF0EDEA),
  boardEmpty: Color(0x00000000),
  piecePrimary: Color(0xFFFF6B6B),
  pieceDark: Color(0xFFE53935),
  pieceHighlight: Color(0xFFFF8A80),
  pieceSelected: Color(0xFFFFD93D),
  primaryColor: Color(0xFFFF6B6B),
  primaryDark: Color(0xFFE53935),
  primaryLight: Color(0xFFFF8A80),
  accentColor: Color(0xFFFFD93D),
  surfaceColor: Color(0xFFFBFBF5),
  surfaceLight: Color(0xFFFDFDF9),
  borderLight: Color(0xFFE8D5C4),
  borderGlow: Color(0x55FF6B6B),
  validMoveColor: Color(0xFF6BCB77),
  textPrimary: Color(0xFF2D3142),
  textSecondary: Color(0xFF4D576A),
  glassColor: Color(0x12FF6B6B),
  glassBorder: Color(0x20FF6B6B),
);

// existing themes map is defined below with the added `cat` theme

const catTheme = GameThemeData(
  id: 'cat',
  name: 'KEDİ',
  emoji: '🐈',
  description: 'Sevimli kedi taşları',
  pieceAsset: 'assets/images/cat/cat.png',
  pieceEmoji: '🐾',
  particles: ['🐾', '✨', '😺'],
  useAssetPiece: true,
  backgroundColor: Color(0xFFFFF8E1),
  backgroundGlow1: Color(0xFFFFE082),
  backgroundGlow2: Color(0xFFFFCC80),
  boardBackground: Color(0xFFFFF3DE),
  boardBorder: Color(0xFFFFE0B2),
  boardHole: Color(0xFFFFF7E6),
  boardEmpty: Color(0x00000000),
  piecePrimary: Color(0xFFFF8A65),
  pieceDark: Color(0xFFD9644A),
  pieceHighlight: Color(0xFFFFAB91),
  pieceSelected: Color(0xFFFF7043),
  primaryColor: Color(0xFFFF8A65),
  primaryDark: Color(0xFFD9644A),
  primaryLight: Color(0xFFFFCCBC),
  accentColor: Color(0xFFFFAB91),
  surfaceColor: Color(0xFFFFF3DE),
  surfaceLight: Color(0xFFFFF7EE),
  borderLight: Color(0xFFFFE0B2),
  borderGlow: Color(0x55FF8A65),
  validMoveColor: Color(0xFF81C784),
  textPrimary: Color(0xFF4E342E),
  textSecondary: Color(0xFF6D4C41),
  glassColor: Color(0x12FF8A65),
  glassBorder: Color(0x20FF8A65),
);

// All themes map in the desired display order
const Map<GameTheme, GameThemeData> allThemes = {
  GameTheme.classic: classicTheme,
  GameTheme.cat: catTheme,
  GameTheme.hellokitty: hellokittyTheme,
  GameTheme.cars: carsTheme,
  GameTheme.fruits: fruitsTheme,
};
