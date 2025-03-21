import UIKit

class DCMauiViewComponent: NSObject, DCMauiComponentProtocol {
    static func createView(props: [String: Any]) -> UIView {
        let view = UIView()
        updateView(view, props: props)
        return view
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        // Background color
        if let bgColor = props["backgroundColor"] as? String {
            view.backgroundColor = UIColorFromHex(bgColor)
        }
        
        // Padding (via layout margins)
        if let padding = props["padding"] as? Int {
            view.layoutMargins = UIEdgeInsets(
                top: CGFloat(padding),
                left: CGFloat(padding),
                bottom: CGFloat(padding),
                right: CGFloat(padding)
            )
        }
        
        // Other view properties can be added here
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Views have no specific events by default
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Views have no specific events by default
    }
}
