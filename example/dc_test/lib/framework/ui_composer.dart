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
