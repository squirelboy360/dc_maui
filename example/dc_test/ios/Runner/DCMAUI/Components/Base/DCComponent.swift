import UIKit
import YogaKit

protocol DCComponent: UIView {
    var viewId: String { get }
    var eventHandlers: [String: () -> Void] { get set }
    
    func handleStateChange(_ newState: [String: Any])
    func applyStyle(_ style: [String: Any])
    func setupDefaults()
}
