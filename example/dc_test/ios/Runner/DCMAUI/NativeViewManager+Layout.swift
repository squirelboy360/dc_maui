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
    
//    func updateStackViewProperties(_ stackView: UIStackView, with properties: [String: Any]) {
//        if let spacing = properties["spacing"] as? CGFloat {
//            stackView.spacing = spacing
//        }
//        if let distribution = properties["distribution"] as? String {
//            stackView.distribution = UIStackView.Distribution(rawValue: distribution) ?? .fill
//        }
//        if let alignment = properties["alignment"] as? String {
//            stackView.alignment = UIStackView.Alignment(rawValue: alignment) ?? .fill
//        }
//    }
    
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
    
    func handleLayoutSetup(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid layout arguments", details: nil))
            return
        }
        
        if let layoutType = args["type"] as? String {
            switch layoutType {
            case "flexbox":
                setupFlexboxLayout(view: view, params: args)
            case "grid":
                setupGridLayout(view: view, params: args)
            case "stack":
                setupStackLayout(view: view, params: args)
            default:
                result(FlutterError(code: "INVALID_TYPE", message: "Unknown layout type", details: nil))
                return
            }
        }
        
        result(true)
    }
    
    private func setupFlexboxLayout(view: UIView, params: [String: Any]) {
        guard let stackView = view as? UIStackView else {
            let newStackView = UIStackView()
            newStackView.frame = view.frame
            newStackView.translatesAutoresizingMaskIntoConstraints = false
            
            if let parent = view.superview {
                parent.addSubview(newStackView)
                NSLayoutConstraint.activate([
                    newStackView.topAnchor.constraint(equalTo: parent.topAnchor),
                    newStackView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                    newStackView.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
                    newStackView.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
                ])
            }
            
            // Transfer all subviews to stack view
            while let subview = view.subviews.first {
                newStackView.addArrangedSubview(subview)
            }
            
            configureStackView(newStackView, params: params)
            return
        }
        
        configureStackView(stackView, params: params)
    }
    
    private func configureStackView(_ stackView: UIStackView, params: [String: Any]) {
        if let direction = params["direction"] as? String {
            stackView.axis = direction == "horizontal" ? .horizontal : .vertical
        }
        
        if let spacing = params["spacing"] as? CGFloat {
            stackView.spacing = spacing
        }
        
        if let alignment = params["alignment"] as? String {
            switch alignment {
            case "start": stackView.alignment = .leading
            case "center": stackView.alignment = .center
            case "end": stackView.alignment = .trailing
            case "stretch": stackView.alignment = .fill
            default: break
            }
        }
        
        if let distribution = params["distribution"] as? String {
            switch distribution {
            case "start": stackView.distribution = .fill
            case "center": stackView.distribution = .equalCentering
            case "end": stackView.distribution = .fillProportionally
            case "spaceBetween": stackView.distribution = .equalSpacing
            case "spaceAround": stackView.distribution = .equalCentering
            default: break
            }
        }
    }
    
    private func setupGridLayout(view: UIView, params: [String: Any]) {
        // Remove existing constraints
        view.constraints.forEach { $0.isActive = false }
        
        // Convert string parameters to integers
        guard let columnsValue = params["columns"],
              let rowsValue = params["rows"],
              let columns = (columnsValue as? NSNumber)?.intValue ?? Int(columnsValue as? String ?? ""),
              let rows = (rowsValue as? NSNumber)?.intValue ?? Int(rowsValue as? String ?? ""),
              columns > 0 && rows > 0 else { return }
        
        let cellViews = view.subviews
        var gridConstraints: [NSLayoutConstraint] = []
        
        // Create horizontal stack views for each row
        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = params["spacing"] as? CGFloat ?? 8
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(rowStack)
            
            // Add cells to row
            for col in 0..<columns {
                let index = row * columns + col
                if index < cellViews.count {
                    let cellView = cellViews[index]
                    rowStack.addArrangedSubview(cellView)
                }
            }
            
            // Layout row stack view
            gridConstraints.append(contentsOf: [
                rowStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                rowStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                rowStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0/CGFloat(rows))
            ])
            
            if row == 0 {
                gridConstraints.append(rowStack.topAnchor.constraint(equalTo: view.topAnchor))
            } else {
                let previousRow = view.subviews[row - 1]
                gridConstraints.append(rowStack.topAnchor.constraint(equalTo: previousRow.bottomAnchor))
            }
        }
        
        NSLayoutConstraint.activate(gridConstraints)
    }
    
    private func setupStackLayout(view: UIView, params: [String: Any]) {
        guard let stackView = view as? UIStackView else { return }
        
        if let spacing = params["spacing"] as? CGFloat {
            stackView.spacing = spacing
        }
        
        if let axis = params["axis"] as? String {
            stackView.axis = axis == "horizontal" ? .horizontal : .vertical
        }
        
        if let distribution = params["distribution"] as? String {
            switch distribution {
            case "equal": stackView.distribution = .fillEqually
            case "proportional": stackView.distribution = .fillProportionally
            case "dynamic": stackView.distribution = .fill
            default: stackView.distribution = .fill
            }
        }
        
        stackView.alignment = .fill
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
