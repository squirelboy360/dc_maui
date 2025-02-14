import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    func applyStyles(_ view: UIView, styles: [String: Any]) {
        // Background
        if let backgroundColor = styles["backgroundColor"] as? String {
            view.backgroundColor = UIColor(hex: backgroundColor)
        }
        
        // Border
        if let border = styles["border"] as? [String: Any] {
            if let width = border["width"] as? CGFloat {
                view.layer.borderWidth = width
            }
            if let color = border["color"] as? String {
                view.layer.borderColor = UIColor(hex: color)?.cgColor
            }
            if let radius = border["radius"] as? CGFloat {
                view.layer.cornerRadius = radius
            }
        }
        
        // Shadow
        if let shadow = styles["shadow"] as? [String: Any] {
            view.layer.shadowColor = UIColor(hex: shadow["color"] as? String ?? "#000000")?.cgColor
            view.layer.shadowOffset = CGSize(
                width: shadow["offsetX"] as? CGFloat ?? 0,
                height: shadow["offsetY"] as? CGFloat ?? 2
            )
            view.layer.shadowRadius = shadow["radius"] as? CGFloat ?? 4
            view.layer.shadowOpacity = Float(shadow["opacity"] as? CGFloat ?? 0.25)
        }
        
        // Opacity
        if let opacity = styles["opacity"] as? CGFloat {
            view.alpha = opacity
        }
        
        // Transform
        if let transform = styles["transform"] as? [String: Any] {
            var transform = CGAffineTransform.identity
            
            if let scale = transform["scale"] as? CGFloat {
                transform = transform.scaledBy(x: scale, y: scale)
            }
            if let rotation = transform["rotation"] as? CGFloat {
                transform = transform.rotated(by: rotation)
            }
            if let translation = transform["translation"] as? [String: CGFloat] {
                transform = transform.translatedBy(
                    x: translation["x"] ?? 0,
                    y: translation["y"] ?? 0
                )
            }
            
            view.transform = transform
        }
        
        // Gradient
        if let gradient = styles["gradient"] as? [String: Any] {
            applyGradient(to: view, properties: gradient)
        }
        
        // Blur
        if let blur = styles["blur"] as? [String: Any] {
            applyBlur(to: view, properties: blur)
        }
        
        // Text styles (for labels and buttons)
        if let textStyles = styles["text"] as? [String: Any] {
            applyTextStyles(to: view, styles: textStyles)
        }
        
        // Content mode (for images)
        if let contentMode = styles["contentMode"] as? String {
            view.contentMode = contentMode.toContentMode()
        }
        
        // Clipping
        if let clipsToBounds = styles["clipsToBounds"] as? Bool {
            view.clipsToBounds = clipsToBounds
        }
        
        // Mask
        if let mask = styles["mask"] as? [String: Any] {
            applyMask(to: view, properties: mask)
        }
    }
    
    private func applyGradient(to view: UIView, properties: [String: Any]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        if let colors = properties["colors"] as? [String] {
            gradientLayer.colors = colors.map { UIColor(hex: $0)?.cgColor as Any }
        }
        
        if let locations = properties["locations"] as? [CGFloat] {
            gradientLayer.locations = locations.map { NSNumber(value: Double($0)) }
        }
        
        if let startPoint = properties["startPoint"] as? [String: CGFloat],
           let endPoint = properties["endPoint"] as? [String: CGFloat] {
            gradientLayer.startPoint = CGPoint(x: startPoint["x"] ?? 0, y: startPoint["y"] ?? 0)
            gradientLayer.endPoint = CGPoint(x: endPoint["x"] ?? 1, y: endPoint["y"] ?? 1)
        }
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func applyBlur(to view: UIView, properties: [String: Any]) {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
        
        if let intensity = properties["intensity"] as? CGFloat {
            blurView.alpha = intensity
        }
    }
    
    private func applyTextStyles(to view: UIView, styles: [String: Any]) {
        if let label = view as? UILabel {
            if let font = styles["font"] as? String {
                label.font = UIFont(name: font, size: styles["size"] as? CGFloat ?? 17)
            }
            if let color = styles["color"] as? String {
                label.textColor = UIColor(hex: color)
            }
            if let alignment = styles["alignment"] as? String {
                label.textAlignment = alignment.toTextAlignment()
            }
        } else if let button = view as? UIButton {
            if let font = styles["font"] as? String {
                button.titleLabel?.font = UIFont(name: font, size: styles["size"] as? CGFloat ?? 17)
            }
            if let color = styles["color"] as? String {
                button.setTitleColor(UIColor(hex: color), for: .normal)
            }
        }
    }
    
    private func applyMask(to view: UIView, properties: [String: Any]) {
        let maskLayer = CAShapeLayer()
        
        if let type = properties["type"] as? String {
            switch type {
            case "circle":
                let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
                let radius = min(view.bounds.width, view.bounds.height) / 2
                let path = UIBezierPath(arcCenter: center, radius: radius,
                                      startAngle: 0, endAngle: .pi * 2, clockwise: true)
                maskLayer.path = path.cgPath
                
            case "roundRect":
                let radius = properties["radius"] as? CGFloat ?? 8
                let path = UIBezierPath(roundedRect: view.bounds,
                                      cornerRadius: radius)
                maskLayer.path = path.cgPath
                
            default:
                break
            }
        }
        
        view.layer.mask = maskLayer
    }
}

// Helper extensions for styling
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension String {
    func toTextAlignment() -> NSTextAlignment {
        switch self.lowercased() {
        case "left": return .left
        case "center": return .center
        case "right": return .right
        case "justified": return .justified
        case "natural": return .natural
        default: return .left
        }
    }
    
    func toContentMode() -> UIView.ContentMode {
        switch self.lowercased() {
        case "scaleToFill": return .scaleToFill
        case "scaleAspectFit": return .scaleAspectFit
        case "scaleAspectFill": return .scaleAspectFill
        case "center": return .center
        case "top": return .top
        case "bottom": return .bottom
        case "left": return .left
        case "right": return .right
        default: return .scaleToFill
        }
    }
}