import 'package:flutter/material.dart';
import 'package:solo_test/models/piece.dart';
import 'package:solo_test/core/constants/app_colors.dart';

class ChessPiece extends StatelessWidget {
  final Piece piece;
  final bool isSelected;
  final bool isDragging;

  const ChessPiece({
    super.key,
    required this.piece,
    this.isSelected = false,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor =
        isSelected || isDragging
            ? AppColors.pieceSelected
            : AppColors.piecePrimary;
    final scale = isDragging ? 1.18 : (isSelected ? 1.06 : 1.0);

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 0.85,
              colors:
                  isSelected || isDragging
                      ? [
                        Colors.white.withOpacity(0.9),
                        AppColors.pieceSelected,
                        const Color(0xFF0369A1),
                      ]
                      : [
                        AppColors.pieceHighlight.withOpacity(0.95),
                        AppColors.piecePrimary,
                        AppColors.primaryDark,
                      ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.65),
                blurRadius: isSelected || isDragging ? 18 : 10,
                spreadRadius: isSelected || isDragging ? 2 : 0,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
