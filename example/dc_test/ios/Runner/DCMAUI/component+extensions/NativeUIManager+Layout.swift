import UIKit

enum StackAlignment {
    case start
    case center
    case end
    case stretch
    case baseline
    
    var uiKitAlignment: UIStackView.Alignment {
        switch self {
        case .start: return .leading
        case .center: return .center
        case .end: return .trailing
        case .stretch: return .fill
        case .baseline: return .firstBaseline
        }
    }
}

enum StackDistribution {
    case start
    case center
    case end
    case spaceBetween
    case spaceAround
    case spaceEvenly
    
    var uiKitDistribution: UIStackView.Distribution {
        switch self {
        case .start: return .fill
        case .center: return .equalCentering
        case .end: return .fillProportionally
        case .spaceBetween: return .equalSpacing
        case .spaceAround: return .equalCentering
        case .spaceEvenly: return .fillEqually
        }
    }
}

enum SizeType: String {
    case fixed
    case flex
    case wrap
    case matchParent
}

struct ViewSize {
    let type: SizeType
    let value: CGFloat?
    
    static func from(_ dict: [String: Any]?) -> ViewSize? {
        guard let dict = dict,
              let typeStr = dict["type"] as? String,
              let type = SizeType(rawValue: typeStr) else {
            return nil
        }
        return ViewSize(type: type, value: dict["value"] as? CGFloat)
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func configureStackViewLayout(_ stackView: UIStackView, layout: [String: Any]) {
        if let mainAxis = layout["mainAxisAlignment"] as? String {
            switch mainAxis {
            case "start":
                stackView.distribution = .fill
            case "center":
                stackView.distribution = .equalCentering
            case "end":
                stackView.distribution = .fillProportionally
            case "spaceBetween":
                stackView.distribution = .equalSpacing
            case "spaceAround":
                stackView.distribution = .equalCentering
            case "spaceEvenly":
                stackView.distribution = .fillEqually
            default:
                break
            }
        }
        
        if let crossAxis = layout["crossAxisAlignment"] as? String {
            switch crossAxis {
            case "start":
                stackView.alignment = .leading
            case "center":
                stackView.alignment = .center
            case "end":
                stackView.alignment = .trailing
            case "stretch":
                stackView.alignment = .fill
            case "baseline":
                stackView.alignment = .firstBaseline
            default:
                break
            }
        }
        
        if let spacing = layout["spacing"] as? CGFloat {
            stackView.spacing = spacing
        }
    }
    
    internal func configureViewLayout(_ view: UIView, layout: [String: Any]) {
        // Apply size constraints first
        if let widthDict = layout["width"] as? [String: Any],
           let width = ViewSize.from(widthDict) {
            applySizeConstraint(view, size: width, isWidth: true)
        }
        
        if let heightDict = layout["height"] as? [String: Any],
           let height = ViewSize.from(heightDict) {
            applySizeConstraint(view, size: height, isWidth: false)
        }
        
        // Apply background color if specified
        if let backgroundColor = layout["backgroundColor"] as? String {
            applyColorToView(view, colorString: backgroundColor, colorType: .background)
        }
        
        // Apply margins
        if let margins = layout["margin"] as? [String: CGFloat] {
            let layoutMargins = UIEdgeInsets(
                top: margins["top"] ?? 0,
                left: margins["left"] ?? 0,
                bottom: margins["bottom"] ?? 0,
                right: margins["right"] ?? 0
            )
            view.layoutMargins = layoutMargins
        }
        
        // Apply padding and stack properties
        if let stackView = view as? UIStackView {
            if let padding = layout["padding"] as? [String: CGFloat] {
                stackView.isLayoutMarginsRelativeArrangement = true
                stackView.layoutMargins = UIEdgeInsets(
                    top: padding["top"] ?? 0,
                    left: padding["left"] ?? 0,
                    bottom: padding["bottom"] ?? 0,
                    right: padding["right"] ?? 0
                )
            }
            
            // Configure stack properties using our enums
            if let mainAxis = layout["mainAxisAlignment"] as? String,
               let distribution = StackDistribution(rawValue: mainAxis) {
                stackView.distribution = distribution.uiKitDistribution
            }
            
            if let crossAxis = layout["crossAxisAlignment"] as? String,
               let alignment = StackAlignment(rawValue: crossAxis) {
                stackView.alignment = alignment.uiKitAlignment
            }
            
            if let spacing = layout["spacing"] as? CGFloat {
                stackView.spacing = spacing
            }
        }
    }

    private func applySizeConstraint(_ view: UIView, size: ViewSize, isWidth: Bool) {
        if let superview = view.superview {
            switch size.type {
            case .fixed:
                if let value = size.value {
                    let constraint = isWidth ?
                        view.widthAnchor.constraint(equalToConstant: value) :
                        view.heightAnchor.constraint(equalToConstant: value)
                    constraint.isActive = true
                }
            case .matchParent:
                let constraint = isWidth ?
                    view.widthAnchor.constraint(equalTo: superview.widthAnchor) :
                    view.heightAnchor.constraint(equalTo: superview.heightAnchor)
                constraint.isActive = true
            case .flex:
                if let value = size.value {
                    let priority = UILayoutPriority(rawValue: Float(value * 1000))
                    view.setContentHuggingPriority(priority, for: isWidth ? .horizontal : .vertical)
                }
            case .wrap:
                view.setContentHuggingPriority(.required, for: isWidth ? .horizontal : .vertical)
            }
        }
    }
}
