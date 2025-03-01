import UIKit

/**
 DCAnimatedView: Animatable container view

 Expected Input Properties:
 {
   "animation": {
     "type": String,           // "basic", "spring", "keyframe", "chain"
     "duration": Double,       // Animation duration
     "delay": Double,         // Start delay
     "curve": String,         // "linear", "easeIn", "easeOut", "easeInOut"
     
     // For spring animations
     "dampingRatio": CGFloat,
     "initialVelocity": CGFloat,
     
     // For keyframe animations
     "keyframes": [{
       "startTime": Double,   // Relative start time (0-1)
       "duration": Double,    // Relative duration
       "transform": {
         "scale": CGFloat,
         "rotation": CGFloat,
         "translation": {x, y}
       },
       "style": { style properties }
     }],
     
     // For chain animations
     "chain": [{ animation configs }]
   },
   "layout": {
     // Yoga layout properties
   }
 }
*/

class DCAnimatedView: DCView {
    private var currentAnimation: UIViewPropertyAnimator?
    private var animations: [String: UIViewPropertyAnimator] = [:]
    
    // New animation options
    enum AnimationType: String {
        case basic, spring, keyframe, chain
    }
    
    override func setupDefaults() {
        super.setupDefaults()
        clipsToBounds = true
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        // Handle animation configuration
        if let animation = newState["animation"] as? [String: Any] {
            let type = AnimationType(rawValue: animation["type"] as? String ?? "basic") ?? .basic
            
            // Stop any current animation if requested
            if let stop = animation["stop"] as? Bool, stop {
                currentAnimation?.stopAnimation(true)
                currentAnimation = nil
                return
            }
            
            switch type {
            case .basic:
                animate(with: animation)
            case .spring:
                animateSpring(with: animation)
            case .keyframe:
                animateKeyframes(with: animation)
            case .chain:
                animateChain(with: animation)
            }
        }
        
        // Handle direct animation controls
        if let animationProgress = newState["animationProgress"] as? CGFloat,
           let currentAnimation = self.currentAnimation {
            currentAnimation.fractionComplete = animationProgress
        }
        
        // Handle animation pausing/resuming
        if let isPaused = newState["isPaused"] as? Bool {
            if isPaused {
                currentAnimation?.pauseAnimation()
            } else {
                currentAnimation?.startAnimation()
            }
        }
        
        // Handle direct transform changes
        if let transform = newState["transform"] as? [String: Any] {
            UIView.animate(withDuration: 0.3) {
                self.applyTransform(transform)
            }
        }
    }
    
    private func animate(with config: [String: Any]) {
        // Cancel any ongoing animation
        currentAnimation?.stopAnimation(true)
        
        let duration = config["duration"] as? Double ?? 0.3
        let delay = config["delay"] as? Double ?? 0
        let options: UIView.AnimationOptions = {
            switch config["curve"] as? String {
            case "linear": return .curveLinear
            case "easeIn": return .curveEaseIn
            case "easeOut": return .curveEaseOut
            case "easeInOut", _: return .curveEaseInOut
            }
        }()
        
        currentAnimation = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [weak self] in
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
    
    private func animateSpring(with config: [String: Any]) {
        let dampingRatio = config["dampingRatio"] as? CGFloat ?? 0.8
        let initialVelocity = config["initialVelocity"] as? CGFloat ?? 0.0
        
        currentAnimation = UIViewPropertyAnimator(duration: 0, dampingRatio: dampingRatio) { [weak self] in
            self?.applyAnimationChanges(config)
        }
        currentAnimation?.startAnimation()
    }
    
    private func animateKeyframes(with config: [String: Any]) {
        guard let keyframes = config["keyframes"] as? [[String: Any]] else { return }
        
        UIView.animateKeyframes(withDuration: config["duration"] as? Double ?? 1.0, delay: 0) {
            keyframes.enumerated().forEach { index, frame in
                let relativeStartTime = frame["startTime"] as? Double ?? Double(index) / Double(keyframes.count)
                let relativeDuration = frame["duration"] as? Double ?? 1.0 / Double(keyframes.count)
                
                UIView.addKeyframe(withRelativeStartTime: relativeStartTime, relativeDuration: relativeDuration) {
                    self.applyAnimationChanges(frame)
                }
            }
        }
    }
    
    private func animateChain(with config: [String: Any]) {
        guard let chain = config["chain"] as? [[String: Any]] else { return }
        
        var previousAnimation: UIViewPropertyAnimator?
        
        chain.forEach { animationConfig in
            let animation = UIViewPropertyAnimator(duration: animationConfig["duration"] as? Double ?? 0.3, curve: .easeInOut) {
                self.applyAnimationChanges(animationConfig)
            }
            
            if let previous = previousAnimation {
                previous.addCompletion { _ in
                    animation.startAnimation()
                }
            } else {
                animation.startAnimation()
            }
            
            previousAnimation = animation
        }
    }
    
    private func applyAnimationChanges(_ config: [String: Any]) {
        if let transform = config["transform"] as? [String: Any] {
            applyTransform(transform)
        }
        if let style = config["style"] as? [String: Any] {
            applyStyle(style)
        }
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
    
    override func captureCurrentState() -> [String: Any] {
        var state = super.captureCurrentState()
        
        // Animation state
        if let currentAnimation = currentAnimation {
            state["isAnimating"] = true
            state["animationProgress"] = currentAnimation.fractionComplete
            state["isPaused"] = currentAnimation.state == .inactive
        } else {
            state["isAnimating"] = false
        }
        
        // Transform state
        if transform != .identity {
            // Transform is already captured in the super.captureCurrentState()
        }
        
        return state
    }
}
