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
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        // Apply Yoga/CSS layout properties
        if let layout = style["layout"] as? [String: Any] {
            yoga.applyFlexbox(layout)
            yoga.applySpacing(layout)
            
            // Handle dimensions
            if let width = layout["width"] as? YGValue { yoga.width = width }
            if let height = layout["height"] as? YGValue { yoga.height = height }
            if let minWidth = layout["minWidth"] as? YGValue { yoga.minWidth = minWidth }
            if let maxWidth = layout["maxWidth"] as? YGValue { yoga.maxWidth = maxWidth }
            if let minHeight = layout["minHeight"] as? YGValue { yoga.minHeight = minHeight }
            if let maxHeight = layout["maxHeight"] as? YGValue { yoga.maxHeight = maxHeight }
        }
        
        // Apply visual styles
        if let backgroundColor = style["backgroundColor"] as? UInt32 {
            self.backgroundColor = UIColor(rgb: backgroundColor)
        }
    }
}
