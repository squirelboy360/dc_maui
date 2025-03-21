import 'dart:developer' as developer;
import '../vdom/vdom_node.dart';
import '../vdom/vdom_element.dart';
import '../vdom/vdom_text.dart';
import '../vdom/vdom_component.dart';
import '../vdom/vdom_patch.dart';
import '../native_bridge/native_bridge.dart';

/// Renderer that converts VDOM nodes to native UI through a bridge
class VDomRenderer {
  final NativeBridge _bridge;

  // Mappings to track rendered nodes
  final Map<String, VDomNode> _nodeRegistry = {};
  final Map<String, String> _pathToIdMap = {};

  // View ID generation
  int _nextViewId = 0;

  VDomRenderer() : _bridge = NativeBridgeFactory.create() {
    // Initialize bridge
    _bridge.initialize();

    // Set up event handler
    _bridge.setEventHandler(_handleNativeEvent);
  }

  /// Generate a unique view ID
  String _generateViewId() {
    return 'view_${_nextViewId++}';
  }

  /// Render a node and all its children
  Future<String> renderNode(VDomNode node,
      [String? parentId, int index = 0]) async {
    if (node is VDomElement) {
      // Create the view
      final viewId = _generateViewId();
      _nodeRegistry[viewId] = node;

      await _bridge.createView(viewId, node.type, node.props);

      // Register event listeners for this view
      final eventTypes = _extractEventTypes(node.props);
      if (eventTypes.isNotEmpty) {
        await _bridge.addEventListeners(viewId, eventTypes);
      }

      // Render children
      final childIds = <String>[];
      for (var i = 0; i < node.children.length; i++) {
        final childId = await renderNode(node.children[i], viewId, i);
        childIds.add(childId);
      }

      // Set children
      if (childIds.isNotEmpty) {
        await _bridge.setChildren(viewId, childIds);
      }

      // Attach to parent if provided
      if (parentId != null) {
        await _bridge.attachView(viewId, parentId, index);
      }

      return viewId;
    } else if (node is VDomText) {
      // Create text view
      final viewId = _generateViewId();
      _nodeRegistry[viewId] = node;

      await _bridge.createView(viewId, 'Text', {'content': node.content});

      // Attach to parent if provided
      if (parentId != null) {
        await _bridge.attachView(viewId, parentId, index);
      }

      return viewId;
    } else if (node is VDomComponent) {
      // Components are rendered through their rendered nodes
      if (node.renderedNode == null) {
        throw Exception('Component has not been rendered');
      }

      return renderNode(node.renderedNode!, parentId, index);
    }

    throw UnsupportedError('Unsupported node type: ${node.runtimeType}');
  }

  /// Extract event types from props
  List<String> _extractEventTypes(Map<String, dynamic> props) {
    final eventTypes = <String>[];

    for (final key in props.keys) {
      if (key.startsWith('on') && props[key] is Function) {
        // Convert onPress to press, etc.
        final eventType = key.substring(2).toLowerCase();
        eventTypes.add(eventType);
      }
    }

    return eventTypes;
  }

  /// Handle events from native UI
  void _handleNativeEvent(
      String viewId, String eventType, Map<String, dynamic> eventData) {
    final node = _nodeRegistry[viewId];
    if (node is VDomElement) {
      final handler = node.props[
          'on${eventType.substring(0, 1).toUpperCase()}${eventType.substring(1)}'];
      if (handler is Function) {
        // Execute the event handler
        handler(eventData);
      }
    }
  }

  /// Apply VDOM patches to native UI
  Future<void> applyPatches(List<VDomPatch> patches) async {
    for (final patch in patches) {
      await _applyPatch(patch);
    }
  }

  /// Apply a single patch
  Future<void> _applyPatch(VDomPatch patch) async {
    switch (patch.type) {
      case PatchType.props:
        final viewId = _getViewIdForPath(patch.path);
        if (viewId != null) {
          await _bridge.updateView(viewId, patch.payload);

          // Update event listeners if needed
          final node = _nodeRegistry[viewId];
          if (node is VDomElement) {
            final oldEventTypes = _extractEventTypes(node.props);

            // Update our registry
            for (final key in patch.payload.keys) {
              if (patch.payload[key] == null) {
                node.props.remove(key);
              } else {
                node.props[key] = patch.payload[key];
              }
            }

            final newEventTypes = _extractEventTypes(node.props);

            // Find added and removed event types
            final addedEvents =
                newEventTypes.where((e) => !oldEventTypes.contains(e)).toList();
            final removedEvents =
                oldEventTypes.where((e) => !newEventTypes.contains(e)).toList();

            if (addedEvents.isNotEmpty) {
              await _bridge.addEventListeners(viewId, addedEvents);
            }

            if (removedEvents.isNotEmpty) {
              await _bridge.removeEventListeners(viewId, removedEvents);
            }
          }
        }
        break;

      // ... implement other patch types
      case PatchType.text:
      case PatchType.add:
      case PatchType.remove:
      case PatchType.replace:
      case PatchType.componentProps:
        developer.log('Patch type not yet implemented: ${patch.type}',
            name: 'VDomRenderer');
        break;
    }
  }

  /// Get the view ID for a path
  String? _getViewIdForPath(String path) {
    return _pathToIdMap[path];
  }
}
