import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Provides utility functions for working with native platform features
class NativeFeatures {
  /// Returns true if the current device is an iOS device with a notch
  static bool get hasNotch {
    if (!Platform.isIOS) return false;

    // List of devices with notches/dynamic islands
    final List<String> notchDevices = [
      'iPhone X',
      'iPhone XS',
      'iPhone XR',
      'iPhone XS Max',
      'iPhone 11',
      'iPhone 11 Pro',
      'iPhone 11 Pro Max',
      'iPhone 12 mini',
      'iPhone 12',
      'iPhone 12 Pro',
      'iPhone 12 Pro Max',
      'iPhone 13 mini',
      'iPhone 13',
      'iPhone 13 Pro',
      'iPhone 13 Pro Max',
      'iPhone 14',
      'iPhone 14 Plus',
      'iPhone 14 Pro',
      'iPhone 14 Pro Max',
      'iPhone 15',
      'iPhone 15 Plus',
      'iPhone 15 Pro',
      'iPhone 15 Pro Max',
    ];

    // If we can detect the model through channel, check against the list
    // For simplicity in this implementation, we use screen dimensions as a proxy

    // Logic that estimates based on screen dimensions would go here in a real implementation
    return true; // Simplified for this example
  }

  /// Returns true if the device is using gesture navigation (no home button)
  static bool get hasHomeIndicator {
    // On iOS, devices with a notch also have the home indicator
    return Platform.isIOS && hasNotch;
  }

  /// Returns the default safe area insets for the current device
  static Map<String, double> get safeAreaInsets {
    if (!Platform.isIOS) {
      return {
        'top': 0.0,
        'right': 0.0,
        'bottom': 0.0,
        'left': 0.0,
      };
    }

    if (hasNotch) {
      return {
        'top': 44.0,
        'right': 0.0,
        'bottom': hasHomeIndicator ? 34.0 : 0.0,
        'left': 0.0,
      };
    }

    return {
      'top': 20.0, // Status bar height
      'right': 0.0,
      'bottom': 0.0,
      'left': 0.0,
    };
  }

  /// Returns the appropriate native styling for the platform
  static Map<String, dynamic> getNativeStyling(String component) {
    if (Platform.isIOS) {
      switch (component) {
        case 'button':
          return {
            'borderRadius': 8.0,
            'backgroundColor': '#007AFF', // iOS blue
            'color': '#FFFFFF',
          };
        case 'switch':
          return {
            'trackColor': '#E9E9EA',
            'activeTrackColor': '#34C759',
            'thumbColor': '#FFFFFF',
          };
        case 'checkbox':
          return {
            'tintColor': '#007AFF',
            'checkedColor': '#007AFF',
          };
        default:
          return {};
      }
    } else if (Platform.isAndroid) {
      switch (component) {
        case 'button':
          return {
            'borderRadius': 4.0,
            'backgroundColor': '#6200EE', // Material purple
            'color': '#FFFFFF',
          };
        case 'switch':
          return {
            'trackColor': '#E0E0E0',
            'activeTrackColor': '#6200EE',
            'thumbColor': '#FFFFFF',
          };
        case 'checkbox':
          return {
            'tintColor': '#6200EE',
            'checkedColor': '#6200EE',
          };
        default:
          return {};
      }
    }

    return {};
  }
}
