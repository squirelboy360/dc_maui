import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func handleCreateListView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
            return
        }

        let listView = DCScrollableStackView(frame: .zero)
        listView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure direction
        if let direction = args["direction"] as? String {
            listView.axis = direction == "horizontal" ? .horizontal : .vertical
        }
        
        // Configure spacing
        if let spacing = args["spacing"] as? CGFloat {
            listView.spacing = spacing
        }
        
        // Configure padding
        if let padding = args["padding"] as? [String: CGFloat] {
            listView.contentInset = UIEdgeInsets(
                top: padding["top"] ?? 0,
                left: padding["left"] ?? 0,
                bottom: padding["bottom"] ?? 0,
                right: padding["right"] ?? 0
            )
        }

        let viewId = "listview-\(UUID().uuidString)"
        views[viewId] = listView
        childViews[viewId] = []
        
        result(viewId)
    }
}

private class DCScrollableStackView: UIScrollView {
    private(set) var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    var axis: NSLayoutConstraint.Axis = .vertical {
        didSet {
            stackView.axis = axis
            updateConstraintsForAxis()
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
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            
            // Ensure stack view width matches scroll view width for vertical scrolling
            stackView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor)
        ])
        
        // Default configuration
        stackView.distribution = .fill
        stackView.alignment = .fill
        spacing = 8
        
        // Enable scrolling
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = true
    }
    
    private func updateConstraintsForAxis() {
        if axis == .vertical {
            stackView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor).isActive = true
        } else {
            stackView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor).isActive = true
        }
    }
    
    override func addSubview(_ view: UIView) {
        if view === stackView {
            super.addSubview(view)
        } else {
            stackView.addArrangedSubview(view)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update content size
        if axis == .vertical {
            contentSize = CGSize(width: bounds.width, height: stackView.frame.height)
        } else {
            contentSize = CGSize(width: stackView.frame.width, height: bounds.height)
        }
    }
}
