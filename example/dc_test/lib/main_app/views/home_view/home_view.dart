part of '../view_imports.dart';

class HomeView extends HomeViewComponents {
  final NativeUIBridge bridge;
  int counter = 0;

  HomeView(this.bridge);

  // Root container component with gradient
  Future<void> createRootContainer(String parentId) async {
    rootContainer = await bridge.createView(ViewType.view) ?? '';

    // Set explicit size constraints
    await bridge.setLayout(
      rootContainer,
      LayoutConfig(
        position: YGPositionType.absolute, // Change to absolute positioning
        display: YGDisplay.flex,
        flexDirection: YGFlexDirection.column,
        width: YGValue(100, YGUnit.percent),
        height: YGValue(100, YGUnit.percent),
        alignItems: YGAlign.center,
        justifyContent: YGJustify.flexStart,
        padding: const EdgeInsets.symmetric(horizontal: 20),
       
      ),
    );

    await bridge.updateView(
        rootContainer,
        ViewStyle(
          backgroundColor: Colors.deepPurpleAccent).toJson());
  }

  // Header section with title and subtitle
  Future<void> createHeaderSection() async {
    headerSection = await bridge.createView(ViewType.view) ?? '';

    await bridge.setLayout(
      headerSection,
      LayoutConfig(
        flexDirection: YGFlexDirection.column,
        alignItems: YGAlign.center,
        margin: const EdgeInsets.only(top: 60, bottom: 40),
      ),
    );

    await createHeaderTitle();
    await createHeaderSubtitle();
  }

  Future<void> createHeaderTitle() async {
    titleLabel = await bridge.createView(ViewType.label) ?? '';

    await bridge.updateView(
        titleLabel,
        ViewStyle(
            textStyle: TextStyle(
          text: 'Modern Counter',
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        )).toJson());

    await bridge.attachView(headerSection, titleLabel);
  }

  Future<void> createHeaderSubtitle() async {
    subtitleLabel = await bridge.createView(ViewType.label) ?? '';

    await bridge.updateView(
        subtitleLabel,
        ViewStyle(
            textStyle: TextStyle(
          text: 'Tap buttons to count',
          color: Colors.white.withOpacity(0.7),
          fontSize: 16,
        )).toJson());

    await bridge.attachView(headerSection, subtitleLabel);
  }

  // Card section with counter display
  Future<void> createCardSection() async {
    cardSection = await bridge.createView(ViewType.view) ?? '';

    await bridge.setLayout(
      cardSection,
      LayoutConfig(
        display: YGDisplay.flex,
        flexDirection: YGFlexDirection.column,
        alignItems: YGAlign.center,
        justifyContent: YGJustify.center,
        width: YGValue(100, YGUnit.percent),
        height: YGValue(80, YGUnit.percent),
      ),
    );

    await bridge.updateView(
        cardSection,
        ViewStyle(backgroundColor: Colors.white, cornerRadius: 24, shadows: [
          ShadowStyle(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 15),
            radius: 30,
          )
        ]).toJson());

    await createCounterDisplay();
  }

  Future<void> createCounterDisplay() async {
    counterDisplay = await bridge.createView(ViewType.view) ?? '';

    await bridge.setLayout(
      counterDisplay,
      LayoutConfig(
        width: YGValue(180, YGUnit.point),
        height: YGValue(180, YGUnit.point),
        alignItems: YGAlign.center,
        justifyContent: YGJustify.center,
        margin: const EdgeInsets.symmetric(vertical: 24),
      ),
    );

    await bridge.updateView(
        counterDisplay,
        ViewStyle(
          backgroundColor: Colors.blueAccent,
          border: BorderStyle(
              color: Colors.amber, style: BorderType.solid, width: 20),
          cornerRadius: 90,
        ).toJson());

    await createCounterLabel();
  }

  Future<void> createCounterLabel() async {
    counterLabel = await bridge.createView(ViewType.label) ?? '';

    await bridge.updateView(
        counterLabel,
        ViewStyle(
            textStyle: TextStyle(
          text: '0',
          color: Color(0xFF2E3192),
          fontSize: 72,
          fontWeight: FontWeight.bold,
        )).toJson());

    await bridge.attachView(counterDisplay, counterLabel);
  }

  // Buttons section
  Future<void> createButtonsSection() async {
    buttonsSection = await bridge.createView(ViewType.view) ?? '';

    await bridge.setLayout(
      buttonsSection,
      LayoutConfig(
        flexDirection: YGFlexDirection.row,
        justifyContent: YGJustify.spaceBetween,
        alignItems: YGAlign.center,
        width: YGValue(100, YGUnit.percent),
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(32),
      ),
    );

    await createDecrementButton();
    await createResetButton();
    await createIncrementButton();
  }

  Future<void> createDecrementButton() async {
    decrementButton = await createButton('-', Color(0xFFFF3B30), () async {
          counter--;
          // Update counter display
        }) ??
        '';

    await bridge.attachView(buttonsSection, decrementButton);
  }

  Future<void> createResetButton() async {
    resetButton = await createButton('↺', Color(0xFF007AFF), () async {
          counter = 0;
          // Update counter display
        }) ??
        '';

    await bridge.attachView(buttonsSection, resetButton);
  }

  Future<void> createIncrementButton() async {
    incrementButton = await createButton('+', Color(0xFF34C759), () async {
          counter++;
          // Update counter display
        }) ??
        '';

    await bridge.attachView(buttonsSection, incrementButton);
  }

  // Helper method to create buttons
  Future<String?> createButton(
      String text, Color color, Function() onPress) async {
    return await bridge.createButton(
      text: text,
      style: ViewStyle(
        backgroundColor: color,
        cornerRadius: 28,
        textStyle: TextStyle(
          text: text,
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        shadows: [
          ShadowStyle(
            color: color.withOpacity(0.3),
            offset: const Offset(0, 4),
            radius: 8,
          )
        ],
      ).toJson(),
      layout: LayoutConfig(
        width: YGValue.points(56),
        height: YGValue.points(56),
        alignItems: YGAlign.center,
        justifyContent: YGJustify.center,
      ),
      events: {ButtonEventType.onClick: () => onPress()},
    );
  }
}
