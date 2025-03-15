import 'package:dc_test/templating/framework/controls/control.dart';
import 'package:dc_test/templating/framework/core/vdom/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';

/// Props for ListView control
class ListViewProps implements ControlProps {
  final bool horizontal;
  final bool? showsScrollIndicator;
  final Function(double)? onScroll;
  final Function()? onEndReached;
  final double? onEndReachedThreshold;
  final bool? bounces;
  final int? initialScrollIndex;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const ListViewProps({
    this.horizontal = false,
    this.showsScrollIndicator,
    this.onScroll,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.bounces,
    this.initialScrollIndex,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'horizontal': horizontal,
      ...additionalProps,
    };

    if (showsScrollIndicator != null) {
      map['showsScrollIndicator'] = showsScrollIndicator;
    }

    if (onScroll != null) {
      map['onScroll'] = onScroll;
    }

    if (onEndReached != null) {
      map['onEndReached'] = onEndReached;
    }

    if (onEndReachedThreshold != null) {
      map['onEndReachedThreshold'] = onEndReachedThreshold;
    }

    if (bounces != null) {
      map['bounces'] = bounces;
    }

    if (initialScrollIndex != null) {
      map['initialScrollIndex'] = initialScrollIndex;
    }

    if (testID != null) {
      map['testID'] = testID;
    }

    return map;
  }

  ListViewProps copyWith({
    bool? horizontal,
    bool? showsScrollIndicator,
    Function(double)? onScroll,
    Function()? onEndReached,
    double? onEndReachedThreshold,
    bool? bounces,
    int? initialScrollIndex,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) {
    return ListViewProps(
      horizontal: horizontal ?? this.horizontal,
      showsScrollIndicator: showsScrollIndicator ?? this.showsScrollIndicator,
      onScroll: onScroll ?? this.onScroll,
      onEndReached: onEndReached ?? this.onEndReached,
      onEndReachedThreshold:
          onEndReachedThreshold ?? this.onEndReachedThreshold,
      bounces: bounces ?? this.bounces,
      initialScrollIndex: initialScrollIndex ?? this.initialScrollIndex,
      testID: testID ?? this.testID,
      additionalProps: additionalProps ?? this.additionalProps,
    );
  }
}

/// ListView control
class ListView extends Control {
  final ListViewProps props;
  final List<Control> children;

  ListView({
    ListViewProps? props,
    required this.children,
  }) : props = props ?? const ListViewProps();

  ListView.custom({
    required this.props,
    required this.children,
  });

  @override
  VNode build() {
    return ElementFactory.createElement(
      'ListView',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Create a horizontal ListView
  static ListView horizontal({
    required List<Control> children,
    ListViewProps? props,
  }) {
    return ListView(
      props: (props ?? const ListViewProps()).copyWith(horizontal: true),
      children: children,
    );
  }
}
