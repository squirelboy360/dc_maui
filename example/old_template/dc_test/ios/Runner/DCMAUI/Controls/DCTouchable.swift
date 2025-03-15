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
    private var activeOpacity: CGFloat = 0.2
    private var defaultOpacity: CGFloat = 1.0
    private weak var methodChannel: FlutterMethodChannel?
    private var delaysContentTouches: Bool = false
    private var cancelsTouchesInView: Bool = true
    
    override func setupDefaults() {
        super.setupDefaults()
        isUserInteractionEnabled = true
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        if let enabled = newState["enabled"] as? Bool {
            self.isUserInteractionEnabled = enabled
            // Visual feedback
            self.alpha = enabled ? 1.0 : 0.6
        }
        
        if let activeOpacity = newState["activeOpacity"] as? CGFloat {
            self.activeOpacity = activeOpacity
        }
        
        // Support direct passing of state key buttonText to child text component
        if let buttonText = newState["buttonText"] as? String {
            // Find child text components and update their text
            for subview in subviews {
                if let textView = subview as? DCText {
                    textView.handleStateChange(["text": buttonText])
                }
            }
        }
    }
    
    override func captureCurrentState() -> [String: Any] {
        var state = super.captureCurrentState()
        state["enabled"] = self.isUserInteractionEnabled
        state["activeOpacity"] = self.activeOpacity
        
        // Get text from child text component if exists
        for subview in subviews {
            if let textView = subview as? DCText {
                let textState = textView.captureCurrentState()
                if let text = textState["text"] as? String {
                    state["buttonText"] = text
                }
            }
        }
        
        return state
    }
    
    override func applyStyle(_ style: [String: Any]) {
        // First apply base view styles
        super.applyStyle(style)
        
        if let touchableStyle = style["touchableStyle"] as? [String: Any] {
            print("Applying touchable style: \(touchableStyle)")
            
            if let activeOpacity = touchableStyle["activeOpacity"] as? CGFloat {
                self.activeOpacity = activeOpacity
            }
            
            if let enabled = touchableStyle["enabled"] as? Bool {
                self.isUserInteractionEnabled = enabled
            }
            
            if let delaysContent = touchableStyle["delaysContentTouches"] as? Bool {
                self.delaysContentTouches = delaysContent
            }
            
            if let cancelsTouch = touchableStyle["cancelsTouchesInView"] as? Bool {
                self.cancelsTouchesInView = cancelsTouch
            }
        }
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        print("Setting up events for touchable: \(viewId)")
        print("Events config: \(events)")
        self.methodChannel = channel
        
        // Map each event type to its gesture recognizer
        if (events["onPress"] as? Bool) == true {
            print("Setting up tap gesture for: \(viewId)")
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tap)
        }
        
        if (events["onLongPress"] as? Bool) == true {
            print("Setting up long press gesture for: \(viewId)")
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            addGestureRecognizer(longPress)
        }
    }
    
    private func sendEvent(_ type: String) {
        print("Sending event: \(type) for view: \(viewId)")
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": type,
            "data": [
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
    
    @objc private func handleTap() {
        print("Tap detected for: \(viewId)")
        sendEvent("onPress")
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onLongPress",
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Touch began for: \(viewId)")
        sendEvent("onPressIn")
        animate(to: activeOpacity)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("Touch ended for: \(viewId)")
        sendEvent("onPressOut")
        animate(to: defaultOpacity)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        print("Touch cancelled for: \(viewId)")
        sendEvent("onPressOut")
        animate(to: defaultOpacity)
    }
    
    private func animate(to opacity: CGFloat) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction) {
            self.alpha = opacity
        }
    }
}
