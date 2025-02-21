import UIKit

class DCAnimatedView: DCView {
    private var currentAnimation: UIViewPropertyAnimator?
    
    override func setupDefaults() {
        super.setupDefaults()
        clipsToBounds = true
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        if let animation = newState["animation"] as? [String: Any] {
            animate(with: animation)
        }
    }
    
    private func animate(with config: [String: Any]) {
        // Cancel any ongoing animation
        currentAnimation?.stopAnimation(true)
        
        let duration = config["duration"] as? Double ?? 0.3
        let delay = config["delay"] as? Double ?? 0
        let curve = AnimationCurve(rawValue: config["curve"] as? String ?? "easeInOut")?.uiCurve ?? .easeInOut
        
        currentAnimation = UIViewPropertyAnimator(duration: duration, curve: curve) { [weak self] in
            guard let self = self else { return }
            
            if let transform = config["transform"] as? [String: Any] {
                self.applyTransform(transform)
            }
            
            if let style = config["style"] as? [String: Any] {
                self.applyStyle(style)
            }
        }
        
        currentAnimation?.startAnimation(afterDelay: delay)
    }
    
    private func applyTransform(_ transform: [String: Any]) {
        var transformations = CGAffineTransform.identity
        
        if let scale = transform["scale"] as? CGFloat {
            transformations = transformations.scaledBy(x: scale, y: scale)
        }
        
        if let rotation = transform["rotation"] as? CGFloat {
            transformations = transformations.rotated(by: rotation)
        }
        
        if let translation = transform["translation"] as? [String: CGFloat] {
            let x = translation["x"] ?? 0
            let y = translation["y"] ?? 0
            transformations = transformations.translatedBy(x: x, y: y)
        }
        
        self.transform = transformations
    }
}

private enum AnimationCurve: String {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    
    var uiCurve: UIView.AnimationCurve {
        switch self {
        case .linear: return .linear
        case .easeIn: return .easeIn
        case .easeOut: return .easeOut
        case .easeInOut: return .easeInOut
        }
    }
}
