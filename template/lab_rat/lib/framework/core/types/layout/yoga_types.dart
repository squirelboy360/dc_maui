// YGValue type definition
class YGValue {
  final double value;
  final YGUnit unit;

  const YGValue(this.value, this.unit);

  static YGValue auto() => const YGValue(double.nan, YGUnit.auto);
  static YGValue points(double value) => YGValue(value, YGUnit.point);
  static YGValue percent(double value) => YGValue(value, YGUnit.percent);

  Map<String, dynamic> toJson() => {
        'value': value,
        'unit': unit.name,
      };
}

enum YGUnit { undefined, point, percent, auto }

enum YGFlexDirection { column, columnReverse, row, rowReverse }

enum YGJustify {
  flexStart,
  center,
  flexEnd,
  spaceBetween,
  spaceAround,
  spaceEvenly
}

enum YGAlign {
  auto,
  flexStart,
  center,
  flexEnd,
  stretch,
  baseline,
  spaceBetween,
  spaceAround
}

enum YGPositionType { static, relative, absolute }

enum YGDisplay { flex, none }

enum YGEdge { left, top, right, bottom, start, end, horizontal, vertical, all }
