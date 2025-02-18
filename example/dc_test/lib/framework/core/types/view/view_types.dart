enum ViewType {
  view,
  label,
  button,
  touchableOpacity,
  gestureDetector,
  scrollView,
  stackView,
  listView;

  String get value {
    switch (this) {
      case ViewType.view:
        return 'View';
      case ViewType.label:
        return 'Label';
      case ViewType.button:
        return 'Button';
      case ViewType.touchableOpacity:
        return 'TouchableOpacity';
      case ViewType.gestureDetector:
        return 'GestureDetector';
      case ViewType.scrollView:
        return 'ScrollView';
      case ViewType.stackView:
        return 'StackView';
      case ViewType.listView:
        return 'ListView';
    }
  }
}
