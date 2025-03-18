import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/vdom/vdom/vdom.dart';
import 'package:flutter/foundation.dart';

/// OptimizedVDOM extends VDOM with specialized algorithms for large lists and trees
class OptimizedVDOM extends VDOM {
  // Configuration
  final bool _enableWindowedDiffing;
  final int _diffWindowSize;
  final bool _enableLazyRendering;

  // Performance tracking
  int _lastDiffTime = 0;
  int _lastRenderTime = 0;
  int _diffCount = 0;
  int _mountCount = 0;

  // Store our own copy of previous tree for diffing
  VNode? _lastTreeRoot;

  // Constructor with optimizations enabled by default
  OptimizedVDOM({
    bool enableWindowedDiffing = true,
    int diffWindowSize = 20,
    bool enableLazyRendering = true,
  })  : _enableWindowedDiffing = enableWindowedDiffing,
        _diffWindowSize = diffWindowSize,
        _enableLazyRendering = enableLazyRendering;

  // Statistics for monitoring
  int get lastDiffTimeMs => _lastDiffTime ~/ 1000;
  int get lastRenderTimeMs => _lastRenderTime ~/ 1000;
  int get diffCount => _diffCount;
  int get mountCount => _mountCount;

  @override
  void render(VNode newTree) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    try {
      if (_lastTreeRoot == null) {
        debugPrint('OptimizedVDOM: First render - mounting tree');
        mount(newTree);
      } else {
        debugPrint('OptimizedVDOM: Updating previous tree with diff');
        diff(_lastTreeRoot!, newTree);
      }
      _lastTreeRoot = newTree;
      super.render(newTree); // Ensure parent tracking is maintained
    } finally {
      final endTime = DateTime.now().microsecondsSinceEpoch;
      _lastRenderTime = endTime - startTime;

      if (kDebugMode && _lastRenderTime > 16000) {
        debugPrint(
            'OptimizedVDOM: Slow render detected: ${_lastRenderTime ~/ 1000}ms');
      }
    }
  }

  // Implementation of mounting for nodes
  void mount(VNode node) {
    _mountCount++;

    // Use lazy mounting for deeply nested trees if enabled
    if (_enableLazyRendering && _shouldRenderLazily(node)) {
      _lazyMount(node);
    } else {
      // Standard mounting logic
      final viewId = getViewId(node);
      createView(node, viewId);

      // Track parent-child relationships
      final childViewIds = <String>[];
      for (var child in node.children) {
        mount(child);
        childViewIds.add(getViewId(child));
      }

      // Set children relationship
      if (childViewIds.isNotEmpty) {
        setChildren(viewId, childViewIds);
      }
    }
  }

  // Check if a node should be rendered lazily
  bool _shouldRenderLazily(VNode node) {
    // Lazy render for large lists or deeply nested trees
    if (node.children.length > 30) return true;

    // Check depth
    int depth = 0;
    VNode? current = node;
    while (current != null &&
        current.props.containsKey('_parentNode') &&
        depth < 5) {
      current = current.props['_parentNode'] as VNode?;
      depth++;
    }

    return depth > 3; // Lazy render for deeply nested content
  }

  // Mount a node lazily - only immediate children at first
  void _lazyMount(VNode node) {
    final viewId = getViewId(node);
    createView(node, viewId);

    // Track parent-child relationships
    final childViewIds = <String>[];
    final childrenToRender = node.children.length > _diffWindowSize
        ? node.children.sublist(0, _diffWindowSize) // Only render first window
        : node.children;

    for (var child in childrenToRender) {
      mount(child);
      childViewIds.add(getViewId(child));
    }

    // Schedule remaining children to render asynchronously if needed
    if (node.children.length > _diffWindowSize) {
      _scheduleRemainingChildren(node, viewId, _diffWindowSize);
    }

    // Set children relationship
    if (childViewIds.isNotEmpty) {
      setChildren(viewId, childViewIds);
    }
  }

  // Schedule remaining children to mount asynchronously in batches
  void _scheduleRemainingChildren(VNode node, String viewId, int startIndex) {
    // Don't block the main thread - use microtasks to render in chunks
    Future.microtask(() {
      final endIndex =
          (startIndex + _diffWindowSize).clamp(0, node.children.length);
      final childViewIds = <String>[];

      // First collect existing child view IDs
      for (int i = 0; i < startIndex; i++) {
        childViewIds.add(getViewId(node.children[i]));
      }

      // Mount the next batch
      for (int i = startIndex; i < endIndex; i++) {
        final child = node.children[i];
        mount(child);
        childViewIds.add(getViewId(child));
      }

      // Update the children relationship
      setChildren(viewId, childViewIds);

      // Schedule more if needed
      if (endIndex < node.children.length) {
        _scheduleRemainingChildren(node, viewId, endIndex);
      }
    });
  }

  // Diffing for nodes with enhanced performance
  void diff(VNode oldNode, VNode newNode) {
    // If node types are different, replace the entire subtree
    if (oldNode.type != newNode.type) {
      replaceView(oldNode, newNode);
      return;
    }

    // Same type, transfer the view ID
    final viewId = getViewId(oldNode);
    nodeToViewId[newNode.key] = viewId;

    // Update props if needed
    if (!_arePropsEqual(oldNode.props, newNode.props)) {
      updateView(oldNode, newNode, viewId);
    }

    // Diff children using key-based reconciliation
    diffChildren(oldNode, newNode);
  }

  // Check if props are equal - needed for optimized diff
  bool _arePropsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      // Skip function comparisons as they're not reliably comparable
      if (a[key] is Function && b[key] is Function) continue;

      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  // Replace an old view with a completely new one
  void replaceView(VNode oldNode, VNode newNode) {
    final oldViewId = getViewId(oldNode);

    // First delete the old view and all its children
    deleteView(oldViewId);

    // Then mount the new tree
    mount(newNode);
  }

  // Diffing implementation for children with windowing optimization
  void diffChildren(VNode oldNode, VNode newNode) {
    final startTime = DateTime.now().microsecondsSinceEpoch;
    _diffCount++;

    try {
      // Use optimized algorithm for large lists
      if (_enableWindowedDiffing &&
          oldNode.children.length > _diffWindowSize &&
          newNode.children.length > _diffWindowSize) {
        _windowedDiffChildren(oldNode, newNode);
      } else {
        _standardDiffChildren(oldNode, newNode);
      }
    } finally {
      final endTime = DateTime.now().microsecondsSinceEpoch;
      _lastDiffTime = endTime - startTime;

      if (kDebugMode && _lastDiffTime > 8000) {
        // 8ms = half a frame at 60fps
        debugPrint(
            'OptimizedVDOM: Slow diffing detected: ${_lastDiffTime ~/ 1000}ms');
      }
    }
  }

  // Standard implementation of child diffing
  void _standardDiffChildren(VNode oldNode, VNode newNode) {
    final oldChildren = oldNode.children;
    final newChildren = newNode.children;
    final parentViewId = getViewId(oldNode);

    // Create maps for O(1) lookups
    final oldKeyToChild = {for (var child in oldChildren) child.key: child};

    // Track which old children have been processed
    final processed = <String>{};

    // Final list of child view IDs to be set on the parent
    final finalChildViewIds = <String>[];

    // First pass: Update existing children and create new ones
    for (final newChild in newChildren) {
      final key = newChild.key;

      if (oldKeyToChild.containsKey(key)) {
        // Child exists in both old and new trees, update it
        final oldChild = oldKeyToChild[key]!;
        processed.add(key);
        diff(oldChild, newChild);
        finalChildViewIds.add(getViewId(newChild));
      } else {
        // New child, mount it
        mount(newChild);
        finalChildViewIds.add(getViewId(newChild));
      }
    }

    // Second pass: Remove children that don't exist in the new tree
    for (final oldChild in oldChildren) {
      final key = oldChild.key;
      if (!processed.contains(key)) {
        // Child was removed, delete the view
        final viewId = getViewId(oldChild);
        deleteView(viewId);
      }
    }

    // Update the parent's children
    if (finalChildViewIds.isNotEmpty) {
      setChildren(parentViewId, finalChildViewIds);
    }
  }

  // Optimized diffing for large lists using windowing technique
  void _windowedDiffChildren(VNode oldNode, VNode newNode) {
    final oldChildren = oldNode.children;
    final newChildren = newNode.children;
    final parentViewId = getViewId(oldNode);

    // Create maps for O(1) lookups
    final oldKeyToChild = {for (var child in oldChildren) child.key: child};
    final newKeyToChild = {for (var child in newChildren) child.key: child};

    // Find list of keys that need updates
    final keysToUpdate = <String>[];
    for (final newChild in newChildren) {
      final key = newChild.key;
      if (oldKeyToChild.containsKey(key)) {
        if (!_arePropsEqual(oldKeyToChild[key]!.props, newChild.props) ||
            oldKeyToChild[key]!.children.length != newChild.children.length) {
          keysToUpdate.add(key);
        }
      } else {
        // New key
        keysToUpdate.add(key);
      }
    }

    // Keys that exist in old but not in new (to be removed)
    final keysToRemove = oldKeyToChild.keys
        .where((key) => !newKeyToChild.containsKey(key))
        .toList();

    // Build the final list of child IDs
    final finalChildViewIds = <String>[];

    // Process in batches for smoother UI
    int updatedCount = 0;
    const batchSize = 10;

    // First pass - handle visible items and keys that changed
    for (final newChild in newChildren) {
      final key = newChild.key;

      if (keysToUpdate.contains(key) && updatedCount < batchSize) {
        // This is a new or modified node
        if (oldKeyToChild.containsKey(key)) {
          // Update existing
          diff(oldKeyToChild[key]!, newChild);
        } else {
          // Mount new
          mount(newChild);
        }
        updatedCount++;
      }

      finalChildViewIds.add(getViewId(newChild));
    }

    // Handle removals
    for (final key in keysToRemove) {
      deleteView(getViewId(oldKeyToChild[key]!));
    }

    // Update the parent's children
    setChildren(parentViewId, finalChildViewIds);

    // Schedule remaining updates if needed
    if (updatedCount < keysToUpdate.length) {
      _scheduleRemainingUpdates(
          oldKeyToChild, newKeyToChild, keysToUpdate.sublist(updatedCount));
    }
  }

  // Schedule remaining updates in batches
  void _scheduleRemainingUpdates(Map<String, VNode> oldKeyToChild,
      Map<String, VNode> newKeyToChild, List<String> remainingKeys) {
    Future.microtask(() {
      final batchSize = 10;
      final processBatch = remainingKeys.length > batchSize
          ? remainingKeys.sublist(0, batchSize)
          : remainingKeys;

      for (final key in processBatch) {
        final newChild = newKeyToChild[key]!;
        if (oldKeyToChild.containsKey(key)) {
          // Update existing
          diff(oldKeyToChild[key]!, newChild);
        } else {
          // Mount new
          mount(newChild);
        }
      }

      // Schedule next batch if needed
      if (remainingKeys.length > batchSize) {
        _scheduleRemainingUpdates(
            oldKeyToChild, newKeyToChild, remainingKeys.sublist(batchSize));
      }
    });
  }
}
