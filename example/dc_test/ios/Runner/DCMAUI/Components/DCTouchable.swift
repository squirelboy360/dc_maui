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
    private var eventCallbacks: [String: () -> Void] = [:] // Add storage for callbacks
    
    override func setupDefaults() {
        super.setupDefaults()
        isUserInteractionEnabled = true
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        
        if events["onPress"] != nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tap)
        }
        
        if events["onLongPress"] != nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            addGestureRecognizer(longPress)
        }
    }
    
    @objc private func handleTap() {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPress",
            "timestamp": Date().timeIntervalSince1970
        ])
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
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressIn",
            "timestamp": Date().timeIntervalSince1970
        ])
        animate(to: activeOpacity)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressOut",
            "timestamp": Date().timeIntervalSince1970
        ])
        animate(to: defaultOpacity)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressOut",
            "timestamp": Date().timeIntervalSince1970
        ])
        animate(to: defaultOpacity)
    }
    
    private func animate(to opacity: CGFloat) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction) {
            self.alpha = opacity
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let activeOpacity = style["activeOpacity"] as? CGFloat {
            self.activeOpacity = activeOpacity
        }
    }
}
