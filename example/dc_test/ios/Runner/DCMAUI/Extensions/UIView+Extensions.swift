import UIKit

extension UIView {
    func setupForBackground() {
        backgroundColor = .clear
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

protocol SafeCheckable {
    var isValid: Bool { get }
    func showPlaceholder()
}

extension UIView: SafeCheckable {
    var isValid: Bool {
        return window != nil && !isHidden && alpha > 0
    }
    
    func showPlaceholder() {
        let label = UILabel()
        label.text = "Not Implemented: \(type(of: self))"
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .lightGray.withAlphaComponent(0.3)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        print("⚠️ View not implemented: \(type(of: self))")
    }
}

extension Optional where Wrapped: SafeCheckable {
    @discardableResult
    func safeCheck() -> Wrapped? {
        guard let value = self, value.isValid else {
            print("⚠️ SafeCheck failed: \(String(describing: Wrapped.self)) is nil or invalid")
            return nil
        }
        return value
    }
}
