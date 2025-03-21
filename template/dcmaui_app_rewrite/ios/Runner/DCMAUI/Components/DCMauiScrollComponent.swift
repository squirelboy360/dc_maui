import UIKit

class DCMauiScrollComponent: NSObject, DCMauiComponentProtocol {
    private static var scrollViewDelegates: [UIScrollView: ScrollViewDelegate] = [:]
    
    static func createView(props: [String: Any]) -> UIView {
        let scrollView = UIScrollView()
        updateView(scrollView, props: props)
        return scrollView
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Apply base view properties
        DCMauiViewComponent.updateView(scrollView, props: props)
        
        // Scroll-specific properties
        if let showsVerticalScrollIndicator = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
        
        // Configure other scroll properties...
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // If we need to handle events, create a delegate
        if eventTypes.contains("scroll") || eventTypes.contains("scrollEnd") {
            // Create and store delegate that bridges to our callback
            let delegate = ScrollViewDelegate(viewId: viewId, callback: eventCallback)
            scrollView.delegate = delegate
            scrollViewDelegates[scrollView] = delegate
        }
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        if eventTypes.contains("scroll") || eventTypes.contains("scrollEnd") {
            scrollView.delegate = nil
            scrollViewDelegates.removeValue(forKey: scrollView)
        }
    }
}

// Helper class to bridge UIScrollViewDelegate to our callback system
class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    private let viewId: String
    private let callback: (String, String, [String: Any]) -> Void
    
    init(viewId: String, callback: @escaping (String, String, [String: Any]) -> Void) {
        self.viewId = viewId
        self.callback = callback
        super.init()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        callback(viewId, "scroll", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        callback(viewId, "scrollEnd", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
}
