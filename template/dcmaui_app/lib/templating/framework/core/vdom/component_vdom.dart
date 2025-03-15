import 'package:dc_test/templating/framework/core/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node.dart';
import 'package:dc_test/templating/framework/core/vdom/vdom.dart';
import 'package:flutter/foundation.dart';

/// ComponentVDOM adds React-like component functionality to the VDOM renderer
class ComponentVDOM extends VDOM {
  // Map to keep track of components by their ID
  final Map<String, Component> _components = {};
  // Map to track rendered nodes for components
  final Map<String, VNode> _renderedNodes = {};
  // Map to track component nodes by view ID
  final Map<String, VNode> _viewIdToComponentNode = {};

  // Check if VNode represents a component
  bool _isComponent(VNode node) {
    return node.props['_isComponent'] == true;
  }

  // Get component instance from node
  Component? _getComponentInstance(VNode node) {
    final componentId = _getComponentId(node);
    return _components[componentId];
  }

  // Get component ID
  String _getComponentId(VNode node) {
    return node.props['_componentId'] as String;
  }

  @override
  void createView(VNode node, String viewId) {
    try {
      debugPrint(
          'ComponentVDOM: Creating view for ${node.type} with ID $viewId');
      if (_isComponent(node)) {
        debugPrint(
            'ComponentVDOM: Creating component view for ${node.props['_componentId']}');
        _createComponentView(node, viewId);
        // Store node reference for later use in deleteView
        _viewIdToComponentNode[viewId] = node;
      } else {
        debugPrint(
            'ComponentVDOM: Creating regular view with super.createView');
        super.createView(node, viewId);
      }
    } catch (e, stackTrace) {
      debugPrint('ComponentVDOM: ERROR in createView - $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _createComponentView(VNode node, String viewId) {
    try {
      final componentConstructor =
          node.props['_componentConstructor'] as Component Function();
      final componentInstance = componentConstructor();
      final componentId = viewId;

      debugPrint('ComponentVDOM: Initializing component $componentId');

      // Store the component instance
      _components[componentId] = componentInstance;

      // Update props before mounting
      final cleanProps = Map<String, dynamic>.from(node.props)
        ..remove('_isComponent')
        ..remove('_componentId')
        ..remove('_componentConstructor');

      componentInstance.props = cleanProps;

      // Set up component's update mechanism using the public callback
      componentInstance.updateCallback = () {
        // Re-render when setState is called
        _handleComponentUpdate(componentId);
      };

      // Initialize state with values from getInitialState
      componentInstance.initializeState(componentInstance.getInitialState());

      // Call lifecycle methods
      componentInstance.componentWillMount();
      componentInstance.mounted = true;

      // Render the component
      final renderedNode = componentInstance.render();
      debugPrint(
          'ComponentVDOM: Component $componentId rendered node: ${renderedNode.type}');
      _renderedNodes[componentId] = renderedNode;

      // Render to actual view - this is key!
      if (renderedNode.type != 'component') {
        // If it's a regular view node, create it directly
        debugPrint(
            'ComponentVDOM: Creating view for rendered node ${renderedNode.type}');
        super.createView(renderedNode, viewId);

        // Explicitly handle children
        final childViewIds = <String>[];
        debugPrint(
            'ComponentVDOM: Processing ${renderedNode.children.length} children of rendered node');
        for (var child in renderedNode.children) {
          final childViewId = getViewId(child);
          debugPrint(
              'ComponentVDOM: Child of $viewId -> $childViewId (${child.type})');
          createView(child, childViewId);
          childViewIds.add(childViewId);
        }

        // Set children relationship
        if (childViewIds.isNotEmpty) {
          debugPrint(
              'ComponentVDOM: Setting ${childViewIds.length} children for $viewId');
          setChildren(viewId, childViewIds);
        } else {
          debugPrint('ComponentVDOM: No children to set for $viewId');
        }
      } else {
        // Handle nested component
        debugPrint('ComponentVDOM: Creating nested component');
        createView(renderedNode, viewId);
      }

      // Call didMount callback
      componentInstance.componentDidMount();
    } catch (e, stackTrace) {
      debugPrint('ComponentVDOM: ERROR in _createComponentView - $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void updateView(VNode oldNode, VNode newNode, String viewId) {
    if (_isComponent(oldNode) && _isComponent(newNode)) {
      _updateComponentView(oldNode, newNode, viewId);
      // Update node reference for later use
      _viewIdToComponentNode[viewId] = newNode;
    } else if (!_isComponent(oldNode) && !_isComponent(newNode)) {
      super.updateView(oldNode, newNode, viewId);
    } else {
      // Component type changed, replace the entire view
      deleteView(viewId);
      createView(newNode, viewId);
    }
  }

  void _updateComponentView(VNode oldNode, VNode newNode, String viewId) {
    final component = _getComponentInstance(oldNode);
    if (component == null) {
      if (kDebugMode) {
        print('Error: Component instance not found for update');
      }
      return;
    }

    // Clean the props
    final newProps = Map<String, dynamic>.from(newNode.props)
      ..remove('_isComponent')
      ..remove('_componentId')
      ..remove('_componentConstructor');

    // Check if we should update
    if (!component.shouldComponentUpdate(newProps, component.state)) {
      return;
    }

    // Update props and trigger lifecycle
    final prevProps = Map<String, dynamic>.from(component.props);
    component.props = newProps;

    // Get previous rendered node
    final prevRenderedNode = _renderedNodes[viewId];
    if (prevRenderedNode == null) {
      if (kDebugMode) {
        print('Warning: Previous rendered node not found');
      }
      return;
    }

    // Re-render component
    final newRenderedNode = component.render();
    _renderedNodes[viewId] = newRenderedNode;

    // Update the rendered view
    super.updateView(prevRenderedNode, newRenderedNode, viewId);

    // Call lifecycle method
    if (component.mounted) {
      component.componentDidUpdate(prevProps, component.state);
    }
  }

  @override
  void deleteView(String viewId) {
    // Check if this viewId corresponds to a component
    if (_viewIdToComponentNode.containsKey(viewId)) {
      _deleteComponentView(_viewIdToComponentNode[viewId]!, viewId);
    } else {
      super.deleteView(viewId);
    }
  }

  void _deleteComponentView(VNode node, String viewId) {
    final component = _getComponentInstance(node);
    if (component != null) {
      // Call lifecycle method directly
      component.componentWillUnmount();
      component.mounted = false;

      // Remove component
      _components.remove(_getComponentId(node));

      // Get the rendered node
      final renderedNode = _renderedNodes.remove(viewId);
      if (renderedNode != null) {
        super.deleteView(viewId);
      }

      // Clean up the reference
      _viewIdToComponentNode.remove(viewId);
    } else {
      super.deleteView(viewId);
    }
  }

  // Handle component update when setState is called
  void _handleComponentUpdate(String componentId) {
    final component = _components[componentId];
    if (component == null || !component.mounted) return;

    // Get previous rendered node
    final prevRenderedNode = _renderedNodes[componentId];
    if (prevRenderedNode == null) return;

    // Render the updated component
    final newRenderedNode = component.render();
    _renderedNodes[componentId] = newRenderedNode;

    // Update the view by diffing
    super.updateView(prevRenderedNode, newRenderedNode, componentId);
  }
}
