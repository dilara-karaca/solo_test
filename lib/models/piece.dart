class Piece {
  final int row;
  final int column;
  bool isPeg;
  bool isSelected;
  final int? pieceVariant; // theme-specific image variant index

  Piece({
    required this.row,
    required this.column,
    this.isPeg = true,
    this.isSelected = false,
    this.pieceVariant,
  });

  Piece copyWith({
    int? row,
    int? column,
    bool? isPeg,
    bool? isSelected,
    int? pieceVariant,
  }) {
    return Piece(
      row: row ?? this.row,
      column: column ?? this.column,
      isPeg: isPeg ?? this.isPeg,
      isSelected: isSelected ?? this.isSelected,
      pieceVariant: pieceVariant ?? this.pieceVariant,
    );
  }

  @override
  String toString() => 'Piece(row: $row, column: $column, isPeg: $isPeg)';
}
