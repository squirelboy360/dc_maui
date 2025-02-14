import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func handleCreateListView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
            return
        }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        // Configure direction
        if let direction = args["direction"] as? String {
            stackView.axis = direction == "horizontal" ? .horizontal : .vertical
        }
        
        // Configure spacing
        if let spacing = args["spacing"] as? CGFloat {
            stackView.spacing = spacing
        }
        
        // Configure padding
        if let padding = args["padding"] as? [String: CGFloat] {
            scrollView.contentInset = UIEdgeInsets(
                top: padding["top"] ?? 0,
                left: padding["left"] ?? 0,
                bottom: padding["bottom"] ?? 0,
                right: padding["right"] ?? 0
            )
        }

        // Setup stackView constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Make stack width equal to scroll view for vertical scrolling
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // Configure stack
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        let viewId = "listview-\(UUID().uuidString)"
        views[viewId] = scrollView
        childViews[viewId] = []
        
        result(viewId)
    }
}

private class DCScrollableStackView: UIScrollView {
    private let stackView = UIStackView()
    
    var axis: NSLayoutConstraint.Axis = .vertical {
        didSet {
            stackView.axis = axis
        }
    }
    
    var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }
    
    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            // This constraint ensures proper scrolling
            stackView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        
        // Default configuration
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
    }
    
    override func addSubview(_ view: UIView) {
        if view != stackView {
            stackView.addArrangedSubview(view)
        } else {
            super.addSubview(view)
        }
    }
}
