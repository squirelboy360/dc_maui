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
}
