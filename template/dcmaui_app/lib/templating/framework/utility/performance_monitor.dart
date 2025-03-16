import 'dart:collection';
import 'package:flutter/foundation.dart';

/// PerformanceMonitor provides global performance tracking for the DC Framework
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  static PerformanceMonitor get instance => _instance;

  PerformanceMonitor._internal();

  // Store render durations
  final _renderTimes = ListQueue<_RenderRecord>(100); // Keep last 100 records
  final _slowRenders = <_RenderRecord>[];

  // Store diff durations
  final _diffTimes = ListQueue<_DiffRecord>(100);
  final _slowDiffs = <_DiffRecord>[];

  // Memory usage tracking
  final _memorySnapshots = ListQueue<_MemoryRecord>(50);

  // Warning thresholds
  int renderTimeWarningThresholdMs = 16; // ~1 frame at 60fps
  int diffTimeWarningThresholdMs = 8; // Half a frame

  // Flags
  bool enableLogging = kDebugMode;
  bool collectDetailedMetrics = kDebugMode;
  bool _trackingEnabled = true;

  /// Enable or disable performance tracking
  set trackingEnabled(bool value) => _trackingEnabled = value;
  bool get trackingEnabled => _trackingEnabled;

  /// Track a component render operation
  void trackRender(
      String componentId, String componentType, int durationMicros) {
    if (!_trackingEnabled) return;

    final durationMs = durationMicros / 1000.0;
    final record = _RenderRecord(
      timestamp: DateTime.now(),
      componentId: componentId,
      componentType: componentType,
      durationMs: durationMs,
    );

    _renderTimes.add(record);
    if (_renderTimes.length > 100) _renderTimes.removeFirst();

    if (durationMs > renderTimeWarningThresholdMs) {
      _slowRenders.add(record);

      if (enableLogging) {
        debugPrint(
            '⚠️ SLOW RENDER: $componentType took ${durationMs.toStringAsFixed(2)}ms '
            '(threshold: ${renderTimeWarningThresholdMs}ms)');
      }
    }
  }

  /// Track a VDOM diffing operation
  void trackDiff(String nodeKey, int nodeCount, int durationMicros) {
    if (!_trackingEnabled) return;

    final durationMs = durationMicros / 1000.0;
    final record = _DiffRecord(
      timestamp: DateTime.now(),
      nodeKey: nodeKey,
      nodeCount: nodeCount,
      durationMs: durationMs,
    );

    _diffTimes.add(record);
    if (_diffTimes.length > 100) _diffTimes.removeFirst();

    if (durationMs > diffTimeWarningThresholdMs) {
      _slowDiffs.add(record);

      if (enableLogging) {
        debugPrint(
            '⚠️ SLOW DIFF: $nodeKey with $nodeCount nodes took ${durationMs.toStringAsFixed(2)}ms '
            '(threshold: ${diffTimeWarningThresholdMs}ms)');
      }
    }
  }

  /// Take a memory snapshot
  void takeMemorySnapshot([String? label]) {
    if (!_trackingEnabled || !collectDetailedMetrics) return;

    // On web or in release mode, we can't get detailed memory info
    _memorySnapshots.add(_MemoryRecord(
      timestamp: DateTime.now(),
      label: label ?? 'snapshot_${_memorySnapshots.length}',
    ));

    if (_memorySnapshots.length > 50) _memorySnapshots.removeFirst();
  }

  /// Get performance report
  Map<String, dynamic> getPerformanceReport() {
    final now = DateTime.now();

    // Calculate averages
    double avgRenderTime = 0;
    if (_renderTimes.isNotEmpty) {
      avgRenderTime =
          _renderTimes.fold(0.0, (sum, record) => sum + record.durationMs) /
              _renderTimes.length;
    }

    double avgDiffTime = 0;
    if (_diffTimes.isNotEmpty) {
      avgDiffTime =
          _diffTimes.fold(0.0, (sum, record) => sum + record.durationMs) /
              _diffTimes.length;
    }

    return {
      'timestamp': now.toString(),
      'renders': {
        'count': _renderTimes.length,
        'averageMs': avgRenderTime,
        'slowCount': _slowRenders.length,
        'slowest': _slowRenders.isEmpty
            ? null
            : {
                'componentType': _slowRenders
                    .reduce((a, b) => a.durationMs > b.durationMs ? a : b)
                    .componentType,
                'durationMs': _slowRenders
                    .reduce((a, b) => a.durationMs > b.durationMs ? a : b)
                    .durationMs,
              },
        'recent': _renderTimes.isEmpty
            ? []
            : _renderTimes
                .toList()
                .sublist(_renderTimes.length > 5 ? _renderTimes.length - 5 : 0)
                .map((r) => {
                      'componentType': r.componentType,
                      'durationMs': r.durationMs,
                      'timestamp': r.timestamp.toString()
                    })
                .toList(),
      },
      'diffs': {
        'count': _diffTimes.length,
        'averageMs': avgDiffTime,
        'slowCount': _slowDiffs.length,
      },
      'memorySnapshots': _memorySnapshots
          .map((snapshot) => {
                'timestamp': snapshot.timestamp.toString(),
                'label': snapshot.label,
              })
          .toList(),
    };
  }

  /// Reset collected metrics
  void reset() {
    _renderTimes.clear();
    _slowRenders.clear();
    _diffTimes.clear();
    _slowDiffs.clear();
    _memorySnapshots.clear();
  }
}

// Helper classes for data storage

class _RenderRecord {
  final DateTime timestamp;
  final String componentId;
  final String componentType;
  final double durationMs;

  _RenderRecord({
    required this.timestamp,
    required this.componentId,
    required this.componentType,
    required this.durationMs,
  });
}

class _DiffRecord {
  final DateTime timestamp;
  final String nodeKey;
  final int nodeCount;
  final double durationMs;

  _DiffRecord({
    required this.timestamp,
    required this.nodeKey,
    required this.nodeCount,
    required this.durationMs,
  });
}

class _MemoryRecord {
  final DateTime timestamp;
  final String label;

  _MemoryRecord({
    required this.timestamp,
    required this.label,
  });
}
