import UIKit


@available(iOS 13.0, *)
extension NativeUIManager {
    internal func handleCreateScrollView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
            return
        }

        // Extract scroll axis configuration
        let axis: ScrollAxis
        if let axisString = args["axis"] as? String {
            switch axisString {
            case "vertical": axis = .vertical
            case "horizontal": axis = .horizontal
            case "free": axis = .free
            default: axis = .vertical
            }
        } else {
            axis = .vertical
        }

        // Extract padding
        let padding = args["padding"] as? [String: CGFloat] ?? [:]
        let insets = UIEdgeInsets(
            top: padding["top"] ?? 0,
            left: padding["left"] ?? 0,
            bottom: padding["bottom"] ?? 0,
            right: padding["right"] ?? 0
        )

        // Create scroll view with axis and padding
        let scrollView = DCScrollView(axis: axis, padding: insets)
        
        // Generate view ID and store
        let viewId = "scrollview-\(UUID().uuidString)"
        views[viewId] = scrollView
        childViews[viewId] = []
        
        result(viewId)
    }
    
    internal func handleSetScrollContent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let scrollViewId = args["scrollViewId"] as? String,
              let contentViewId = args["contentViewId"] as? String,
              let scrollView = views[scrollViewId] as? DCScrollView,
              let contentView = views[contentViewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view IDs", details: nil))
            return
        }
        
        scrollView.setContent(contentView)
        result(true)
    }
    
    internal func handleConfigureAsScrollView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid viewId", details: nil))
            return
        }
        
        // Create scroll view with existing view's frame
        let scrollView = DCScrollView(frame: view.frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.yoga.isEnabled = true
        
        // Configure scroll view
        if let axisString = args["axis"] as? String {
            scrollView.scrollAxis = ScrollAxis(rawValue: axisString) ?? .vertical
        }
        
        if let padding = args["padding"] as? [String: CGFloat] {
            scrollView.contentInset = UIEdgeInsets(
                top: padding["top"] ?? 0,
                left: padding["left"] ?? 0,
                bottom: padding["bottom"] ?? 0,
                right: padding["right"] ?? 0
            )
        }
        
        // Replace old view with scroll view
        if let superview = view.superview {
            view.removeFromSuperview()
            superview.addSubview(scrollView)
            
            // Transfer existing constraints
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                scrollView.topAnchor.constraint(equalTo: superview.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        
        // Update view registry
        views[viewId] = scrollView
        
        // Setup scroll monitoring
        scrollView.delegate = self
        scrollView.tag = viewId.hash
        
        result(true)
    }
}

// DCScrollView implementation
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
        
        // Add width/height constraints based on axis
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

enum ScrollAxis: String {
    case vertical
    case horizontal
    case free
}
