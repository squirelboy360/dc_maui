//
//  DCGestureDetector.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// GestureDetector component that handles various touch/gesture events
class DCGestureDetector: DCBaseView {
    private var tapGesture: UITapGestureRecognizer?
    private var doubleTapGesture: UITapGestureRecognizer?
    private var panGesture: UIPanGestureRecognizer?
    private var pinchGesture: UIPinchGestureRecognizer?
    private var rotationGesture: UIRotationGestureRecognizer?
    
    override func setupView() {
        super.setupView()
        
        // We don't add any gestures by default - we'll add them based on props
        isUserInteractionEnabled = true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Enable/disable all gestures
        if let enabled = props["enabled"] as? Bool {
            isUserInteractionEnabled = enabled
        }
        
        // Configure tap gesture
        if props["onTap"] != nil && tapGesture == nil {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            addGestureRecognizer(tapGesture!)
            
            // If we have both tap and double tap, make them work together
            if doubleTapGesture != nil {
                tapGesture?.require(toFail: doubleTapGesture!)
            }
        }
        
        // Configure double tap gesture
        if props["onDoubleTap"] != nil && doubleTapGesture == nil {
            doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapGesture?.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTapGesture!)
            
            // If we have both tap and double tap, make them work together
            if tapGesture != nil {
                tapGesture?.require(toFail: doubleTapGesture!)
            }
        }
        
        // Configure pan gesture
        if (props["onPan"] != nil || props["onPanStart"] != nil || 
            props["onPanUpdate"] != nil || props["onPanEnd"] != nil) && panGesture == nil {
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            addGestureRecognizer(panGesture!)
        }
        
        // Configure pinch gesture
        if (props["onPinch"] != nil || props["onPinchStart"] != nil || 
            props["onPinchUpdate"] != nil || props["onPinchEnd"] != nil) && pinchGesture == nil {
            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            addGestureRecognizer(pinchGesture!)
        }
        
        // Configure rotation gesture
        if props["onRotate"] != nil && rotationGesture == nil {
            rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
            addGestureRecognizer(rotationGesture!)
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onTap",
                params: [:]
            )
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onDoubleTap",
                params: [:]
            )
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        let data: [String: Any] = [
            "x": translation.x,
            "y": translation.y,
            "velocityX": velocity.x,
            "velocityY": velocity.y
        ]
        
        switch gesture.state {
        case .began:
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onPanStart",
                params: data
            )
        case .changed:
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onPanUpdate",
                params: data
            )
        case .ended, .cancelled:
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onPanEnd",
                params: data
            )
        default:
            break
        }
        
        // Also send general pan event for compatibility
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onPan",
            params: data
        )
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        let velocity = gesture.velocity
        
        let data: [String: Any] = [
            "scale": scale,
            "velocity": velocity
        ]
        
        switch gesture.state {
        case .began:
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onPinchStart",
                params: ["scale": scale]
            )
        case .changed:
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onPinchUpdate",
                params: ["scale": scale]
            )
        case .ended, .cancelled:
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onPinchEnd",
                params: ["scale": scale]
            )
        default:
            break
        }
        
        // Also send general pinch event for compatibility
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onPinch",
            params: data
        )
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        let rotation = gesture.rotation
        
        // Convert rotation from radians to degrees for consistency with Dart
        let degrees = rotation * 180.0 / .pi
        
        if gesture.state == .changed || gesture.state == .ended {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onRotate",
                params: ["rotation": degrees]
            )
        }
    }
}
