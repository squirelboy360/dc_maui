part of '../imports.dart';

class HomeViewBinder extends HomeView {
  final _logger = Logger('HomeViewBinder');

  HomeViewBinder(super.bridge);

  Future<void> navigateToHomeScreen() async {
    _logger.info('Starting navigation to home screen');

    final rootInfo = await bridge.getRootView();
    if (rootInfo == null) {
      _logger.severe('Failed to get root view');
      return;
    }

    final rootId = rootInfo['viewId'] as String;
    _logger.info('Got root view ID: $rootId');

    try {
      // First create all components
      await createRootContainer(rootId);
      await createHeaderSection();
      await createCardSection();
      await createButtonsSection();

      // Then build view hierarchy from bottom up
      // 1. Attach counter label to counter display
      await bridge.attachView(counterDisplay, counterLabel);
      
      // 2. Attach counter display to card section
      await bridge.attachView(cardSection, counterDisplay);
      
      // 3. Attach title and subtitle to header
      await bridge.attachView(headerSection, titleLabel);
      await bridge.attachView(headerSection, subtitleLabel);
      
      // 4. Attach buttons to buttons section
      await bridge.attachView(buttonsSection, decrementButton);
      await bridge.attachView(buttonsSection, resetButton);
      await bridge.attachView(buttonsSection, incrementButton);

      // 5. Attach main sections to root container
      await bridge.attachView(rootContainer, headerSection);
      await bridge.attachView(rootContainer, cardSection);
      await bridge.attachView(rootContainer, buttonsSection);

      // 6. Finally attach root container to platform root
      await bridge.attachView(rootId, rootContainer);

      // 7. Force layout calculation
      await bridge.setLayout(
        rootId,
        LayoutConfig(
          width: YGValue(100, YGUnit.percent),
          height: YGValue(100, YGUnit.percent),
        ),
      );

      _logger.info('View hierarchy built successfully');
    } catch (e, stack) {
      _logger.severe('Error building view hierarchy: $e');
      _logger.severe('Stack trace: $stack');
    }
  }

  Future<void> bindComponents() async {
    _logger.info('Starting component binding');

    // Attach main sections to root
    await bridge.attachView(rootContainer, headerSection);
    await bridge.attachView(rootContainer, cardSection);
    await bridge.attachView(rootContainer, buttonsSection);

    _logger.info('Main sections attached');

    // Attach header components
    await bridge.attachView(headerSection, titleLabel);
    await bridge.attachView(headerSection, subtitleLabel);

    _logger.info('Header components attached');

    // Attach card components
    await bridge.attachView(cardSection, counterDisplay);
    await bridge.attachView(counterDisplay, counterLabel);

    _logger.info('Card components attached');

    // Attach button components
    await bridge.attachView(buttonsSection, decrementButton);
    await bridge.attachView(buttonsSection, resetButton);
    await bridge.attachView(buttonsSection, incrementButton);

    _logger.info('Button components attached');
  }
}
