enum YogaEdge {
  left('left'),
  top('top'),
  right('right'),
  bottom('bottom'),
  start('start'),
  end('end'),
  horizontal('horizontal'),
  vertical('vertical'),
  all('all');

  final String value;
  const YogaEdge(this.value);
}

enum YogaAlign {
  auto('auto'),
  flexStart('flex-start'),
  center('center'),
  flexEnd('flex-end'),
  stretch('stretch'),
  baseline('baseline'),
  spaceBetween('space-between'),
  spaceAround('space-around');

  final String value;
  const YogaAlign(this.value);
}

enum YogaJustify {
  flexStart('flex-start'),
  center('center'),
  flexEnd('flex-end'),  
  spaceBetween('space-between'),
  spaceAround('space-around'),
  spaceEvenly('space-evenly');

  final String value;
  const YogaJustify(this.value);
}

enum YogaFlexDirection {
  row('row'),
  rowReverse('row-reverse'),
  column('column'),
  columnReverse('column-reverse');

  final String value;
  const YogaFlexDirection(this.value);
}

enum YogaWrap {
  noWrap('nowrap'),
  wrap('wrap'),
  wrapReverse('wrap-reverse');

  final String value;
  const YogaWrap(this.value);
}

class YogaValue {
  final double value;
  final YogaUnit unit;

  const YogaValue(this.value, this.unit);
  
  Map<String, dynamic> toMap() => {
    'value': value,
    'unit': unit.value,
  };
}

enum YogaUnit {
  point('point'),
  percent('percent'),
  auto('auto');

  final String value;
  const YogaUnit(this.value);
}


enum YogaDirection {
  inherit('inherit'),
  ltr('ltr'),
  rtl('rtl');

  final String value;
  const YogaDirection(this.value);
}
