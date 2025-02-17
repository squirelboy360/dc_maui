import UIKit

class ZStackView: UIView {
    private var sizeConstraints: [NSLayoutConstraint] = []
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Center the view
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Check for explicit size constraints on the child view
        let hasExplicitWidth = view.constraints.contains { $0.firstAttribute == .width }
        let hasExplicitHeight = view.constraints.contains { $0.firstAttribute == .height }
        
        // Remove any previous size constraints
        NSLayoutConstraint.deactivate(sizeConstraints)
        sizeConstraints.removeAll()
        
        // Add size constraints with appropriate priorities
        if !hasExplicitWidth {
            let widthConstraint = view.widthAnchor.constraint(equalTo: widthAnchor)
            widthConstraint.priority = .defaultHigh // Lower priority than explicit constraints
            widthConstraint.isActive = true
            sizeConstraints.append(widthConstraint)
        }
        
        if !hasExplicitHeight {
            let heightConstraint = view.heightAnchor.constraint(equalTo: heightAnchor)
            heightConstraint.priority = .defaultHigh // Lower priority than explicit constraints
            heightConstraint.isActive = true
            sizeConstraints.append(heightConstraint)
        }
        
        // Update ZStack size to match child if needed
        if hasExplicitWidth || hasExplicitHeight {
            updateZStackSize(for: view)
        }
    }
    
    private func updateZStackSize(for view: UIView) {
        // Find explicit size constraints on the child view
        let widthConstraint = view.constraints.first { $0.firstAttribute == .width }
        let heightConstraint = view.constraints.first { $0.firstAttribute == .height }
        
        if let width = widthConstraint?.constant {
            let zstackWidth = widthAnchor.constraint(equalToConstant: width)
            zstackWidth.priority = .defaultLow // Lower priority than child constraints
            zstackWidth.isActive = true
            sizeConstraints.append(zstackWidth)
        }
        
        if let height = heightConstraint?.constant {
            let zstackHeight = heightAnchor.constraint(equalToConstant: height)
            zstackHeight.priority = .defaultLow // Lower priority than child constraints
            zstackHeight.isActive = true
            sizeConstraints.append(zstackHeight)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = subviews.reduce(CGSize.zero) { currentSize, view in
            CGSize(
                width: max(currentSize.width, view.frame.width),
                height: max(currentSize.height, view.frame.height)
            )
        }
        return size.width > 0 && size.height > 0 ? size : CGSize(width: 100, height: 100)
    }
}
