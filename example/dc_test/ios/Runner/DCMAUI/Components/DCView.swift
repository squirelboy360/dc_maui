import UIKit
import YogaKit

class DCView: UIView, DCComponent {
    let viewId: String
    var eventHandlers: [String: () -> Void] = [:]
    
    init(viewId: String) {
        self.viewId = viewId
        super.init(frame: .zero)
        setupDefaults()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func setupDefaults() {
        self.yoga.isEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func handleStateChange(_ newState: [String: Any]) {
        // Base state handling
    }
    
    func applyStyle(_ style: [String: Any]) {
        // Apply common styles (background, border, etc)
        if let backgroundColor = style["backgroundColor"] as? UInt32 {
            self.backgroundColor = UIColor(rgb: backgroundColor)
        }
    }
}
