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

class DCView: UIView, DCComponent {
    let viewId: String
    
    init(viewId: String) {
        self.viewId = viewId
        super.init(frame: .zero)
        setupDefaults()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func setupDefaults() {
        self.yoga.isEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func handleStateChange(_ newState: [String: Any]) {
        // Base state handling
    }
    
    func applyStyle(_ style: [String: Any]) {
        print("Applying style to view: \(viewId)")
        print("Style config: \(style)")
        
        // Handle layout properties
        if let layout = style["layout"] as? [String: Any] {
            yoga.isEnabled = true
            yoga.applyFlexbox(layout)
            yoga.applySpacing(layout)
        }
        
        // Handle visual properties
        if let backgroundColor = style["backgroundColor"] as? UInt32 {
            self.backgroundColor = UIColor(rgb: backgroundColor)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        print("View frame after style: \(frame)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force size calculation if not set
        if bounds.size == .zero {
            yoga.width = YGValue(value: Float(superview?.bounds.width ?? 0), unit: .point)
            yoga.height = YGValue(value: Float(superview?.bounds.height ?? 0), unit: .point)
        }
        
        yoga.applyLayout(preservingOrigin: true)
        
        // Debug
        print("Layout applied to \(viewId)")
        print("Frame: \(frame)")
        print("Yoga layout: enabled=\(yoga.isEnabled), direction=\(yoga.flexDirection)")
    }
    
    func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        // Base event handling
    }
    
    func captureCurrentState() -> [String: Any] {
        return [:]
    }
}

