import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'hot_reload.dart';
import 'core.dart';

final bridge = Core();

class Base {
  static late final HotReloadManager _hotReloadManager;
  static bool _isInitialized = false;

  static Future<void> startApp({required Function bindApp}) async {
    final logger = Logger('Base');
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });

    // Initialize Flutter binding
    final binding = WidgetsFlutterBinding.ensureInitialized();

    if (kDebugMode) {
      _setupDebugMode(binding);
    }

    try {
      //  if you want to ever in sometime in your app embedd a flutter view in your native view with no performance issues,
      //? call runApp and call the flutter view Api and attatch to parent view. this would allow u use flutter in your native app 
      //? 100% fast as a native flutter app
      // runApp(MaterialApp(
      //   theme: ThemeData.light(),
      //   color: Colors.indigo,
      //   home: Center(child: Text("App running")),
      // ));

      // Run actual native UI binding
      await bindApp();
      logger.info('App started successfully');

      if (kDebugMode) {
        // Print initial view hierarchy
        await _hotReloadManager.debugPrintHierarchy();
      }
    } catch (e, stack) {
      logger.severe('Failed to start app: $e');
      logger.severe('Stack trace: $stack');
    }
  }

  static void _setupDebugMode(WidgetsBinding binding) {
    if (_isInitialized) return;
    _isInitialized = true;

    _hotReloadManager = HotReloadManager();

    // Listen to reassemble events for hot reload
    binding.addObserver(
      _HotReloadObserver(
        onHotReload: () async {
          Logger('🔄 Hot reload detected');
          await _hotReloadManager.handleHotReload();
        },
        onHotRestart: () async {
          print('🔁 Hot restart detected');
          await _hotReloadManager.handleHotRestart();
        },
      ),
    );
  }

  // Public API to track views for hot reload
  static void trackViewForHotReload(
      String viewId, Map<String, dynamic> properties) {
    if (kDebugMode) {
      _hotReloadManager.trackView(viewId, properties);
    }
  }
}

class _HotReloadObserver extends WidgetsBindingObserver {
  final Future<void> Function() onHotReload;
  final Future<void> Function() onHotRestart;

  _HotReloadObserver({
    required this.onHotReload,
    required this.onHotRestart,
  });

  @override
  Future<void> didHaveMemoryPressure() async {
    await onHotRestart();
  }

  @override
  void didChangeAccessibilityFeatures() {
    onHotReload();
  }
}
