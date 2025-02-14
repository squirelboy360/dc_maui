import '../ui_apis.dart';

class Alert {
  static Future<String?> show({
    required String title,
    required String message,
    List<AlertAction> actions = const [],
    String style = 'alert', // or 'actionSheet'
  }) async {
    final result = await NativeUIBridge().invokeMethod('showAlert', {
      'title': title,
      'message': message,
      'actions': actions.map((a) => a.toMap()).toList(),
      'style': style,
    });
    
    return result as String?;
  }
}

class AlertAction {
  final String title;
  final String style; // 'default', 'cancel', 'destructive'
  
  const AlertAction({
    required this.title,
    this.style = 'default',
  });
  
  Map<String, String> toMap() => {
    'title': title,
    'style': style,
  };
}
