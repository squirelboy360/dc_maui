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
 DCScrollView: Native scrollable container

 Expected Input Properties:
 {
   "style": {
     "showsIndicators": Bool,     // Show scroll indicators
     "bounces": Bool,            // Enable bounce effect
     "pagingEnabled": Bool      // Enable paging mode
   },
   "layout": {
     // Yoga layout properties for container
   },
   "contentOffset": {           // Programmatic scrolling
     "x": CGFloat,
     "y": CGFloat
   }
 }

 Event Data Emitted:
 onScroll: {
   "offset": {
     "x": CGFloat,             // Horizontal scroll position
     "y": CGFloat              // Vertical scroll position
   },
   "velocity": {
     "x": CGFloat,             // Scroll velocity
     "y": CGFloat
   },
   "contentSize": {
     "width": CGFloat,         // Total content width
     "height": CGFloat         // Total content height
   },
   "timestamp": TimeInterval
 }
 onScrollEnd: {
   "offset": {x, y},
   "timestamp": TimeInterval
 }
*/

class DCScrollView: DCView, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let contentContainer = DCView(viewId: "scroll-content")
    private weak var methodChannel: FlutterMethodChannel?
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        scrollView.delegate = self
    }
    
    override func setupDefaults() {
        super.setupDefaults()
        
        // Configure scrollView
        scrollView.yoga.isEnabled = true
        scrollView.delegate = self
        addSubview(scrollView)
        
        // Configure content container
        contentContainer.yoga.isEnabled = true
        contentContainer.backgroundColor = .clear // Ensure transparent background
        scrollView.addSubview(contentContainer)
        
        // Use frame-based layout instead of Auto Layout constraints
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Configure content container
        contentContainer.yoga.flexDirection = .column
        contentContainer.yoga.alignItems = .stretch
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        if let offset = newState["contentOffset"] as? [String: CGFloat] {
            scrollView.contentOffset = CGPoint(
                x: offset["x"] ?? 0,
                y: offset["y"] ?? 0
            )
        }
    }
    
    // Update the direction handling in applyStyle method
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        // Direct consumption of scrollStyle properties
        if let scrollStyle = style["scrollStyle"] as? [String: Any] {
            print("Applying scroll style: \(scrollStyle)")
            
            if let showsIndicators = scrollStyle["showsIndicators"] as? Bool {
                scrollView.showsVerticalScrollIndicator = showsIndicators
                scrollView.showsHorizontalScrollIndicator = showsIndicators
            }
            
            if let bounces = scrollStyle["bounces"] as? Bool {
                scrollView.bounces = bounces
            }
            
            if let pagingEnabled = scrollStyle["pagingEnabled"] as? Bool {
                scrollView.isPagingEnabled = pagingEnabled
            }
            
            // Handle direction properly
            if let direction = scrollStyle["direction"] as? String {
                // Update content container orientation based on direction
                switch direction {
                case "horizontal":
                    // Configure for horizontal scrolling - only change what's necessary
                    contentContainer.yoga.flexDirection = .row
                    scrollView.alwaysBounceHorizontal = true
                    scrollView.alwaysBounceVertical = false
                    
                case "vertical":
                    // Configure for vertical scrolling - only change what's necessary
                    contentContainer.yoga.flexDirection = .column
                    scrollView.alwaysBounceHorizontal = false
                    scrollView.alwaysBounceVertical = true
                    
                case "both":
                    // Configure for both directions - only change what's necessary
                    contentContainer.yoga.flexDirection = .column // Default to column
                    scrollView.alwaysBounceHorizontal = true
                    scrollView.alwaysBounceVertical = true
                    
                default:
                    break
                }
            }
            
            if let scrollEnabled = scrollStyle["scrollEnabled"] as? Bool {
                scrollView.isScrollEnabled = scrollEnabled
            }
            
            if let initialX = scrollStyle["initialScrollX"] as? Double {
                scrollView.contentOffset.x = CGFloat(initialX)
            }
            
            if let initialY = scrollStyle["initialScrollY"] as? Double {
                scrollView.contentOffset.y = CGFloat(initialY)
            }
        }
        
        // Update layout after applying style
        setNeedsLayout()
    }

    // Simplified addSubview method
    override func addSubview(_ view: UIView) {
        if view != scrollView {
            contentContainer.addSubview(view)
            
            // Let Yoga handle the layout based on properties set in Dart
            setNeedsLayout()
        } else {
            super.addSubview(view)
        }
    }
    
    // Simplified layoutSubviews method
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update scrollView frame to match our bounds
        scrollView.frame = bounds
        
        // Let Yoga handle the layout entirely based on the properties set from Dart
        contentContainer.yoga.applyLayout(preservingOrigin: true)
        
        // Update content size after layout
        updateContentSize()
    }

    // Simplified updateContentSize method
    private func updateContentSize() {
        // Let the content container determine its own size based on children and layout properties
        // Apply the yoga layout first to calculate proper sizes
        contentContainer.yoga.applyLayout(preservingOrigin: true)
        
        // Base content size on the actual frame of the content container after layout
        var contentSize = contentContainer.frame.size
        
        // Ensure the content size is at least as large as the scroll view bounds
        contentSize.width = max(contentSize.width, scrollView.bounds.width)
        contentSize.height = max(contentSize.height, scrollView.bounds.height)
        
        // Apply to scroll view
        scrollView.contentSize = contentSize
        
        print("ScrollView content size: \(scrollView.contentSize)")
    }

    func setContent(_ view: DCView) {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        contentContainer.addSubview(view)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("Scroll position: \(scrollView.contentOffset)")
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onScroll",
            "data": [
                "offset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "velocity": [
                    "x": scrollView.panGestureRecognizer.velocity(in: scrollView).x,
                    "y": scrollView.panGestureRecognizer.velocity(in: scrollView).y
                ],
                "contentSize": [
                    "width": scrollView.contentSize.width,
                    "height": scrollView.contentSize.height
                ],
                "viewportSize": [
                    "width": scrollView.bounds.width,
                    "height": scrollView.bounds.height
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Scroll ended at: \(scrollView.contentOffset)")
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onScrollEnd",
            "data": [
                "offset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
}
