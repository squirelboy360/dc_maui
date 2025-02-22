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
import YogaKit

/**
 DCButton: Native button component

 Expected Input Properties:
 {
   "style": {
     "textStyle": {
       "text": String,              // Button text
       "color": UInt32,            // Text color as ARGB
       "fontSize": CGFloat         // Font size in points
     },
     backgroundColor: UInt32,      // Background color as ARGB
     cornerRadius: CGFloat,        // Corner radius in points
     opacity: CGFloat             // Button opacity (0-1)
   },
   "layout": {
     // All Yoga layout properties supported
     "width": YGValue,            // Points or percentage
     "height": YGValue,           // Points or percentage
     "margin": EdgeInsets,        // Spacing around button
     "padding": EdgeInsets        // Internal button padding
   },
   "events": {
     "onClick": true,             // Touch up inside
     "onPressIn": true,          // Touch down
     "onPressOut": true          // Touch up/cancel
   }
 }

 Event Data Emitted:
 onClick: {
   "duration": Double,           // Press duration in seconds
   "position": {                 // Touch position
     "x": CGFloat,
     "y": CGFloat
   },
   "timestamp": TimeInterval     // Event timestamp
 }
 onPressIn: {
   "position": {x, y},          // Initial touch position
   "timestamp": TimeInterval
 }
 onPressOut: {
   "duration": Double,          // Total press duration
   "position": {x, y},         // Final touch position
   "timestamp": TimeInterval
 }
*/

class DCButton: DCView {
    private let button = UIButton(type: .system)
    private weak var methodChannel: FlutterMethodChannel?
    private var pressStartTime: TimeInterval = 0
    
    override func setupDefaults() {
        super.setupDefaults()
        
        button.yoga.isEnabled = true
        addSubview(button)
        
        // Fill parent
        button.yoga.position = .absolute
        button.yoga.left = YGValue.zero
        button.yoga.top = YGValue.zero
        button.yoga.right = YGValue.zero
        button.yoga.bottom = YGValue.zero
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        
        if events["onClick"] != nil {
            button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        }
        if events["onPressIn"] != nil {
            button.addTarget(self, action: #selector(handlePressIn), for: .touchDown)
        }
        if events["onPressOut"] != nil {
            button.addTarget(self, action: #selector(handlePressOut), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }
    
    @objc private func handleTap(_ sender: UIButton) {
        let pressTime = Date().timeIntervalSince1970 - pressStartTime
        let touchPoint = sender.convert(CGPoint.zero, to: nil)
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onClick",
            "data": [
                "duration": pressTime,
                "position": [
                    "x": touchPoint.x,
                    "y": touchPoint.y
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
    
    @objc private func handlePressIn(_ sender: UIButton) {
        pressStartTime = Date().timeIntervalSince1970
        let touchPoint = sender.convert(CGPoint.zero, to: nil)
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressIn",
            "data": [
                "position": [
                    "x": touchPoint.x,
                    "y": touchPoint.y
                ],
                "timestamp": pressStartTime
            ]
        ])
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.7
        }
    }
    
    @objc private func handlePressOut(_ sender: UIButton) {
        let endTime = Date().timeIntervalSince1970
        let touchPoint = sender.convert(CGPoint.zero, to: nil)
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressOut",
            "data": [
                "duration": endTime - pressStartTime,
                "position": [
                    "x": touchPoint.x,
                    "y": touchPoint.y
                ],
                "timestamp": endTime
            ]
        ])
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let textStyle = style["textStyle"] as? [String: Any] {
            if let text = textStyle["text"] as? String {
                button.setTitle(text, for: .normal)
            }
            if let color = textStyle["color"] as? UInt32 {
                button.setTitleColor(UIColor(rgb: color), for: .normal)
            }
            if let fontSize = textStyle["fontSize"] as? CGFloat {
                button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .semibold)
            }
        }
    }
}
