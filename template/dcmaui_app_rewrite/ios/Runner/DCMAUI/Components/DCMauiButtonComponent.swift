import UIKit

class DCMauiButtonComponent: NSObject, DCMauiComponentProtocol {
    private static var buttonEventHandlers: [UIButton: (String, (String, String, [String: Any]) -> Void)] = [:]
    
    static func createView(props: [String: Any]) -> UIView {
        let button = UIButton(type: .system)
        
        // Set title if available
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        updateView(button, props: props)
        return button
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let button = view as? UIButton else { return }
        
        // Apply base view properties first
        DCMauiViewComponent.updateView(button, props: props)
        
        // Button-specific properties
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        if let color = props["color"] as? String {
            button.setTitleColor(UIColorFromHex(color), for: .normal)
        }
        
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
        }
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let button = view as? UIButton else { return }
        
        for eventType in eventTypes {
            if eventType == "press" {
                // Store the viewId and callback
                buttonEventHandlers[button] = (viewId, eventCallback)
                
                // Add target
                button.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
            }
        }
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let button = view as? UIButton else { return }
        
        for eventType in eventTypes {
            if eventType == "press" {
                button.removeTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
                buttonEventHandlers.removeValue(forKey: button)
            }
        }
    }
    
    @objc static func handleButtonPress(_ sender: UIButton) {
        guard let (viewId, callback) = buttonEventHandlers[sender] else { return }
        callback(viewId, "press", [:])
    }
}
