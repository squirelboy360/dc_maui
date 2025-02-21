import 'dart:io';

// Yoga Enums
enum YogaUnit {
  point('point'),
  percent('percent'),
  auto('auto');

  final String value;
  const YogaUnit(this.value);
}

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

enum YogaPosition {
  relative('relative'),
  absolute('absolute');

  final String value;
  const YogaPosition(this.value);
}

enum YogaDisplay {
  flex('flex'),
  none('none');

  final String value;
  const YogaDisplay(this.value);
}

enum YogaOverflow {
  visible('visible'),
  hidden('hidden'),
  scroll('scroll');

  final String value;
  const YogaOverflow(this.value);
}

// Yoga Value and Layout Classes
class YogaValue {
  final double value;
  final YogaUnit unit;

  const YogaValue(this.value, this.unit);
  
  Map<String, dynamic> toMap() => {
    'value': value,
    'unit': unit.value,
  };

  static YogaValue point(double value) => YogaValue(value, YogaUnit.point);
  static YogaValue percent(double value) => YogaValue(value, YogaUnit.percent);
  static YogaValue get auto => YogaValue(0, YogaUnit.auto);
  static YogaValue get zero => YogaValue(0, YogaUnit.point);
}

class YogaLayout {
  final YogaDisplay? display;
  final YogaOverflow? overflow;
  final YogaPosition? position;
  final EdgeValues? positionValues;
  final double? zIndex;
  final YogaValue? width;
  final YogaValue? height;
  final YogaValue? minWidth;
  final YogaValue? minHeight;
  final YogaValue? maxWidth;
  final YogaValue? maxHeight;
  final EdgeValues? margin;
  final EdgeValues? padding;
  final double? flex;
  final double? flexGrow;
  final double? flexShrink;
  final YogaValue? flexBasis;
  final YogaFlexDirection? flexDirection;
  final YogaWrap? flexWrap;
  final YogaAlign? alignSelf;
  final YogaAlign? alignItems;
  final YogaAlign? alignContent;
  final YogaJustify? justifyContent;
  final double? aspectRatio;

  const YogaLayout({
    this.display,
    this.overflow,
    this.position,
    this.positionValues,
    this.zIndex,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.margin,
    this.padding,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.flexDirection,
    this.flexWrap,
    this.alignSelf,
    this.alignItems,
    this.alignContent,
    this.justifyContent,
    this.aspectRatio,
  });

  Map<String, dynamic> toMap() {
    if (!Platform.isIOS) return {};
    
    return {
      if (display != null) 'display': display!.value,
      if (overflow != null) 'overflow': overflow!.value,
      if (position != null) 'position': position!.value,
      if (positionValues != null) ...positionValues!.toMap('position'),
      if (zIndex != null) 'zIndex': zIndex,
      if (width != null) 'width': width!.toMap(),
      if (height != null) 'height': height!.toMap(),
      if (minWidth != null) 'minWidth': minWidth!.toMap(),
      if (minHeight != null) 'minHeight': minHeight!.toMap(),
      if (maxWidth != null) 'maxWidth': maxWidth!.toMap(),
      if (maxHeight != null) 'maxHeight': maxHeight!.toMap(),
      if (margin != null) ...margin!.toMap('margin'),
      if (padding != null) ...padding!.toMap('padding'),
      if (flex != null) 'flex': flex,
      if (flexGrow != null) 'flexGrow': flexGrow,
      if (flexShrink != null) 'flexShrink': flexShrink,
      if (flexBasis != null) 'flexBasis': flexBasis!.toMap(),
      if (flexDirection != null) 'flexDirection': flexDirection!.value,
      if (flexWrap != null) 'flexWrap': flexWrap!.value,
      if (alignSelf != null) 'alignSelf': alignSelf!.value,
      if (alignItems != null) 'alignItems': alignItems!.value,
      if (alignContent != null) 'alignContent': alignContent!.value,
      if (justifyContent != null) 'justifyContent': justifyContent!.value,
      if (aspectRatio != null) 'aspectRatio': aspectRatio,
    };
  }
}

class EdgeValues {
  final YogaValue? left;
  final YogaValue? top;
  final YogaValue? right;
  final YogaValue? bottom;
  final YogaValue? start;
  final YogaValue? end;
  final YogaValue? horizontal;
  final YogaValue? vertical;
  final YogaValue? all;

  const EdgeValues({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.start,
    this.end,
    this.horizontal,
    this.vertical,
    this.all,
  });

  Map<String, dynamic> toMap([String? prefix]) {
    final key = prefix != null ? (String k) => '$prefix$k' : (String k) => k;
    return {
      if (left != null) key('Left'): left!.toMap(),
      if (top != null) key('Top'): top!.toMap(),
      if (right != null) key('Right'): right!.toMap(),
      if (bottom != null) key('Bottom'): bottom!.toMap(),
      if (start != null) key('Start'): start!.toMap(),
      if (end != null) key('End'): end!.toMap(),
      if (horizontal != null) key('Horizontal'): horizontal!.toMap(),
      if (vertical != null) key('Vertical'): vertical!.toMap(),
      if (all != null) key(''): all!.toMap(),
    };
  }
}