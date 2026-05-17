import 'package:flutter/material.dart';
import 'package:solo_test/models/piece.dart';
import 'package:solo_test/models/game_theme_model.dart';

class ChessPiece extends StatefulWidget {
  final Piece piece;
  final bool isSelected;
  final bool isDragging;
  final GameThemeData themeData;

  const ChessPiece({
    super.key,
    required this.piece,
    required this.themeData,
    this.isSelected = false,
    this.isDragging = false,
  });

  @override
  State<ChessPiece> createState() => _ChessPieceState();
}

class _ChessPieceState extends State<ChessPiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _rotateAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.12), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: -0.10), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -0.10, end: 0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(ChessPiece oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.themeData;
    final isActive = widget.isSelected || widget.isDragging;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final dragScale = widget.isDragging ? 1.2 : 1.0;
        return Transform.scale(
          scale: (_ctrl.isAnimating ? _scaleAnim.value : 1.0) * dragScale,
          child: Transform.rotate(
            angle: _ctrl.isAnimating ? _rotateAnim.value : 0.0,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(3),
        child:
            t.useAssetPiece && t.pieceAsset != null
                ? _AssetPiece(themeData: t, isActive: isActive)
                : widget.piece.fruitVariant != null
                ? _FruitPiece(
                  themeData: t,
                  isActive: isActive,
                  fruitVariant: widget.piece.fruitVariant!,
                )
                : _GradientPiece(themeData: t, isActive: isActive),
      ),
    );
  }
}

/// Image asset piece (Hello Kitty, McQueen)
class _AssetPiece extends StatelessWidget {
  final GameThemeData themeData;
  final bool isActive;

  const _AssetPiece({required this.themeData, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isActive
                ? themeData.pieceSelected.withOpacity(0.22)
                : themeData.piecePrimary.withOpacity(0.10),
        boxShadow: [
          BoxShadow(
            color: (isActive ? themeData.pieceSelected : themeData.piecePrimary)
                .withOpacity(isActive ? 0.75 : 0.35),
            blurRadius: isActive ? 18 : 7,
            spreadRadius: isActive ? 3 : 0,
          ),
        ],
        border:
            isActive
                ? Border.all(color: themeData.pieceSelected, width: 2.5)
                : null,
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            themeData.pieceAsset!,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

/// Classic gradient ball piece
class _GradientPiece extends StatelessWidget {
  final GameThemeData themeData;
  final bool isActive;

  const _GradientPiece({required this.themeData, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.85,
          colors:
              isActive
                  ? [
                    Colors.white.withOpacity(0.9),
                    themeData.pieceSelected,
                    themeData.pieceDark,
                  ]
                  : [
                    themeData.pieceHighlight.withOpacity(0.95),
                    themeData.piecePrimary,
                    themeData.pieceDark,
                  ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: (isActive ? themeData.pieceSelected : themeData.piecePrimary)
                .withOpacity(0.65),
            blurRadius: isActive ? 18 : 10,
            spreadRadius: isActive ? 2 : 0,
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

/// Fruit image piece (for Fruits theme)
class _FruitPiece extends StatelessWidget {
  final GameThemeData themeData;
  final bool isActive;
  final int fruitVariant; // 0-4: apple, banana, blueberry, kiwi, strawberry

  const _FruitPiece({
    required this.themeData,
    required this.isActive,
    required this.fruitVariant,
  });

  String get _fruitAsset {
    const fruits = [
      'assets/images/fruits/apple.png',
      'assets/images/fruits/banana.png',
      'assets/images/fruits/blueberry.png',
      'assets/images/fruits/kiwi.png',
      'assets/images/fruits/strawberry.png',
    ];
    return fruits[fruitVariant.clamp(0, 4)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isActive
                ? themeData.pieceSelected.withOpacity(0.22)
                : themeData.piecePrimary.withOpacity(0.10),
        boxShadow: [
          BoxShadow(
            color: (isActive ? themeData.pieceSelected : themeData.piecePrimary)
                .withOpacity(isActive ? 0.75 : 0.35),
            blurRadius: isActive ? 18 : 7,
            spreadRadius: isActive ? 3 : 0,
          ),
        ],
        border:
            isActive
                ? Border.all(color: themeData.pieceSelected, width: 2.5)
                : null,
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Image.asset(
            _fruitAsset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
