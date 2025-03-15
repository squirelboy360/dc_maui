//
//  DCAnimatedView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Component for handling animated properties
class DCAnimatedView: DCBaseView {
    // Map of active animations by property name
    private var activeAnimations: [String: CAAnimation] = [:]
    
    override func setupView() {
        super.setupView()
        layer.masksToBounds = false
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle animated styles
        if let animatedStyles = props["animatedStyles"] as? [String: Any] {
            processAnimatedStyles(animatedStyles)
        }
    }
    
    private func processAnimatedStyles(_ animatedStyles: [String: Any]) {
        // Process each animated property
        for (propertyName, propertyValue) in animatedStyles {
            guard let animationDetails = propertyValue as? [String: Any],
                  let toValue = animationDetails["animatedValue"] as? CGFloat,
                  let animationId = animationDetails["animationId"] as? String else {
                continue
            }
            
            // Process animation configuration
            let config = animationDetails["config"] as? [String: Any]
            let duration = (config?["duration"] as? Double) ?? 500.0 / 1000.0
            let delay = (config?["delay"] as? Double) ?? 0.0 / 1000.0
            let easing = config?["easing"] as? String ?? "easeInOut"
            
            // Create and apply the animation
            createAnimation(
                forProperty: propertyName,
                toValue: toValue,
                animationId: animationId,
                duration: duration,
                delay: delay,
                easing: easing
            )
        }
    }
    
    private func createAnimation(forProperty property: String, toValue: CGFloat, 
                                animationId: String, duration: Double, 
                                delay: Double, easing: String) {
        // Map property name to CALayer keyPath
        let keyPath = mapPropertyToKeyPath(property)
        guard !keyPath.isEmpty else { return }
        
        // Create basic animation
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.toValue = toValue
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        // Apply easing function
        animation.timingFunction = getTimingFunction(easing)
        
        // If an animation for this property already exists, remove it
        if let existingAnimation = activeAnimations[property] {
            layer.removeAnimation(forKey: property)
        }
        
        // Store and apply the animation
        activeAnimations[property] = animation
        layer.add(animation, forKey: property)
        
        // Also set the final value directly for when animation completes
        switch property {
            case "opacity":
                alpha = toValue
            case "translateX", "translateY":
                // These are handled through transform
                if let currentTransform = layer.presentation()?.transform {
                    if property == "translateX" {
                        layer.transform = CATransform3DTranslate(currentTransform, toValue, 0, 0)
                    } else {
                        layer.transform = CATransform3DTranslate(currentTransform, 0, toValue, 0)
                    }
                }
            case "scale":
                layer.transform = CATransform3DMakeScale(toValue, toValue, 1)
            case "rotate":
                layer.transform = CATransform3DMakeRotation(toValue * .pi / 180, 0, 0, 1)
            default:
                break
        }
    }
    
    private func mapPropertyToKeyPath(_ property: String) -> String {
        switch property {
            case "opacity": return "opacity"
            case "translateX": return "transform.translation.x"
            case "translateY": return "transform.translation.y"
            case "scale": return "transform.scale"
            case "scaleX": return "transform.scale.x"
            case "scaleY": return "transform.scale.y"
            case "rotate": return "transform.rotation.z"
            case "width": return "bounds.size.width"
            case "height": return "bounds.size.height"
            default: return ""
        }
    }
    
    private func getTimingFunction(_ easing: String) -> CAMediaTimingFunction {
        switch easing {
            case "linear":
                return CAMediaTimingFunction(name: .linear)
            case "easeIn":
                return CAMediaTimingFunction(name: .easeIn)
            case "easeOut":
                return CAMediaTimingFunction(name: .easeOut)
            case "easeInOut":
                return CAMediaTimingFunction(name: .easeInEaseOut)
            case "elastic":
                // Custom timing function approximating elastic easing
                return CAMediaTimingFunction(controlPoints: 0.5, 0.1, 0.1, 1.0)
            case "bounce":
                // Custom timing function approximating bounce easing
                return CAMediaTimingFunction(controlPoints: 0.5, 0.9, 0.9, 0.95)
            case "back":
                // Custom timing function approximating back easing
                return CAMediaTimingFunction(controlPoints: 0.7, -0.4, 0.7, 1.5)
            default:
                return CAMediaTimingFunction(name: .easeInEaseOut)
        }
    }
}
