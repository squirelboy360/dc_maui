//
//  DCTouchable.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// A touchable view that provides touch feedback
class DCTouchable: DCBaseView {
    private var pressedOpacity: CGFloat = 0.2
    private var originalAlpha: CGFloat = 1.0
    private var pressedDuration: TimeInterval = 0.1
    private var hitSlop: UIEdgeInsets = .zero
    
    override func setupView() {
        super.setupView()
        
        // Configure basic touch handling
        isUserInteractionEnabled = true
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        // Add long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleTap() {
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onPress", data: nil)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let viewId = self.viewId else { return }
        
        if gesture.state == .began {
            MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onLongPress", data: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Save original alpha if we haven't yet
        originalAlpha = alpha
        
        // Apply pressed state visual feedback
        UIView.animate(withDuration: 0.1) {
            self.alpha = self.originalAlpha * (1.0 - self.pressedOpacity)
        }
        
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onPressIn", data: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // Restore original appearance
        UIView.animate(withDuration: pressedDuration) {
            self.alpha = self.originalAlpha
        }
        
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onPressOut", data: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        // Restore original appearance
        UIView.animate(withDuration: pressedDuration) {
            self.alpha = self.originalAlpha
        }
        
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onPressOut", data: false)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Extend touchable area with hit slop
        let hitFrame = bounds.inset(by: UIEdgeInsets(
            top: -hitSlop.top,
            left: -hitSlop.left,
            bottom: -hitSlop.bottom,
            right: -hitSlop.right
        ))
        return hitFrame.contains(point)
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle enabled state
        if let disabled = props["disabled"] as? Bool {
            isUserInteractionEnabled = !disabled
            alpha = disabled ? 0.5 : 1.0
            originalAlpha = alpha
        }
        
        // Apply style properties
        if let style = props["style"] as? [String: Any] {
            // Handle pressed opacity (iOS specific)
            if let opacity = style["pressedOpacity"] as? CGFloat {
                pressedOpacity = opacity
            }
            
            // Handle animation duration
            if let duration = style["pressedDuration"] as? TimeInterval {
                pressedDuration = duration / 1000.0  // Convert from ms to seconds
            }
            
            // Handle hit slop
            var newHitSlop = UIEdgeInsets.zero
            if let top = style["hitSlopTop"] as? CGFloat {
                newHitSlop.top = top
            }
            if let bottom = style["hitSlopBottom"] as? CGFloat {
                newHitSlop.bottom = bottom
            }
            if let left = style["hitSlopLeft"] as? CGFloat {
                newHitSlop.left = left
            }
            if let right = style["hitSlopRight"] as? CGFloat {
                newHitSlop.right = right
            }
            hitSlop = newHitSlop
        }
        
        // Handle delay for long press
        if let delayLongPress = props["delayLongPress"] as? TimeInterval {
            for gesture in gestureRecognizers ?? [] {
                if let longPress = gesture as? UILongPressGestureRecognizer {
                    longPress.minimumPressDuration = delayLongPress / 1000.0  // Convert from ms to seconds
                }
            }
        }
    }
}
