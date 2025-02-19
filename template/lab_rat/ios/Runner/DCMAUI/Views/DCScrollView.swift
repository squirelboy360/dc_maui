import UIKit

enum ScrollAxis {
    case vertical
    case horizontal
    case free
}

class DCScrollView: UIScrollView {
    private let contentView: UIView
    private var currentAxis: ScrollAxis = .vertical
    
    init(axis: ScrollAxis = .vertical, padding: UIEdgeInsets = .zero) {
        self.contentView = UIView()
        self.currentAxis = axis
        super.init(frame: .zero)
        setupScrollView(with: padding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView(with padding: UIEdgeInsets) {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        // Lock scroll direction based on axis
        switch currentAxis {
        case .vertical:
            isDirectionalLockEnabled = true
            alwaysBounceVertical = true
            alwaysBounceHorizontal = false
            showsVerticalScrollIndicator = true 
            showsHorizontalScrollIndicator = false
        case .horizontal:
            isDirectionalLockEnabled = true
            alwaysBounceVertical = false
            alwaysBounceHorizontal = true
            showsVerticalScrollIndicator = false
            showsHorizontalScrollIndicator = true
        case .free:
            isDirectionalLockEnabled = false
            alwaysBounceVertical = true
            alwaysBounceHorizontal = true
            showsVerticalScrollIndicator = true
            showsHorizontalScrollIndicator = true
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        // Base constraints for content view
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor, constant: padding.top),
            contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: padding.left),
            contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -padding.right),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor, constant: -padding.bottom)
        ])
        
        // Axis-specific constraints
        switch currentAxis {
        case .vertical:
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor, constant: -(padding.left + padding.right)).isActive = true
        case .horizontal:
            contentView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor, constant: -(padding.top + padding.bottom)).isActive = true
        case .free:
            // No additional constraints for free scrolling
            break
        }
    }
    
    func setContent(_ view: UIView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
