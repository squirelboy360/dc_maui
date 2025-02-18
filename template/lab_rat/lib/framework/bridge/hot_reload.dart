import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:convert';
import 'core.dart';

class ViewState {
  final String viewId;
  final Map<String, dynamic> properties;
  final List<String> children;
  final String? parentId;
  final int hashCode;

  ViewState({
    required this.viewId,
    required this.properties,
    this.children = const [],
    this.parentId,
  }) : hashCode = _computeStateHash(properties, children);

  static int _computeStateHash(Map<String, dynamic> props, List<String> children) {
    final stateStr = jsonEncode({
      'props': props,
      'children': children,
    });
    return stateStr.hashCode;
  }

  bool hasChanged(ViewState other) {
    return hashCode != other.hashCode;
  }
}

class HotReloadManager {
  final _logger = Logger('HotReloadManager');
  final Core _core = Core();
  
  // Track complete view hierarchy
  final Map<String, ViewState> _viewStates = {};
  String? _rootViewId;

  Future<void> trackView(String viewId, Map<String, dynamic> properties) async {
    try {
      // Get current state including children
      final children = await _core.getChildren(viewId) ?? [];
      final parentId = await _findParentId(viewId);

      final newState = ViewState(
        viewId: viewId,
        properties: Map.from(properties),
        children: children,
        parentId: parentId,
      );

      // Store state and print debug info
      _viewStates[viewId] = newState;
      _logger.fine('Tracking view $viewId with ${children.length} children');
      
      // Print tree after adding new view
      await debugPrintHierarchy();
    } catch (e) {
      _logger.severe('Error tracking view $viewId: $e');
    }
  }

  Future<void> handleHotReload() async {
    _logger.info('🔄 Hot reload triggered - Starting view comparison');
    
    try {
      // Get fresh root view
      final rootView = await _core.getRootView();
      if (rootView == null) {
        _logger.warning('No root view found during hot reload');
        return;
      }
      
      _rootViewId = rootView['viewId'] as String;
      _logger.info('Root view ID: $_rootViewId');

      // Print tree before changes
      _logger.info('View hierarchy before updates:');
      await debugPrintHierarchy();
      
      // Perform smart diff starting from root
      final changes = await _diffViewTreeChanges(_rootViewId!);
      
      // Apply changes in correct order
      for (final change in changes) {
        await _applyViewChange(change);
      }

      // Print final tree
      _logger.info('View hierarchy after updates:');
      await debugPrintHierarchy();
      
    } catch (e, stack) {
      _logger.severe('Error during hot reload: $e');
      _logger.severe('Stack trace: $stack');
    }
  }

  Future<List<_ViewChange>> _diffViewTreeChanges(String viewId) async {
    final changes = <_ViewChange>[];
    
    // Get current native state
    final currentView = await _core.getViewById(viewId);
    if (currentView == null) return changes;

    final currentChildren = await _core.getChildren(viewId) ?? [];
    
    // Compare with tracked state
    final trackedState = _viewStates[viewId];
    if (trackedState != null) {
      final currentState = ViewState(
        viewId: viewId,
        properties: currentView['properties'] as Map<String, dynamic>? ?? {},
        children: currentChildren,
      );

      if (currentState.hasChanged(trackedState)) {
        changes.add(_ViewChange(
          viewId: viewId,
          type: _ChangeType.update,
          properties: currentState.properties,
        ));
        _viewStates[viewId] = currentState;
      }
    }

    // Recursively check children
    for (final childId in currentChildren) {
      changes.addAll(await _diffViewTreeChanges(childId));
    }

    return changes;
  }

  Future<void> _applyViewChange(_ViewChange change) async {
    _logger.info('Applying change to view ${change.viewId}: ${change.type}');
    
    switch (change.type) {
      case _ChangeType.update:
        await _core.updateView(change.viewId, change.properties);
        break;
    }
  }

  Future<void> handleHotRestart() async {
    _logger.info('🔁 Hot restart triggered - Cleaning up view hierarchy');
    
    try {
      final rootView = await _core.getRootView();
      if (rootView == null) return;

      _logger.info('Deleting all views except root');
      
      // Delete all views except root
      final viewIds = List<String>.from(_viewStates.keys);
      for (final id in viewIds) {
        if (id != rootView['viewId']) {
          await _core.deleteView(id);
          _logger.fine('Deleted view: $id');
        }
      }
      
      _viewStates.clear();
      _logger.info('View hierarchy cleaned up');
      
    } catch (e) {
      _logger.severe('Error during hot restart: $e');
    }
  }

  // Helper method to find parent ID
  Future<String?> _findParentId(String viewId) async {
    if (viewId == _rootViewId) return null;
    
    for (final state in _viewStates.values) {
      if (state.children.contains(viewId)) {
        return state.viewId;
      }
    }
    return null;
  }

  Future<void> debugPrintHierarchy() async {
    final rootView = await _core.getRootView();
    if (rootView == null) {
      _logger.info('No view hierarchy to print');
      return;
    }
    
    _logger.info('📱 Current View Hierarchy:');
    await _printViewTree(rootView['viewId'] as String, '', true);
  }

  Future<void> _printViewTree(String viewId, String prefix, bool isLast) async {
    final children = await _core.getChildren(viewId) ?? [];
    final state = _viewStates[viewId];
    
    final stateInfo = state != null ? 
        '(${state.properties.length} props, ${state.children.length} children)' : 
        '(untracked)';
    
    _logger.info('$prefix${isLast ? '└── ' : '├── '}$viewId $stateInfo');
    
    for (var i = 0; i < children.length; i++) {
      await _printViewTree(
        children[i],
        '$prefix${isLast ? '    ' : '│   '}',
        i == children.length - 1,
      );
    }
  }
}

enum _ChangeType { update }

class _ViewChange {
  final String viewId;
  final _ChangeType type;
  final Map<String, dynamic> properties;

  _ViewChange({
    required this.viewId,
    required this.type,
    required this.properties,
  });
}
