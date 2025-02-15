import UIKit

class ZStackView: UIView {
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Only apply center constraints - remove conflicting width/height constraints
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Only set size if no explicit size was set
        if !view.constraints.contains(where: { $0.firstAttribute == .width }) {
            view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        }
        if !view.constraints.contains(where: { $0.firstAttribute == .height }) {
            view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        }
    }
    
    override var intrinsicContentSize: CGSize {
        // Use the largest subview's size as intrinsic size
        let size = subviews.reduce(CGSize.zero) { currentSize, view in
            CGSize(
                width: max(currentSize.width, view.frame.width),
                height: max(currentSize.height, view.frame.height)
            )
        }
        return size.width > 0 && size.height > 0 ? size : CGSize(width: 100, height: 100)
    }
}
