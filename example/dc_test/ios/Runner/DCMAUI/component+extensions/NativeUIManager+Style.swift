import UIKit

extension UIView {
    func apply(_ style: ViewStyle) {
        // Background
        if let color = style.backgroundColor {
            backgroundColor = color
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
                // ... create path with different corner radii
                layer.mask = CAShapeLayer()
                (layer.mask as? CAShapeLayer)?.path = path.cgPath
            }()
        }
        
        // Shadow
        if let shadow = style.shadow {
            layer.shadowColor = shadow.color.cgColor
            layer.shadowOffset = shadow.offset
            layer.shadowRadius = shadow.radius
            layer.shadowOpacity = Float(shadow.opacity)
        }
        
        // Clipping
        if let clips = style.clipToBounds {
            clipsToBounds = clips
        }
        
        // Transform
        if let transform = style.transform {
            var transform = CATransform3DIdentity
            
            if let rotation = transform.rotation {
                transform = CATransform3DRotate(transform, rotation * .pi / 180, 0, 0, 1)
            }
            
            if let scale = transform.scale {
                transform = CATransform3DScale(transform, scale.x, scale.y, 1)
            }
            
            if let translation = transform.translation {
                transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
            }
            
            if let anchor = transform.anchor {
                layer.anchorPoint = CGPoint(x: anchor.x, y: anchor.y)
            }
            
            layer.transform = transform
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
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = gradient.colors.map { $0.cgColor }
            gradientLayer.locations = gradient.locations.map { NSNumber(value: $0) }
            gradientLayer.startPoint = gradient.startPoint
            gradientLayer.endPoint = gradient.endPoint
            layer.insertSublayer(gradientLayer, at: 0)
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
}

struct TransformStyle {
    let rotation: CGFloat?
    let scale: CGPoint?
    let translation: CGPoint?
    let anchor: CGPoint?
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
}