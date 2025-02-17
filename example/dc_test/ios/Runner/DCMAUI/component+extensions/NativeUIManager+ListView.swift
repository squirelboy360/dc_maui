import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func handleCreateListView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
            return
        }

        let spacing = args["spacing"] as? CGFloat ?? 8.0
        let padding = args["padding"] as? [String: CGFloat] ?? [:]
        
        let insets = UIEdgeInsets(
            top: padding["top"] ?? 0,
            left: padding["left"] ?? 0,
            bottom: padding["bottom"] ?? 0,
            right: padding["right"] ?? 0
        )
        
        let listView = DCCollectionView(spacing: spacing, padding: insets)
        listView.translatesAutoresizingMaskIntoConstraints = false

        let viewId = "listview-\(UUID().uuidString)"
        views[viewId] = listView
        childViews[viewId] = []
        
        result(viewId)
    }
    
    // Add this helper method to handle adding items to the list
    internal func addItemToList(_ listView: DCCollectionView, _ childView: UIView, height: CGFloat? = nil) {
        listView.addItem(childView, height: height)
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
    
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupStackView()
    }
    
    private func setupScrollView() {
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = true
        clipsToBounds = true
    }
    
    private func setupStackView() {
        addSubview(stackView)
        
        // Use frameLayoutGuide for outer constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
        ])
        
        // Configure stack view
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        // Initial axis setup
        updateConstraintsForAxis()
    }
    
    private func updateConstraintsForAxis() {
        // Remove existing constraints
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        
        // Create new constraints based on axis
        if axis == .vertical {
            widthConstraint = stackView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor)
            widthConstraint?.isActive = true
        } else {
            heightConstraint = stackView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor)
            heightConstraint?.isActive = true
        }
    }
    
    override func addSubview(_ view: UIView) {
        if view === stackView {
            super.addSubview(view)
        } else {
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
            
            // For vertical stacks, ensure items fill width
            if axis == .vertical {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
                ])
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update content size
        contentSize = stackView.frame.size
    }
}
