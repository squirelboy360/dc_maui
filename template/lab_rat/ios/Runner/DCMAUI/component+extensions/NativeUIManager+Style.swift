import UIKit

extension UIColor {
    convenience init(rgb: UInt32) {
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        let a = CGFloat((rgb >> 24) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a > 0 ? a : 1.0)
    }
}

enum BorderType: String {
    case none
    case solid
    case dashed
    case dotted
}

struct BorderStyle {
    let width: CGFloat
    let color: UIColor
    let style: BorderType
    
    func apply(to layer: CALayer) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        // Apply border style if needed
    }
}

struct TextStyle {
    let text: String?  // Add this property
    let font: UIFont?
    let color: UIColor?
    let alignment: NSTextAlignment?
    let lineSpacing: CGFloat?
    let letterSpacing: CGFloat?
    
    func apply(to label: UILabel) {
        if let text = text {
            label.text = text
        }
        if let font = font {
            label.font = font
        }
        if let color = color {
            label.textColor = color
        }
        if let alignment = alignment {
            label.textAlignment = alignment
        }
        if let lineSpacing = lineSpacing {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            label.attributedText = NSAttributedString(
                string: label.text ?? "",
                attributes: [.paragraphStyle: paragraphStyle]
            )
        }
    }
}

struct ImageStyle {
    let contentMode: UIView.ContentMode
    let tintColor: UIColor?
    let cornerRadius: CGFloat?
    
    func apply(to imageView: UIImageView) {
        imageView.contentMode = contentMode
        if let tintColor = tintColor {
            imageView.tintColor = tintColor
        }
        if let cornerRadius = cornerRadius {
            imageView.layer.cornerRadius = cornerRadius
            imageView.clipsToBounds = true
        }
    }
}

extension UIView {
    func apply(_ style: ViewStyle) {
        print("Applying style to view: \(self)")
        print("Style properties: \(style)")
        
        // Background
        if let color = style.backgroundColor {
            backgroundColor = color
            print("Applied background color: \(color)")
        }
        
        // Opacity
        if let opacity = style.opacity {
            alpha = opacity
        }
        
        // Corner radius
        if let radius = style.cornerRadius {
            layer.cornerRadius = radius.isUniform ? radius.topLeft : {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: bounds.minX + radius.topLeft, y: bounds.minY))
                path.addLine(to: CGPoint(x: bounds.maxX - radius.topRight, y: bounds.minY))
                path.addArc(withCenter: CGPoint(x: bounds.maxX - radius.topRight, y: bounds.minY + radius.topRight),
                           radius: radius.topRight,
                           startAngle: -.pi / 2,
                           endAngle: 0,
                           clockwise: true)
                path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - radius.bottomRight))
                path.addArc(withCenter: CGPoint(x: bounds.maxX - radius.bottomRight, y: bounds.maxY - radius.bottomRight),
                           radius: radius.bottomRight,
                           startAngle: 0,
                           endAngle: .pi / 2,
                           clockwise: true)
                path.addLine(to: CGPoint(x: bounds.minX + radius.bottomLeft, y: bounds.maxY))
                path.addArc(withCenter: CGPoint(x: bounds.minX + radius.bottomLeft, y: bounds.maxY - radius.bottomLeft),
                           radius: radius.bottomLeft,
                           startAngle: .pi / 2,
                           endAngle: .pi,
                           clockwise: true)
                path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + radius.topLeft))
                path.addArc(withCenter: CGPoint(x: bounds.minX + radius.topLeft, y: bounds.minY + radius.topLeft),
                           radius: radius.topLeft,
                           startAngle: .pi,
                           endAngle: 3 * .pi / 2,
                           clockwise: true)
                path.close()
                
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                layer.mask = mask
                return radius.topLeft // Return a value for the ternary operator
            }()
        }
        
        // Shadow
        if let shadow = style.shadow {
            shadow.apply(to: layer)
        }
        
        // Clipping
        if let clips = style.clipToBounds {
            clipsToBounds = clips
        }
        
        // Transform
        if let transform = style.transform {
            transform.apply(to: self)
        }
        
        // Filters
        if let filter = style.filter {
            var filters: [CIFilter] = []
            
            if let blur = filter.blur {
                let gaussianBlur = CIFilter(name: "CIGaussianBlur")
                gaussianBlur?.setValue(blur, forKey: kCIInputRadiusKey)
                filters.append(gaussianBlur!)
            }
            
            if !filters.isEmpty {
                layer.filters = filters
            }
        }
        
        // Gradient
        if let gradient = style.gradient {
            print("Applying gradient: \(gradient)")
            gradient.apply(to: self)
        }
        
        // Apply gradient with proper frame
        if let gradient = style.gradient {
            print("Applying gradient with colors: \(gradient.colors)")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = self.bounds
                gradientLayer.colors = gradient.colors.map { $0.cgColor }
                gradientLayer.locations = gradient.locations.map { NSNumber(value: Double($0)) }
                gradientLayer.startPoint = gradient.startPoint
                gradientLayer.endPoint = gradient.endPoint
                // Remove existing gradient if any
                self.layer.sublayers?.removeAll { $0 is CAGradientLayer }
                self.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
        
        // Handle text styles more comprehensively
        if let textStyle = style.textStyle {
            if let label = self as? UILabel {
                if let text = textStyle.text {
                    label.text = text
                }
                if let font = textStyle.font {
                    label.font = font
                }
                if let color = textStyle.color {
                    label.textColor = color
                }
            } else if let button = self as? UIButton {
                if let text = textStyle.text {
                    button.setTitle(text, for: .normal)
                }
                if let font = textStyle.font {
                    button.titleLabel?.font = font
                }
                if let color = textStyle.color {
                    button.setTitleColor(color, for: .normal)
                }
            }
        }
    }
}

struct ViewStyle {
    var backgroundColor: UIColor?
    var opacity: CGFloat?
    var cornerRadius: EdgeRadius?
    var border: BorderStyle?
    var shadow: ShadowStyle?
    var clipToBounds: Bool?
    var gradient: GradientStyle?
    var blendMode: CGBlendMode?
    var transform: TransformStyle?
    var filter: FilterStyle?
    var textStyle: TextStyle? // Add this line
}

struct EdgeRadius {
    let topLeft: CGFloat
    let topRight: CGFloat
    let bottomLeft: CGFloat
    let bottomRight: CGFloat
    
    var isUniform: Bool {
        return topLeft == topRight && topRight == bottomLeft && bottomLeft == bottomRight
    }
}

struct ShadowStyle {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: CGFloat
    
    func apply(to layer: CALayer) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = Float(opacity)
        layer.masksToBounds = false
    }
}

struct TransformStyle {
    let rotation: CGFloat?
    let scale: CGPoint?
    let translation: CGPoint?
    let anchor: CGPoint?
    
    func apply(to view: UIView) {
        var transform = CATransform3DIdentity
        
        if let rotation = rotation {
            transform = CATransform3DRotate(transform, rotation * .pi / 180, 0, 0, 1)
        }
        
        if let scale = scale {
            transform = CATransform3DScale(transform, CGFloat(scale.x), CGFloat(scale.y), 1)
        }
        
        if let translation = translation {
            transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
        }
        
        if let anchor = anchor {
            view.layer.anchorPoint = anchor
        }
        
        view.layer.transform = transform
    }
}

struct FilterStyle {
    let blur: CGFloat?
    let brightness: CGFloat?
    let contrast: CGFloat?
    let saturation: CGFloat?
    let grayscale: CGFloat?
}

struct GradientStyle {
    let colors: [UIColor]
    let locations: [CGFloat]
    let startPoint: CGPoint
    let endPoint: CGPoint
    
    func apply(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations.map { NSNumber(value: Double($0)) }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

struct NativeViewStyle {
    let backgroundColor: UIColor?
    let opacity: Float?
    let border: BorderStyle?
    let cornerRadius: CGFloat?
    let shadow: ShadowStyle? 
    let gradient: GradientStyle?
    let transform: TransformStyle?
    let blendMode: CGBlendMode?
    let clipToBounds: Bool?
    let textStyle: TextStyle?
    let imageStyle: ImageStyle?

    init(from style: [String: Any]) {
        // Initialize all properties
        self.backgroundColor = (style["backgroundColor"] as? UInt32).map { UIColor(rgb: $0) }
        self.opacity = style["opacity"] as? Float
        self.border = (style["border"] as? [String: Any]).map { dict in
            BorderStyle(
                width: (dict["width"] as? CGFloat) ?? 1.0,
                color: UIColor(rgb: (dict["color"] as? UInt32) ?? 0x000000),
                style: BorderType(rawValue: (dict["style"] as? String) ?? "solid") ?? .solid
            )
        }
        self.cornerRadius = style["cornerRadius"] as? CGFloat
        self.shadow = (style["shadow"] as? [String: Any]).map { dict in
            ShadowStyle(
                color: UIColor(rgb: (dict["color"] as? UInt32) ?? 0x000000),
                offset: CGSize(
                    width: ((dict["offset"] as? [String: CGFloat])?["x"] ?? 0),
                    height: ((dict["offset"] as? [String: CGFloat])?["y"] ?? 0)
                ),
                radius: (dict["radius"] as? CGFloat) ?? 0,
                opacity: (dict["opacity"] as? CGFloat) ?? 0
            )
        }
        self.gradient = (style["gradient"] as? [String: Any]).map { dict in
            GradientStyle(
                colors: (dict["colors"] as? [UInt32])?.map { UIColor(rgb: $0) } ?? [],
                locations: (dict["locations"] as? [CGFloat]) ?? [],
                startPoint: CGPoint(
                    x: ((dict["startPoint"] as? [String: CGFloat])?["x"] ?? 0),
                    y: ((dict["startPoint"] as? [String: CGFloat])?["y"] ?? 0)
                ),
                endPoint: CGPoint(
                    x: ((dict["endPoint"] as? [String: CGFloat])?["x"] ?? 1),
                    y: ((dict["endPoint"] as? [String: CGFloat])?["y"] ?? 1)
                )
            )
        }
        self.transform = (style["transform"] as? [String: Any]).map { dict in
            TransformStyle(
                rotation: dict["rotation"] as? CGFloat,
                scale: (dict["scale"] as? [String: CGFloat]).map { CGPoint(x: $0["x"] ?? 1, y: $0["y"] ?? 1) },
                translation: (dict["translation"] as? [String: CGFloat]).map { CGPoint(x: $0["x"] ?? 0, y: $0["y"] ?? 0) },
                anchor: (dict["anchor"] as? [String: CGFloat]).map { CGPoint(x: $0["x"] ?? 0.5, y: $0["y"] ?? 0.5) }
            )
        }
        self.blendMode = (style["blendMode"] as? String).flatMap { BlendMode(rawValue: $0)?.cgBlendMode }
        self.clipToBounds = style["clipToBounds"] as? Bool
        self.textStyle = (style["textStyle"] as? [String: Any]).map { dict in
            TextStyle(
                text: dict["text"] as? String,  // Add this line
                font: (dict["fontSize"] as? CGFloat).map { UIFont.systemFont(ofSize: $0) },
                color: (dict["color"] as? UInt32).map { UIColor(rgb: $0) },
                alignment: (dict["textAlign"] as? String).flatMap { TextAlign(rawValue: $0)?.nsTextAlignment },
                lineSpacing: dict["lineSpacing"] as? CGFloat,
                letterSpacing: dict["letterSpacing"] as? CGFloat
            )
        }
        self.imageStyle = (style["imageStyle"] as? [String: Any]).map { dict in
            ImageStyle(
                contentMode: ContentMode(rawValue: (dict["fit"] as? String) ?? "cover")?.uiViewContentMode ?? .scaleAspectFill,
                tintColor: (dict["tintColor"] as? UInt32).map { UIColor(rgb: $0) },
                cornerRadius: dict["cornerRadius"] as? CGFloat
            )
        }
    }

    func apply(to view: UIView) {
        // Type-safe application of styles
        if let backgroundColor = backgroundColor {
            view.backgroundColor = backgroundColor
        }
        
        if let opacity = opacity {
            view.alpha = CGFloat(opacity)
        }

        if let border = border {
            border.apply(to: view.layer)
        }

        if let cornerRadius = cornerRadius {
            view.layer.cornerRadius = cornerRadius
        }

        if let shadow = shadow {
            shadow.apply(to: view.layer)
        }

        if let gradient = gradient {
            gradient.apply(to: view)
        }

        if let transform = transform {
            transform.apply(to: view)
        }

        if let blendMode = blendMode {
            view.layer.compositingFilter = blendMode
        }

        if let clipToBounds = clipToBounds {
            view.clipsToBounds = clipToBounds
        }

        if let textStyle = textStyle, let label = view as? UILabel {
            textStyle.apply(to: label)
        }

        if let imageStyle = imageStyle, let imageView = view as? UIImageView {
            imageStyle.apply(to: imageView) 
        }
    }
}


private enum TextAlign: String {
    case left, center, right, justify
    
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justify: return .justified
        }
    }
}

private enum ContentMode: String {
    case fill, contain, cover, scaleDown, none
    
    var uiViewContentMode: UIView.ContentMode {
        switch self {
        case .fill: return .scaleToFill
        case .contain: return .scaleAspectFit
        case .cover: return .scaleAspectFill
        case .scaleDown: return .scaleAspectFit
        case .none: return .center
        }
    }
}

private enum BlendMode: String {
    case normal, multiply, screen, overlay
    
    var cgBlendMode: CGBlendMode {
        switch self {
        case .normal: return .normal
        case .multiply: return .multiply
        case .screen: return .screen
        case .overlay: return .overlay
        }
    }
}
