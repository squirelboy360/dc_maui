import 'low_apis/navigation_apis.dart';
import 'low_apis/ui_apis.dart';

class DCMaui {
  // Singleton pattern
  static final DCMaui instance = DCMaui._internal();
  factory DCMaui() => instance;
  DCMaui._internal();

  final navigation = NavigationAPI();
  final ui = NativeUIBridge();

  // Initialize framework
  Future<void> initialize({
    NavigationType navigationType = NavigationType.stack,
    List<TabInfo>? tabs,
  }) async {
    await navigation.setupNavigation(navigationType, tabs: tabs);
  }
}
