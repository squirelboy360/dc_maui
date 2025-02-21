import UIKit
import Flutter

protocol DCComponent: UIView {
    var viewId: String { get }
    
    func handleStateChange(_ newState: [String: Any])
    func applyStyle(_ style: [String: Any])
    func setupDefaults()
    func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?)
}

// Default implementation
extension DCComponent {
    func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        // Base components don't handle events by default
    }
}
