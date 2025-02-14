import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    func applyConstraints(to view: UIView, in container: UIView, with edges: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: edges.top),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: edges.left),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -edges.right),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -edges.bottom)
        ])
    }
    
    func applySize(to view: UIView, width: CGFloat?, height: CGFloat?) {
        if let width = width {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func applyAlignment(_ alignment: String, to view: UIView, in container: UIView) {
        switch alignment {
        case "center":
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        case "top":
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ])
        case "bottom":
            NSLayoutConstraint.activate([
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ])
        default:
            break
        }
    }
    
    func updateStackViewProperties(_ stackView: UIStackView, with properties: [String: Any]) {
        if let spacing = properties["spacing"] as? CGFloat {
            stackView.spacing = spacing
        }
        if let distribution = properties["distribution"] as? String {
            stackView.distribution = UIStackView.Distribution(rawValue: distribution) ?? .fill
        }
        if let alignment = properties["alignment"] as? String {
            stackView.alignment = UIStackView.Alignment(rawValue: alignment) ?? .fill
        }
    }
    
    private func applyLayoutConstraints(_ view: UIView, options: [String: Any]) {
        // Stack layout
        if let stackView = view as? UIStackView {
            if let distribution = options["distribution"] as? String {
                stackView.distribution = distribution.toStackDistribution()
            }
            if let alignment = options["alignment"] as? String {
                stackView.alignment = alignment.toStackAlignment()
            }
        }
        
        // Flex layout
        if let flex = options["flex"] as? CGFloat {
            view.setContentHuggingPriority(.init(rawValue: 1000 - Float(flex)), for: .horizontal)
            view.setContentHuggingPriority(.init(rawValue: 1000 - Float(flex)), for: .vertical)
        }
        
        // Position constraints
        if let position = options["position"] as? [String: CGFloat],
           let superview = view.superview {
            var constraints: [NSLayoutConstraint] = []
            
            if let top = position["top"] {
                constraints.append(view.topAnchor.constraint(equalTo: superview.topAnchor, constant: top))
            }
            if let left = position["left"] {
                constraints.append(view.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: left))
            }
            if let right = position["right"] {
                constraints.append(view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -right))
            }
            if let bottom = position["bottom"] {
                constraints.append(view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom))
            }
            
            // Center positioning
            if let centerX = position["centerX"] {
                constraints.append(view.centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: centerX))
            }
            if let centerY = position["centerY"] {
                constraints.append(view.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: centerY))
            }
            
            NSLayoutConstraint.activate(constraints)
        }
        
        // Size constraints
        if let size = options["size"] as? [String: CGFloat] {
            if let width = size["width"] {
                view.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
            if let height = size["height"] {
                view.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }
        
        // Aspect ratio
        if let aspectRatio = options["aspectRatio"] as? CGFloat {
            view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: aspectRatio).isActive = true
        }
        
        // Margin and padding
        if let edges = options["margin"] as? [String: CGFloat],
           let superview = view.superview {
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: edges["top"] ?? 0),
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: edges["left"] ?? 0),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -(edges["right"] ?? 0)),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -(edges["bottom"] ?? 0))
            ])
        }
        
        // Z-index (layer ordering)
        if let zIndex = options["zIndex"] as? Int {
            view.layer.zPosition = CGFloat(zIndex)
        }
    }
    
    func applyFlexibleLayout(_ view: UIView, flex: Int) {
        let priority = UILayoutPriority(1000 - Float(flex))
        view.setContentHuggingPriority(priority, for: .horizontal)
        view.setContentHuggingPriority(priority, for: .vertical)
        view.setContentCompressionResistancePriority(priority, for: .horizontal)
        view.setContentCompressionResistancePriority(priority, for: .vertical)
    }
}

// Helper extensions for layout
extension String {
    func toStackDistribution() -> UIStackView.Distribution {
        switch self {
        case "fill": return .fill
        case "fillEqually": return .fillEqually
        case "fillProportionally": return .fillProportionally
        case "equalSpacing": return .equalSpacing
        case "equalCentering": return .equalCentering
        default: return .fill
        }
    }
    
    func toStackAlignment() -> UIStackView.Alignment {
        switch self {
        case "fill": return .fill
        case "leading": return .leading
        case "center": return .center
        case "trailing": return .trailing
        case "firstBaseline": return .firstBaseline
        case "lastBaseline": return .lastBaseline
        default: return .fill
        }
    }
}