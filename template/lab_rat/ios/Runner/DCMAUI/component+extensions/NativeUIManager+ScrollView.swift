import UIKit
import Flutter

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func createScrollableBase(viewType: String, args: [String: Any]) -> UIView {
        let scrollView = UIScrollView()
        scrollView.delegate = self // We'll implement delegate methods here
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        // Create content view
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup content view constraints
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Handle ListView specific setup
        if viewType == "ListView" {
            setupListView(contentView, with: args)
        }
        
        return scrollView
    }
    
    private func setupListView(_ contentView: UIView, with args: [String: Any]) {
        guard let data = args["data"] as? [[String: Any]] else { return }
        
        // Create stack view for list items
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Setup stack view constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Store stack view reference for later use
        contentView.tag = 999
    }
}

// ScrollView delegate methods
@available(iOS 13.0, *)
extension NativeUIManager: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let eventData: [String: Any] = [
            "offset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ],
            "type": "onScroll"
        ]
        
        methodChannel?.invokeMethod("onScrollEvent", arguments: eventData)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let eventData: [String: Any] = [
            "offset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ],
            "type": "onScrollEnd"
        ]
        
        methodChannel?.invokeMethod("onScrollEvent", arguments: eventData)
    }
}
