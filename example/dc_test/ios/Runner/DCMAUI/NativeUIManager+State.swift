import Foundation

@available(iOS 13.0, *)
extension NativeUIManager {
    struct ViewState: Codable {
        var properties: [String: Any]
        var childIds: [String]
        var stateBindings: [String: Any]
        
        enum CodingKeys: String, CodingKey {
            case properties, childIds, stateBindings
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(properties.jsonStringify(), forKey: .properties)
            try container.encode(childIds, forKey: .childIds)
            try container.encode(stateBindings.jsonStringify(), forKey: .stateBindings)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            properties = (try container.decode(String.self, forKey: .properties)).jsonDictionary() ?? [:]
            childIds = try container.decode([String].self, forKey: .childIds)
            stateBindings = (try container.decode(String.self, forKey: .stateBindings)).jsonDictionary() ?? [:]
        }
        
        init(properties: [String: Any], childIds: [String], stateBindings: [String: Any]) {
            self.properties = properties
            self.childIds = childIds
            self.stateBindings = stateBindings
        }
    }
    
    func saveState() {
        viewAccessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let state = self.views.mapValues { view -> ViewState in
                let properties = self.captureViewState(view)
                let childIds = self.childViews[view.hashValue.description] ?? []
                let bindings = self.stateBindings.filter { $0.value.contains(view.hashValue.description) }
                return ViewState(properties: properties, childIds: childIds, stateBindings: bindings)
            }
            
            if let data = try? JSONEncoder().encode(state) {
                UserDefaults.standard.set(data, forKey: "NativeUIState")
            }
        }
    }
    
    func restoreState() {
        guard let data = UserDefaults.standard.data(forKey: "NativeUIState"),
              let state = try? JSONDecoder().decode([String: ViewState].self, from: data) else {
            return
        }
        
        viewAccessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Restore views and their states
            for (viewId, viewState) in state {
                if let view = self.views[viewId] {
                    self.applyViewState(viewState.properties, to: view)
                    self.childViews[viewId] = viewState.childIds
                    
                    // Restore bindings
                    for (key, boundViews) in viewState.stateBindings {
                        if let boundViewsSet = boundViews as? Set<String> {
                            self.stateBindings[key] = boundViewsSet
                        }
                    }
                }
            }
        }
    }
    
    private func captureViewState(_ view: UIView) -> [String: Any] {
        var state: [String: Any] = [
            "frame": ["x": view.frame.origin.x, "y": view.frame.origin.y,
                     "width": view.frame.size.width, "height": view.frame.size.height],
            "alpha": view.alpha,
            "isHidden": view.isHidden,
            "tag": view.tag
        ]
        
        // Capture view-specific properties
        switch view {
        case let button as UIButton:
            state["title"] = button.title(for: .normal)
            state["isEnabled"] = button.isEnabled
            
        case let label as UILabel:
            state["text"] = label.text
            state["textColor"] = label.textColor.hexString
            
        case let imageView as UIImageView:
            if let imageUrl = imageView.accessibilityIdentifier {
                state["imageUrl"] = imageUrl
            }
            
        default:
            break
        }
        
        return state
    }
    
    private func applyViewState(_ state: [String: Any], to view: UIView) {
        if let frame = state["frame"] as? [String: CGFloat] {
            view.frame = CGRect(x: frame["x"] ?? 0, y: frame["y"] ?? 0,
                              width: frame["width"] ?? 0, height: frame["height"] ?? 0)
        }
        
        if let alpha = state["alpha"] as? CGFloat {
            view.alpha = alpha
        }
        
        if let isHidden = state["isHidden"] as? Bool {
            view.isHidden = isHidden
        }
        
        if let tag = state["tag"] as? Int {
            view.tag = tag
        }
        
        // Apply view-specific properties
        switch view {
        case let button as UIButton:
            if let title = state["title"] as? String {
                button.setTitle(title, for: .normal)
            }
            if let isEnabled = state["isEnabled"] as? Bool {
                button.isEnabled = isEnabled
            }
            
        case let label as UILabel:
            if let text = state["text"] as? String {
                label.text = text
            }
            if let textColor = state["textColor"] as? String {
                label.textColor = UIColor(hex: textColor)
            }
            
        case let imageView as UIImageView:
            if let imageUrl = state["imageUrl"] as? String {
                imageView.accessibilityIdentifier = imageUrl
                loadNetworkImage(url: imageUrl, into: imageView)
            }
            
        default:
            break
        }
    }
}

// Helper extensions
extension Dictionary {
    func jsonStringify() -> String {
        if let data = try? JSONSerialization.data(withJSONObject: self),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "{}"
    }
}

extension String {
    func jsonDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return dict
        }
        return nil
    }
}

extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X%02X",
                     Int(red * 255),
                     Int(green * 255),
                     Int(blue * 255),
                     Int(alpha * 255))
    }
}
