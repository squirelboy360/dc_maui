import 'package:flutter/material.dart';
import 'bridge/core.dart';

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

  String? _id;
  String? get id => _id; // Make it clear this can be null

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

  // Create component and return its ID
  Future<String?> create() async {
    _id = await createComponent();

    // Create all children and attach them
    for (var child in children) {
      final childId = await child.create();
      if (_id != null && childId != null) {
        await Core.attachView(_id!, childId);
      }
    }

    return _id;
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
