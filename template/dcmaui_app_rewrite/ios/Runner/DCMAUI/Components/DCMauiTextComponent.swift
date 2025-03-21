import UIKit

class DCMauiTextComponent: NSObject, DCMauiComponentProtocol {
    static func createView(props: [String: Any]) -> UIView {
        let label = UILabel()
        
        // Set content if available
        if let content = props["content"] as? String {
            label.text = content
        }
        
        updateView(label, props: props)
        return label
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let textView = view as? UILabel else { return }
        
        // Apply base view properties first
        DCMauiViewComponent.updateView(textView, props: props)
        
        // Set content if available
        if let content = props["content"] as? String {
            textView.text = content
        }
        
        // Text-specific properties
        if let fontSize = props["fontSize"] as? Int {
            textView.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        
        if let color = props["color"] as? String {
            textView.textColor = UIColorFromHex(color)
        }
        
        if let align = props["textAlign"] as? String {
            switch align {
            case "center":
                textView.textAlignment = .center
            case "right":
                textView.textAlignment = .right
            default:
                textView.textAlignment = .left
            }
        }
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Text components have no standard events
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Text components have no standard events
    }
}
