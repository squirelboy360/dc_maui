import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

// Add this enum at the top of the file after imports
enum ScrollDirection { vertical, horizontal }

// Add these enums
enum FlexDirection { row, column }

enum FlexAlignment {
  start,
  center,
  end,
  spaceBetween,
  spaceAround,
  spaceEvenly
}

// Add these enums after existing enums
enum StackType {
  vertical, // VStack
  horizontal, // HStack
  depth // ZStack
}

// Add this extension near the top of the file
extension ColorExtension on Color {
  String toHexString() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}

enum ListViewStyle { list, grid }

// Add this enum after existing enums
enum ScrollAxis { vertical, horizontal, free }

// Layout system enums and types
enum LayoutType { flex, absolute, relative }

enum LayoutAlign { auto, start, center, end, stretch, baseline }

// Yoga-compatible layout enums
enum YogaAlign {
  auto,
  flexStart,
  center,
  flexEnd,
  stretch,
  baseline,
  spaceBetween,
  spaceAround
}

enum YogaFlexDirection { row, column, rowReverse, columnReverse }

enum YogaJustify {
  flexStart,
  center,
  flexEnd,
  spaceBetween,
  spaceAround,
  spaceEvenly
}

enum YogaPositionType { relative, absolute }

enum YogaDisplay { flex, none }

// Yoga-compatible layout configuration
class LayoutConfig {
  final String type;
  final dynamic width; // Can be double or String (for percentages)
  final dynamic height; // Can be double or String (for percentages)
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Offset? position;
  final double? flex;
  final double? flexGrow;
  final double? flexShrink;
  final double? flexBasis;
  final String? flexDirection;
  final String? justifyContent;
  final String? alignItems;
  final String? alignSelf;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;

  const LayoutConfig({
    this.type = 'flex',
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.position,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.flexDirection,
    this.justifyContent,
    this.alignItems,
    this.alignSelf,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (margin != null)
          'margin': {
            'top': margin?.top,
            'right': margin?.right,
            'bottom': margin?.bottom,
            'left': margin?.left,
          },
        if (padding != null)
          'padding': {
            'top': padding?.top,
            'right': padding?.right,
            'bottom': padding?.bottom,
            'left': padding?.left,
          },
        if (position != null)
          'position': {
            'x': position?.dx,
            'y': position?.dy,
          },
        if (flex != null) 'flex': flex,
        if (flexGrow != null) 'flexGrow': flexGrow,
        if (flexShrink != null) 'flexShrink': flexShrink,
        if (flexBasis != null) 'flexBasis': flexBasis,
        if (flexDirection != null) 'flexDirection': flexDirection,
        if (justifyContent != null) 'justifyContent': justifyContent,
        if (alignItems != null) 'alignItems': alignItems,
        if (alignSelf != null) 'alignSelf': alignSelf,
        if (minWidth != null) 'minWidth': minWidth,
        if (minHeight != null) 'minHeight': minHeight,
        if (maxWidth != null) 'maxWidth': maxWidth,
        if (maxHeight != null) 'maxHeight': maxHeight,
      };
}

class NativeUIBridge {
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');
  final _logger = Logger('NativeUIBridge');

  // Add these constants
  static const double matchParent = -1.0;
  static const double wrapContent = -2.0;

  // Singleton pattern
  static final NativeUIBridge _instance = NativeUIBridge._();
  factory NativeUIBridge() => _instance;
  NativeUIBridge._() {
    _setupEventHandler();
  }

  // Callback registry
  final Map<String, Map<String, Function>> _eventCallbacks = {};

  // Event handler setup
  void _setupEventHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNativeEvent') {
        try {
          // Explicitly cast the arguments to Map<String, dynamic>
          final args = Map<String, dynamic>.from(call.arguments as Map);
          final String viewId = args['viewId'] as String;
          final String eventType = args['eventType'] as String;

          if (_eventCallbacks.containsKey(viewId) &&
              _eventCallbacks[viewId]!.containsKey(eventType)) {
            await _eventCallbacks[viewId]![eventType]!.call();
            return true;
          }
          _logger.warning('No callback found for $eventType on view $viewId');
          return false;
        } catch (e, stack) {
          _logger.severe('Error handling native event: $e');
          _logger.severe('Stack trace: $stack');
          throw FlutterError('Failed to process native event: $e');
        }
      }
      return null;
    });
  }

  // View Management Methods

  /// Creates a new native view
  /// Native expects:
  /// - viewType: String (e.g. 'Button', 'TextView', 'LinearLayout')
  /// - properties: {
  ///     text?: String,
  ///     textSize?: double,
  ///     backgroundColor?: String (hex color),
  ///     width?: int,
  ///     height?: int,
  ///     padding?: int,
  ///     margin?: int,
  ///     isEnabled?: bool
  ///   }
  /// Returns: String viewId or null if failed
  Future<String?> createView(String viewType,
      {Map<String, dynamic>? properties}) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createView', {
        'viewType': viewType,
        ...?properties,
      });
      return viewId;
    } catch (e) {
      _logger.severe('Error creating view: $e');
      return null;
    }
  }

  /// Attaches child view to parent view in native hierarchy
  /// Native expects:
  /// - parentId: String (must be existing view ID)
  /// - childId: String (must be existing view ID)
  /// Returns: bool success
  Future<bool> attachView(String parentId, String childId) async {
    try {
      final result = await _channel.invokeMethod<bool>('attachView', {
        'parentId': parentId,
        'childId': childId,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error attaching view: $e');
      return false;
    }
  }

  Future<bool> deleteView(String viewId) async {
    try {
      final result = await _channel.invokeMethod<bool>('deleteView', {
        'viewId': viewId,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error deleting view: $e');
      return false;
    }
  }

  /// Updates properties of existing native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - properties: {
  ///     text?: String,
  ///     textSize?: double,
  ///     backgroundColor?: String (hex),
  ///     width?: int,
  ///     height?: int,
  ///     isEnabled?: bool,
  ///     isVisible?: bool
  ///   }
  Future<bool> updateView(
      String viewId, Map<String, dynamic> properties) async {
    try {
      // Convert any Color objects to hex strings
      var processedProperties = Map<String, dynamic>.from(properties);
      if (properties['textColor'] is Color) {
        processedProperties['textColor'] =
            (properties['textColor'] as Color).toHexString();
      }

      final result = await _channel.invokeMethod<bool>('updateView', {
        'viewId': viewId,
        'properties': processedProperties,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error updating view: $e');
      return false;
    }
  }

  // Event Handling

  /// Registers event listener on native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - eventType: String (supported events:
  ///   'click', 'longClick', 'focus', 'blur',
  ///   'textChanged', 'scrolled')
  /// Returns: bool success
  Future<bool> registerEvent(
      String viewId, String eventType, Function callback) async {
    try {
      final result = await _channel.invokeMethod<bool>('registerEvent', {
        'viewId': viewId,
        'eventType': eventType,
      });

      if (result == true) {
        // Initialize the map for this viewId if it doesn't exist
        _eventCallbacks[viewId] ??= {};
        // Store the callback - this was missing!
        _eventCallbacks[viewId]![eventType] = callback;
        _logger.info('Successfully registered $eventType for view $viewId');
        return true;
      }
      _logger.warning('Failed to register event on native side');
      return false;
    } catch (e) {
      _logger.severe('Error registering event: $e');
      return false;
    }
  }

  Future<bool> unregisterEvent(String viewId, String eventType) async {
    try {
      final result = await _channel.invokeMethod<bool>('unregisterEvent', {
        'viewId': viewId,
        'eventType': eventType,
      });

      if (result ?? false) {
        _eventCallbacks[viewId]?.remove(eventType);
        if (_eventCallbacks[viewId]?.isEmpty ?? false) {
          _eventCallbacks.remove(viewId);
        }
        return true;
      }
      return false;
    } catch (e) {
      _logger.severe('Error unregistering event: $e');
      return false;
    }
  }

  // Styling Methods

  /// Sets background color of native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - color: String (hex format: '#RRGGBB' or '#AARRGGBB')
  Future<bool> setViewBackgroundColor(String viewId, dynamic color) async {
    try {
      String colorString;
      if (color is Color) {
        colorString = color.toHexString();
      } else if (color is String) {
        colorString = color;
      } else {
        throw ArgumentError('Color must be either a Color object or a String');
      }

      final result = await _channel.invokeMethod<bool>(
        'changeViewBackgroundColor',
        {
          'viewId': viewId,
          'color': colorString,
        },
      );
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting background color: $e');
      return false;
    }
  }

  /// Sets visibility of native view
  /// Native expects:
  /// - viewId: String (must be existing view ID)
  /// - isVisible: bool (true = View.VISIBLE, false = View.GONE)
  Future<bool> setViewVisibility(String viewId, bool isVisible) async {
    try {
      final result = await _channel.invokeMethod<bool>('setViewVisibility', {
        'viewId': viewId,
        'isVisible': isVisible,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting visibility: $e');
      return false;
    }
  }

  // Hierarchy Methods

  /// Get native view properties by ID
  /// Returns: Map with properties:
  /// {
  ///   viewType: String,
  ///   properties: Map<String, dynamic>,
  ///   children: List<String>,
  ///   parent: String?
  /// }
  Future<Map<String, dynamic>?> getViewById(String viewId) async {
    try {
      final result = await _channel.invokeMethod('getViewById', {
        'viewId': viewId,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      _logger.severe('Error getting view: $e');
      return null;
    }
  }

  Future<List<String>?> getChildren(String parentId) async {
    try {
      final result = await _channel.invokeMethod('getChildren', {
        'parentId': parentId,
      });
      return List<String>.from(result);
    } catch (e) {
      _logger.severe('Error getting children: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRootView() async {
    try {
      final result = await _channel.invokeMethod('getRootView');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      _logger.severe('Error getting root view: $e');
      return null;
    }
  }

  Future<ListViewController?> createListView({
    ListViewStyle style = ListViewStyle.list,
    int columns = 1,
    double spacing = 8.0,
    EdgeInsets padding = EdgeInsets.zero,
    bool enableRefresh = false,
    bool enablePagination = false,
  }) async {
    try {
      final viewId = await _channel.invokeMethod<String>('createListView', {
        'style': style.toString(),
        'columns': columns,
        'spacing': spacing,
        'padding': {
          'top': padding.top,
          'left': padding.left,
          'bottom': padding.bottom,
          'right': padding.right,
        },
        'enableRefresh': enableRefresh,
        'enablePagination': enablePagination,
      });

      if (viewId != null) {
        return ListViewController(this, viewId);
      }
      return null;
    } catch (e) {
      _logger.severe('Error creating list view: $e');
      return null;
    }
  }

  Future<bool> setViewLayout(
    String viewId, {
    double? width,
    double? height,
    double? flex,
    FlexDirection? direction,
    FlexAlignment? alignment,
    double? spacing,
  }) async {
    try {
      final result = await _channel.invokeMethod('setViewLayout', {
        'viewId': viewId,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (flex != null) 'flex': flex,
        if (direction != null)
          'direction': direction.toString().split('.').last,
        if (alignment != null)
          'alignment': alignment.toString().split('.').last,
        if (spacing != null) 'spacing': spacing,
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error setting view layout: $e');
      return false;
    }
  }

  Future<String?> createStackView(
    StackType type, {
    double spacing = 8.0,
    FlexAlignment? alignment,
    EdgeInsets padding = EdgeInsets.zero,
  }) async {
    try {
      _logger.info('Creating stack view of type: ${type.toString()}');
      final viewId = await _channel.invokeMethod<String>('createStackView', {
        'stackType': type.toString().split('.').last,
        'spacing': spacing,
        'alignment': alignment?.toString().split('.').last,
        'padding': {
          'top': padding.top,
          'left': padding.left,
          'bottom': padding.bottom,
          'right': padding.right,
        },
      });
      _logger.info('Stack view created with ID: $viewId');
      return viewId;
    } catch (e) {
      _logger.severe('Error creating stack view: $e');
      return null;
    }
  }

  // Helper methods for specific stack types
  Future<String?> createVStack({
    double spacing = 8.0,
    FlexAlignment? alignment,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return createStackView(
      StackType.vertical,
      spacing: spacing,
      alignment: alignment,
      padding: padding,
    );
  }

  Future<String?> createHStack({
    double spacing = 8.0,
    FlexAlignment? alignment,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return createStackView(
      StackType.horizontal,
      spacing: spacing,
      alignment: alignment,
      padding: padding,
    );
  }

  Future<String?> createZStack({
    FlexAlignment? alignment,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return createStackView(
      StackType.depth,
      spacing: 0,
      alignment: alignment,
      padding: padding,
    );
  }

  Future<double> getScreenWidth() async {
    try {
      final width = await _channel.invokeMethod<double>('getScreenWidth');
      return width ?? 0.0;
    } catch (e) {
      _logger.severe('Error getting screen width: $e');
      return 0.0;
    }
  }

  Future<double> getScreenHeight() async {
    try {
      final height = await _channel.invokeMethod<double>('getScreenHeight');
      return height ?? 0.0;
    } catch (e) {
      _logger.severe('Error getting screen height: $e');
      return 0.0;
    }
  }

  Future<Map<String, dynamic>> getDeviceMetrics() async {
    try {
      final metrics = await _channel.invokeMethod<Map>('getDeviceMetrics');
      return Map<String, dynamic>.from(metrics ?? {});
    } catch (e) {
      _logger.severe('Error getting device metrics: $e');
      return {};
    }
  }

  Future<bool> isDarkMode() async {
    try {
      final isDark = await _channel.invokeMethod<bool>('isDarkMode');
      return isDark ?? false;
    } catch (e) {
      _logger.severe('Error checking dark mode: $e');
      return false;
    }
  }

  Future<double> getStatusBarHeight() async {
    try {
      final height = await _channel.invokeMethod<double>('getStatusBarHeight');
      return height ?? 0.0;
    } catch (e) {
      _logger.severe('Error getting status bar height: $e');
      return 0.0;
    }
  }

  Future<double> getSafeAreaInsets(String edge) async {
    try {
      final inset = await _channel.invokeMethod<double>('getSafeAreaInset', {
        'edge': edge, // top, bottom, left, right
      });
      return inset ?? 0.0;
    } catch (e) {
      _logger.severe('Error getting safe area inset: $e');
      return 0.0;
    }
  }

  Future<bool> setViewToFillParent(String viewId) async {
    return setViewLayout(viewId, width: matchParent, height: matchParent);
  }

  Future<bool> setViewToFillWidth(String viewId) async {
    return setViewLayout(viewId, width: matchParent);
  }

  Future<bool> setViewToFillHeight(String viewId) async {
    return setViewLayout(viewId, height: matchParent);
  }

  // Add this helper method for direct method channel invocation
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      return result;
    } catch (e) {
      _logger.severe('Error invoking native method $method: $e');
      return null;
    }
  }

  Future<String?> createScrollView({
    ScrollAxis axis = ScrollAxis.vertical,
    EdgeInsets padding = EdgeInsets.zero,
  }) async {
    try {
      final result = await _channel.invokeMethod('createScrollView', {
        'axis': axis.toString().split('.').last,
        'padding': {
          'top': padding.top,
          'left': padding.left,
          'bottom': padding.bottom,
          'right': padding.right,
        },
      });
      return result as String?;
    } catch (e) {
      _logger.severe('Error creating scroll view: $e');
      return null;
    }
  }

  Future<bool> setScrollContent(
      String scrollViewId, String contentViewId) async {
    try {
      final result = await _channel.invokeMethod('setScrollContent', {
        'scrollViewId': scrollViewId,
        'contentViewId': contentViewId,
      });
      return result as bool? ?? false;
    } catch (e) {
      _logger.severe('Error setting scroll content: $e');
      return false;
    }
  }

  // Single unified layout method
  Future<bool> setLayout(String viewId, LayoutConfig config) async {
    try {
      final result = await _channel.invokeMethod('applyLayout', {
        'viewId': viewId,
        ...config.toJson(),
      });
      return result ?? false;
    } catch (e) {
      _logger.severe('Error applying layout: $e');
      return false;
    }
  }

  // Convenience methods
  Future<bool> centerInParent(String viewId) {
    return setLayout(
        viewId,
        const LayoutConfig(
          alignSelf: 'center',
          justifyContent: 'center',
        ));
  }

  Future<bool> fillParent(String viewId) {
    return setLayout(
        viewId,
        const LayoutConfig(
          width: '100%',
          height: '100%',
        ));
  }

  Future<bool> setAbsoluteLayout(
    String viewId, {
    double? x,
    double? y,
    double? width,
    double? height,
    EdgeInsets? margin,
  }) {
    return setLayout(
        viewId,
        LayoutConfig(
          type: 'absolute',
          position: x != null || y != null ? Offset(x ?? 0, y ?? 0) : null,
          width: width,
          height: height,
          margin: margin,
        ));
  }

  Future<bool> setFlexLayout(
    String viewId, {
    String? direction,
    String? justify,
    String? alignItems,
    double? flex,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return setLayout(
        viewId,
        LayoutConfig(
          type: 'flex',
          flexDirection: direction,
          justifyContent: justify,
          alignItems: alignItems,
          flex: flex,
          margin: margin,
          padding: padding,
        ));
  }
}

// Helper classes for type-safe view creation
class NativeView {
  final String viewId;
  final NativeUIBridge _bridge;

  NativeView(this.viewId) : _bridge = NativeUIBridge();

  Future<bool> setBackgroundColor(String color) {
    return _bridge.setViewBackgroundColor(viewId, color);
  }

  Future<bool> setVisibility(bool isVisible) {
    return _bridge.setViewVisibility(viewId, isVisible);
  }

  Future<bool> delete() {
    return _bridge.deleteView(viewId);
  }

  Future<bool> update(Map<String, dynamic> properties) {
    return _bridge.updateView(viewId, properties);
  }

  Future<bool> addEventListener(String eventType, Function callback) {
    return _bridge.registerEvent(viewId, eventType, callback);
  }

  Future<bool> removeEventListener(String eventType) {
    return _bridge.unregisterEvent(viewId, eventType);
  }

  Future<bool> setSize({double? width, double? height}) {
    return _bridge.setViewLayout(viewId, width: width, height: height);
  }

  Future<bool> setFlex(double flex) {
    return _bridge.setViewLayout(viewId, flex: flex);
  }
}

class ListViewController {
  final NativeUIBridge _bridge;
  final String viewId;
  final List<String> itemIds = [];

  ListViewController(this._bridge, this.viewId);

  Future<bool> addItem(Future<String?> Function() itemBuilder) async {
    try {
      final itemId = await itemBuilder();
      if (itemId != null) {
        itemIds.add(itemId);
        await _bridge.attachView(viewId, itemId);
        return true;
      }
      return false;
    } catch (e) {
      _bridge._logger.severe('Error adding item to list: $e');
      return false;
    }
  }

  Future<bool> removeItem(int index) async {
    if (index >= 0 && index < itemIds.length) {
      final itemId = itemIds[index];
      if (await _bridge.deleteView(itemId)) {
        itemIds.removeAt(index);
        return true;
      }
    }
    return false;
  }

  Future<void> setRefreshCallback(Future<void> Function() onRefresh) async {
    await _bridge.registerEvent(viewId, 'onRefresh', () async {
      await onRefresh();
      await _bridge.invokeMethod('endRefreshing', {'viewId': viewId});
    });
  }

  Future<void> setPaginationCallback(Future<void> Function() onLoadMore) async {
    await _bridge.registerEvent(viewId, 'onLoadMore', onLoadMore);
  }
}
