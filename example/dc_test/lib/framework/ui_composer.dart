import 'package:dc_test/framework/bridge/core.dart';
import 'package:flutter/material.dart';
import 'bridge/controls/scroll_view.dart' as bridge;
import 'bridge/types/layout_layouts/yoga_types.dart';

abstract class UIComposer {
  Future<void> compose();
  Future<void> bind();

  // Public method for users to start the UI
  Future<void> start() async {
    await execute();
  }

  @protected
  Future<void> execute() async {
    try {
      await Core.initialize();
      final rootInfo = await Core.getRootView();

      if (rootInfo == null) {
        debugPrint('Failed to get root view');
        return;
      }

      await compose();
      await bind();
    } catch (e) {
      debugPrint('Error in execute: $e');
    }
  }
}

abstract class UIComponent<T> {
  Map<String, dynamic> properties = {};
  Map<String, dynamic> layout = {};
  Map<String, dynamic> style = {};
  List<UIComponent> children = [];

  // New properties to support scrollable components
  List<UIComponent> listChildren = [];
  bridge.ScrollViewStyle? scrollViewStyle;
  void Function(bridge.ScrollMetrics)? onScroll;
  VoidCallback? onScrollEnd;

  String? _id;
  String get id => _id ?? '';

  // Add children to this component
  UIComponent<T> addChild(UIComponent child) {
    children.add(child);
    return this;
  }

  // Add multiple children at once
  UIComponent<T> addChildren(List<UIComponent> children) {
    this.children.addAll(children);
    return this;
  }

  // New method to make a component scrollable
  UIComponent<T> makeScrollable({
    List<UIComponent> scrollChildren = const [],
    bridge.ScrollViewStyle style = const bridge.ScrollViewStyle(),
    void Function(bridge.ScrollMetrics)? onScroll,
    VoidCallback? onScrollEnd,
  }) {
    this.listChildren = scrollChildren;
    this.scrollViewStyle = style;
    this.onScroll = onScroll;
    this.onScrollEnd = onScrollEnd;

    // Apply scroll style to component style
    this.style = {...this.style, ...style.toMap()};

    return this;
  }

  // Create component and return its ID
  Future<String?> create() async {
    // Check if this is a scrollable component
    if (listChildren.isNotEmpty && scrollViewStyle != null) {
      _id = await _createScrollableComponent();
    } else {
      _id = await createComponent();
    }

    // Create all regular children and attach them
    for (var child in children) {
      final childId = await child.create();
      if (_id != null && childId != null) {
        await Core.attachView(_id!, childId);
      }
    }

    return _id;
  }

  // Private method to create a scrollable component
  Future<String?> _createScrollableComponent() async {
    // IMPORTANT: Create all listChildren first WITHOUT attaching them
    // We'll simply pass their IDs to the ScrollView constructor
    List<String> childIds = [];

    for (var child in listChildren) {
      // Create each child component but don't attach it
      final childId = await child.create();
      if (childId != null && childId.isNotEmpty) {
        childIds.add(childId);
      }
    }

    print("Creating ScrollView with ${childIds.length} children");

    // Create the ScrollView and pass children IDs directly to native
    // This will ensure native code handles adding children properly
    final viewId = await Core.createView(
      viewType: 'ScrollView',
      properties: {
        'style': scrollViewStyle!.toMap(),
        'layout': layout,
        'events': {
          if (onScroll != null) 'onScroll': true,
          if (onScrollEnd != null) 'onScrollEnd': true,
        },
      },
      onEvent: (type, data) {
        if (type == 'onScroll' && onScroll != null) {
          final metrics = bridge.ScrollMetrics.fromMap(data);
          onScroll!(metrics);
        } else if (type == 'onScrollEnd' && onScrollEnd != null) {
          onScrollEnd!();
        }
      },
      children: childIds, // Pass children IDs directly to native side
    );

    return viewId;
  }

  // Abstract method that subclasses must implement
  Future<String?> createComponent();
}

// UIState class that wraps StateValue for reactive state
class UIState<T> {
  final StateValue<T> _stateValue;
  T _currentValue;

  UIState(T initialValue)
      : _stateValue = StateValue<T>(initialValue),
        _currentValue = initialValue;

  T get value => _currentValue;

  set value(T newValue) {
    _currentValue = newValue;
    _stateValue.setValue(newValue);
  }

  void register(String componentId) {
    _stateValue.register(componentId);
  }

  void addListener(VoidCallback listener) {
    _stateValue.addObserver(listener);
  }
}

// Component Tree class for hierarchical composition
class ComponentTree {
  final UIComponent _root;
  final Map<String, UIComponent> _components = {};

  ComponentTree(this._root);

  Future<String?> build() async {
    return await _root.create();
  }

  void registerComponent(String key, UIComponent component) {
    _components[key] = component;
  }

  UIComponent? getComponent(String key) {
    return _components[key];
  }
}
