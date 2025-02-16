import UIKit

enum LayoutAxis: String {
    case horizontal
    case vertical
}

enum LayoutAlignment: String {
    case start
    case center
    case end
    case stretch
}

enum LayoutSize: String {
    case fill
    case wrap
}

enum FlexDirection: String {
    case row, column
}

enum FlexAlignment: String {
    case start, center, end, spaceBetween, spaceAround, spaceEvenly
}

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func handleSetViewLayout(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view ID", details: nil))
            return
        }

        DispatchQueue.main.async {
            // Ensure view has a superview
            guard let superview = view.superview else {
                result(FlutterError(code: "NO_SUPERVIEW", message: "View must be attached", details: nil))
                return
            }

            // Remove existing constraints
            view.constraints.forEach { constraint in
                if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                    view.removeConstraint(constraint)
                }
            }

            // Handle width
            if let width = args["width"] as? Double {
                if width == -1 { // matchParent
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                        view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
                    ])
                } else if width > 0 {
                    view.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
                }
            }

            // Handle height
            if let height = args["height"] as? Double {
                if height == -1 { // matchParent
                    NSLayoutConstraint.activate([
                        view.topAnchor.constraint(equalTo: superview.topAnchor),
                        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                    ])
                } else if height > 0 {
                    view.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
                }
            }

            // Handle alignment
            if let alignment = args["alignment"] as? String {
                switch alignment {
                case "center":
                    view.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
                case "start":
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                case "end":
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                default:
                    break
                }
            }

            result(true)
        }
    }
    
    private func convertStackAlignment(_ alignment: String) -> UIStackView.Alignment {
        switch alignment {
        case "start": return .leading
        case "center": return .center
        case "end": return .trailing
        case "stretch": return .fill
        default: return .fill
        }
    }
    
    internal func handleSetViewSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view ID", details: nil))
            return
        }
        
        // Remove existing size constraints
        view.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                view.removeConstraint(constraint)
            }
        }
        
        // Apply new size constraints
        if let width = args["width"] as? CGFloat {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = args["height"] as? CGFloat {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        result(true)
    }
    
    private func applyAlignment(_ alignment: String, to view: UIView) {
        if let stackView = view as? UIStackView {
            switch alignment {
            case "start":
                stackView.alignment = .leading
            case "center":
                stackView.alignment = .center
            case "end":
                stackView.alignment = .trailing
            case "stretch":
                stackView.alignment = .fill
            default:
                break
            }
        } else {
            // For non-stack views, use constraints
            guard let superview = view.superview else { return }
            
            switch alignment {
            case "center":
                view.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
                view.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
            case "stretch":
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            default:
                break
            }
        }
    }
    
    private func applySizeConstraint(_ size: String, for dimension: NSLayoutConstraint.Attribute, to view: UIView) {
        guard let superview = view.superview else { return }
        
        switch size {
        case "fill":
            switch dimension {
            case .width:
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            case .height:
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            default:
                break
            }
        case "wrap":
            if let stackView = view as? UIStackView {
                dimension == .width ? (stackView.axis = .horizontal) : (stackView.axis = .vertical)
            }
        default:
            break
        }
    }
    
    private func applyMargin(_ margin: [String: CGFloat], to view: UIView) {
        guard let superview = view.superview else { return }
        
        if let top = margin["top"] {
            view.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        }
        if let left = margin["left"] {
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: left).isActive = true
        }
        if let bottom = margin["bottom"] {
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom).isActive = true
        }
        if let right = margin["right"] {
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -right).isActive = true
        }
    }
    
    private func applyPadding(_ padding: [String: CGFloat], to view: UIView) {
        if let stackView = view as? UIStackView {
            stackView.layoutMargins = UIEdgeInsets(
                top: padding["top"] ?? 0,
                left: padding["left"] ?? 0,
                bottom: padding["bottom"] ?? 0,
                right: padding["right"] ?? 0
            )
            stackView.isLayoutMarginsRelativeArrangement = true
        }
    }
    
    private func applyFlex(_ flex: Double, to view: UIView) {
        if let stackView = view.superview as? UIStackView {
            view.setContentHuggingPriority(.init(rawValue: 1000 - Float(flex)), for: stackView.axis == .horizontal ? .horizontal : .vertical)
            view.setContentCompressionResistancePriority(.init(rawValue: 1000 - Float(flex)), for: stackView.axis == .horizontal ? .horizontal : .vertical)
        }
    }
    
    private func applyWidth(_ width: Double, to view: UIView) {
        view.removeConstraints(view.constraints.filter { $0.firstAttribute == .width })
        
        if width > 0 {
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: CGFloat(width))
            ])
        }
    }
    
    private func applyHeight(_ height: Double, to view: UIView) {
        view.removeConstraints(view.constraints.filter { $0.firstAttribute == .height })
        
        if height > 0 {
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: CGFloat(height))
            ])
        }
    }
}
