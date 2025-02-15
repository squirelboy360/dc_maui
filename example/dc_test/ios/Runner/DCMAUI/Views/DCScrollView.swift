import UIKit

class DCScrollView: UIScrollView {
    private let contentView: UIView
    
    init(padding: UIEdgeInsets = .zero) {
        self.contentView = UIView()
        super.init(frame: .zero)
        setupScrollView(with: padding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView(with padding: UIEdgeInsets) {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        alwaysBounceVertical = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor, constant: padding.top),
            contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: padding.left),
            contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -padding.right),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor, constant: -padding.bottom),
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor, constant: -(padding.left + padding.right))
        ])
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
