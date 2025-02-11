import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  var flutterEngine: FlutterEngine?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Initialize Flutter Engine
    flutterEngine = FlutterEngine(name: "my_flutter_engine")
    flutterEngine?.run()  // Start the Flutter engine
    
    // Register plugins
    GeneratedPluginRegistrant.register(with: self) // Ensure plugins are registered

    // Set up the Flutter method channel for communication
    setupFlutterMethodChannel()

    // Show native UI as Flutter UI is not needed
    showNativeUI()

    return true
  }
  
  func setupFlutterMethodChannel() {
    guard let flutterEngine = flutterEngine else { return }
    
    let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    
    // Initialize method channel to communicate with Flutter
    let methodChannel = FlutterMethodChannel(name: "com.example.channel", binaryMessenger: flutterViewController.binaryMessenger)
    
    // Ensure the method call handler is registered
    methodChannel.setMethodCallHandler { (call, result) in
      if call.method == "sendMessage" {
        if let message = call.arguments as? String {
          // Show received message in native UI
          self.displayReceivedMessage(message)
        }
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  func showNativeUI() {
    // Create a simple native UI button for testing
    let button = UIButton(type: .system)
    button.setTitle("Hello from Native", for: .normal)
    button.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
    button.backgroundColor = .blue
    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    
    if let window = self.window {
      window.rootViewController?.view.addSubview(button)
    }
  }
  
  func displayReceivedMessage(_ message: String) {
    // Display the received message (e.g., on a label or button)
    let label = UILabel()
    label.text = "Received from Flutter: \(message)"
    label.frame = CGRect(x: 100, y: 200, width: 300, height: 50)
    label.textColor = .black
    
    if let window = self.window {
      window.rootViewController?.view.addSubview(label)
    }
  }
  
  @objc func buttonTapped() {
    print("Button tapped!")
  }
}
