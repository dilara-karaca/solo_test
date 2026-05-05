import 'package:flutter/material.dart';
import 'package:solo_test/models/piece.dart';
import 'package:solo_test/core/constants/app_colors.dart';

class ChessPiece extends StatelessWidget {
  final Piece piece;
  final bool isSelected;

  const ChessPiece({super.key, required this.piece, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final glowColor = isSelected ? AppColors.pieceSelected : AppColors.piecePrimary;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.4),
            radius: 0.85,
            colors: isSelected
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
              blurRadius: isSelected ? 18 : 10,
              spreadRadius: isSelected ? 2 : 0,
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}
