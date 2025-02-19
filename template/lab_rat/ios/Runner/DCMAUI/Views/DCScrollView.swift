import UIKit

enum ScrollAxis: String {
    case vertical
    case horizontal
    case free
}

class DCScrollView: UIScrollView {
    var scrollAxis: ScrollAxis = .vertical {
        didSet { updateScrollAxis() }
    }
    
    private var contentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
    }
    
    private func setupScrollView() {
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = true
        alwaysBounceVertical = true
        clipsToBounds = true
    }
    
    func setContent(_ view: UIView) {
        contentView?.removeFromSuperview()
        contentView = view
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
        ])
        
        updateScrollAxis()
    }
    
    private func updateScrollAxis() {
        guard let contentView = contentView else { return }
        
        switch scrollAxis {
        case .vertical:
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor).isActive = true
        case .horizontal:
            contentView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor).isActive = true
        case .free:
            break
        }
    }
}
