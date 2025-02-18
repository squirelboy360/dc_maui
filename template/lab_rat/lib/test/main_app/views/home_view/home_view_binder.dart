part of '../../imports.dart';

class HomeViewBinder extends HomeView {
  final _logger = Logger('HomeViewBinder');



  Future<void> navigateToHomeScreen() async {
    _logger.info('Starting navigation to home screen');

    try {
      // First create all components
      await createRootContainer(); // Bridge will handle root ID internally
      await createHeaderSection();
      await createCardSection();
      await createButtonsSection();

      // Then build view hierarchy from bottom up
      await bridge.attachView(counterDisplay, counterLabel);
      await bridge.attachView(cardSection, counterDisplay);
      await bridge.attachView(headerSection, titleLabel);
      await bridge.attachView(headerSection, subtitleLabel);
      await bridge.attachView(buttonsSection, decrementButton);
      await bridge.attachView(buttonsSection, resetButton);
      await bridge.attachView(buttonsSection, incrementButton);
      await bridge.attachView(rootContainer, headerSection);
      await bridge.attachView(rootContainer, cardSection);
      await bridge.attachView(rootContainer, buttonsSection);

      // Bridge will handle root attachment internally
      await bridge.attachToRoot(rootContainer);

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
