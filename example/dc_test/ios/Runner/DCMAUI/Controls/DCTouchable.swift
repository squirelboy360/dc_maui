/*
 BSD 3-Clause License

Copyright (c) 2025, Tahiru Agbanwa

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit

/**
 DCTouchable: Native touchable component with press feedback

 Expected Input Properties:
 {
   "style": {
     "activeOpacity": CGFloat,     // Opacity when pressed (0-1)
     "backgroundColor": UInt32,    // Background color as ARGB
     "cornerRadius": CGFloat,      // Corner radius in points
   },
   "layout": {
     // Yoga layout properties
   },
   "events": {
     "onPress": true,             // Single tap
     "onLongPress": true,         // Long press
     "onPressIn": true,          // Touch down
     "onPressOut": true          // Touch up/cancel
   }
 }

 Event Data Emitted:
 onPress: {
   "timestamp": TimeInterval
 }
 onLongPress: {
   "timestamp": TimeInterval
 }
 onPressIn: {
   "timestamp": TimeInterval
 }
 onPressOut: {
   "timestamp": TimeInterval
 }
*/

class DCTouchable: DCView {
    private weak var methodChannel: FlutterMethodChannel?
    private var longPressGesture: UILongPressGestureRecognizer?
    private var initialTouchLocation: CGPoint = .zero
    private var pressStartTime: TimeInterval = 0
    
    // Configurable properties from TouchableStyle
    private var activeOpacity: CGFloat = 0.2
    private var isDisabled: Bool = false
    private var underlayColor: UIColor?
    private var pressedScale: CGFloat = 0.98
    private var animationDuration: TimeInterval = 0.1
    private var hasHapticFeedback: Bool = true
    
    override func setupDefaults() {
        super.setupDefaults()
        setupGestureRecognizers()
        clipsToBounds = true
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let touchableStyle = style["touchableStyle"] as? [String: Any] {
            print("Applying touchable style: \(touchableStyle)")
            
            if let activeOpacity = touchableStyle["activeOpacity"] as? CGFloat {
                self.activeOpacity = activeOpacity
            }
            
            if let disabled = touchableStyle["disabled"] as? Bool {
                self.isDisabled = disabled
                self.isUserInteractionEnabled = !disabled
            }
            
            if let underlayColor = touchableStyle["underlayColor"] as? UInt32 {
                self.underlayColor = UIColor(rgb: underlayColor)
            }
            
            if let pressedScale = touchableStyle["pressedScale"] as? CGFloat {
                self.pressedScale = pressedScale
            }
            
            if let duration = touchableStyle["pressAnimationDuration"] as? TimeInterval {
                self.animationDuration = duration / 1000 // Convert from ms to seconds
            }
            
            if let haptic = touchableStyle["hasHapticFeedback"] as? Bool {
                self.hasHapticFeedback = haptic
            }
        }
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
    }
    
    private func setupGestureRecognizers() {
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        // Long press gesture
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        if let longPress = longPressGesture {
            addGestureRecognizer(longPress)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDisabled, let touch = touches.first else { return }
        
        initialTouchLocation = touch.location(in: self)
        pressStartTime = Date().timeIntervalSince1970
        
        // Handle press in
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressIn",
            "data": [
                "timestamp": pressStartTime,
                "position": [
                    "x": initialTouchLocation.x,
                    "y": initialTouchLocation.y
                ]
            ]
        ])
        
        // Animate press
        animatePress(isPressed: true)
        
        // Haptic feedback
        if hasHapticFeedback {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDisabled else { return }
        handleTouchEnd(touches, cancelled: false)
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDisabled else { return }
        handleTouchEnd(touches, cancelled: true)
        super.touchesCancelled(touches, with: event)
    }
    
    private func handleTouchEnd(_ touches: Set<UITouch>, cancelled: Bool) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let endTime = Date().timeIntervalSince1970
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressOut",
            "data": [
                "duration": endTime - pressStartTime,
                "position": ["x": location.x, "y": location.y],
                "cancelled": cancelled,
                "timestamp": endTime
            ]
        ])
        
        animatePress(isPressed: false)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard !isDisabled else { return }
        
        let location = gesture.location(in: self)
        let currentTime = Date().timeIntervalSince1970
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPress",
            "data": [
                "duration": currentTime - pressStartTime,
                "position": ["x": location.x, "y": location.y],
                "timestamp": currentTime
            ]
        ])
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard !isDisabled else { return }
        
        if gesture.state == .began {
            let location = gesture.location(in: self)
            let currentTime = Date().timeIntervalSince1970
            
            methodChannel?.invokeMethod("onComponentEvent", arguments: [
                "viewId": viewId,
                "type": "onLongPress",
                "data": [
                    "duration": currentTime - pressStartTime,
                    "position": ["x": location.x, "y": location.y],
                    "timestamp": currentTime
                ]
            ])
            
            if hasHapticFeedback {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
        }
    }
    
    private func animatePress(isPressed: Bool) {
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.alpha = isPressed ? self.activeOpacity : 1.0
            self.transform = isPressed ? CGAffineTransform(scaleX: self.pressedScale, y: self.pressedScale) : .identity
            if let color = self.underlayColor {
                self.backgroundColor = isPressed ? color : self.backgroundColor
            }
        }
    }
}
