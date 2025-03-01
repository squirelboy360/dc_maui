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
 DCSafeAreaView: Container that respects safe area insets

 Expected Input Properties:
 {
   "style": {
     "edges": {                 // Which edges to respect safe area
       "top": Bool,            // Respect top safe area (status bar/notch)
       "left": Bool,           // Respect left safe area
       "right": Bool,          // Respect right safe area
       "bottom": Bool         // Respect bottom safe area (home indicator)
     },
     "backgroundColor": UInt32 // Background color as ARGB
   },
   "layout": {
     // All Yoga layout properties supported
     // Padding is automatically adjusted based on safe area insets
   }
 }

 Automatic Behaviors:
 - Automatically updates padding when safe area changes (device rotation)
 - Handles all iOS safe areas (notch, home indicator, etc)
 - Can selectively enable/disable specific edges
 - Maintains child layout relative to safe area
 
 Common Use Cases:
 - Root container for full-screen content
 - Navigation bars and bottom tabs
 - Side menus that respect safe areas
 - Modal content with proper insets
 */

class DCSafeAreaView: DCView {
    private var edges: UIEdgeInsets = .zero
    
    override func setupDefaults() {
        super.setupDefaults()
        updateSafeAreaInsets()
    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        updateSafeAreaInsets()
    }
    
    private func updateSafeAreaInsets() {
        let safeArea = self.safeAreaInsets
        
        // Apply safe area as padding
        yoga.paddingTop = YGValue(value: Float(safeArea.top), unit: .point)
        yoga.paddingLeft = YGValue(value: Float(safeArea.left), unit: .point)
        yoga.paddingBottom = YGValue(value: Float(safeArea.bottom), unit: .point)
        yoga.paddingRight = YGValue(value: Float(safeArea.right), unit: .point)
        
        yoga.applyLayout(preservingOrigin: true)
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let edges = style["edges"] as? [String: Bool] {
            var insets = UIEdgeInsets.zero
            
            if edges["top"] == true {
                insets.top = safeAreaInsets.top
            }
            if edges["left"] == true {
                insets.left = safeAreaInsets.left
            }
            if edges["bottom"] == true {
                insets.bottom = safeAreaInsets.bottom
            }
            if edges["right"] == true {
                insets.right = safeAreaInsets.right
            }
            
            self.edges = insets
            updateSafeAreaInsets()
        }
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        // Handle edges configuration
        if let edges = newState["edges"] as? [String: Bool] {
            var insets = UIEdgeInsets.zero
            
            if edges["top"] == true {
                insets.top = safeAreaInsets.top
            }
            if edges["left"] == true {
                insets.left = safeAreaInsets.left
            }
            if edges["bottom"] == true {
                insets.bottom = safeAreaInsets.bottom
            }
            if edges["right"] == true {
                insets.right = safeAreaInsets.right
            }
            
            self.edges = insets
            updateSafeAreaInsets()
        }
        
        // Handle individual edge states
        if let topEnabled = newState["topEdgeEnabled"] as? Bool {
            var newEdges = self.edges
            newEdges.top = topEnabled ? safeAreaInsets.top : 0
            self.edges = newEdges
            updateSafeAreaInsets()
        }
        
        if let bottomEnabled = newState["bottomEdgeEnabled"] as? Bool {
            var newEdges = self.edges
            newEdges.bottom = bottomEnabled ? safeAreaInsets.bottom : 0
            self.edges = newEdges
            updateSafeAreaInsets()
        }
    }

    override func captureCurrentState() -> [String: Any] {
        var state = super.captureCurrentState()
        
        // Capture which edges are being respected
        state["edges"] = [
            "top": edges.top > 0,
            "left": edges.left > 0,
            "bottom": edges.bottom > 0,
            "right": edges.right > 0
        ]
        
        // Add individual edge states
        state["topEdgeEnabled"] = edges.top > 0
        state["leftEdgeEnabled"] = edges.left > 0
        state["bottomEdgeEnabled"] = edges.bottom > 0
        state["rightEdgeEnabled"] = edges.right > 0
        
        return state
    }
}
