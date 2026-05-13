class Piece {
  final int row;
  final int column;
  bool isPeg;
  bool isSelected;

  Piece({
    required this.row,
    required this.column,
    this.isPeg = true,
    this.isSelected = false,
  });

  Piece copyWith({int? row, int? column, bool? isPeg, bool? isSelected}) {
    return Piece(
      row: row ?? this.row,
      column: column ?? this.column,
      isPeg: isPeg ?? this.isPeg,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() => 'Piece(row: $row, column: $column, isPeg: $isPeg)';
}
