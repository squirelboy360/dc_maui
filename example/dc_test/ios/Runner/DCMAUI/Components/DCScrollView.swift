import UIKit

class DCScrollView: DCView, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let contentContainer = DCView(viewId: "scroll-content")
    
    override func setupDefaults() {
        super.setupDefaults()
        
        scrollView.yoga.isEnabled = true
        scrollView.delegate = self
        addSubview(scrollView)
        
        contentContainer.yoga.isEnabled = true
        scrollView.addSubview(contentContainer)
        
        // Setup scroll view constraints
        scrollView.yoga.position = .absolute
        scrollView.yoga.left = .zero
        scrollView.yoga.top = .zero
        scrollView.yoga.right = .zero
        scrollView.yoga.bottom = .zero
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        if let offset = newState["contentOffset"] as? [String: CGFloat] {
            scrollView.contentOffset = CGPoint(
                x: offset["x"] ?? 0,
                y: offset["y"] ?? 0
            )
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let showsIndicators = style["showsIndicators"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsIndicators
            scrollView.showsHorizontalScrollIndicator = showsIndicators
        }
        
        if let bounces = style["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        if let pagingEnabled = style["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
    }
    
    func setContent(_ view: DCView) {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        contentContainer.addSubview(view)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onScroll",
            "data": [
                "offset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "velocity": [
                    "x": scrollView.panGestureRecognizer.velocity(in: scrollView).x,
                    "y": scrollView.panGestureRecognizer.velocity(in: scrollView).y
                ],
                "contentSize": [
                    "width": scrollView.contentSize.width,
                    "height": scrollView.contentSize.height
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onScrollEnd",
            "data": [
                "offset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
}
