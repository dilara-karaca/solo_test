class Piece {
  final int row;
  final int column;
  bool isPeg;
  bool isSelected;
  final int?
  fruitVariant; // 0-4 for fruits theme (apple, banana, blueberry, kiwi, strawberry)

  Piece({
    required this.row,
    required this.column,
    this.isPeg = true,
    this.isSelected = false,
    this.fruitVariant,
  });

  Piece copyWith({
    int? row,
    int? column,
    bool? isPeg,
    bool? isSelected,
    int? fruitVariant,
  }) {
    return Piece(
      row: row ?? this.row,
      column: column ?? this.column,
      isPeg: isPeg ?? this.isPeg,
      isSelected: isSelected ?? this.isSelected,
      fruitVariant: fruitVariant ?? this.fruitVariant,
    );
  }

  @override
  String toString() => 'Piece(row: $row, column: $column, isPeg: $isPeg)';
}
