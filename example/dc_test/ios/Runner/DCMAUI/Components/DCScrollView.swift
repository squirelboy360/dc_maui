import UIKit

class DCScrollView: DCView {
    private let scrollView = UIScrollView()
    private let contentContainer = DCView(viewId: "scroll-content")
    
    override func setupDefaults() {
        super.setupDefaults()
        
        scrollView.yoga.isEnabled = true
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
}
