enum ViewType {
  view,
  label,
  button,
  touchableOpacity;

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
    }
  }
}
