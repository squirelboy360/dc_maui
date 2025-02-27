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
        
        // Configure content container - this will hold all the children
        contentContainer.yoga.isEnabled = true
        contentContainer.backgroundColor = .clear
        scrollView.addSubview(contentContainer)
        
        // Basic frame setup
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Default configuration - will be overridden by style properties 
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        
        // Initial container direction
        contentContainer.yoga.flexDirection = .column
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        if let offset = newState["contentOffset"] as? [String: CGFloat] {
            scrollView.contentOffset = CGPoint(
                x: offset["x"] ?? 0,
                y: offset["y"] ?? 0
            )
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        // Apply scroll-specific styles
        if let scrollStyle = style["scrollStyle"] as? [String: Any] {
            // Indicators
            if let showsIndicators = scrollStyle["showsIndicators"] as? Bool {
                scrollView.showsVerticalScrollIndicator = showsIndicators
                scrollView.showsHorizontalScrollIndicator = showsIndicators
            }
            
            // Bounce behavior
            if let bounces = scrollStyle["bounces"] as? Bool {
                scrollView.bounces = bounces
            }
            
            // Paging
            if let pagingEnabled = scrollStyle["pagingEnabled"] as? Bool {
                scrollView.isPagingEnabled = pagingEnabled
            }
            
            // Scroll direction
            if let direction = scrollStyle["direction"] as? String {
                switch direction {
                case "horizontal":
                    contentContainer.yoga.flexDirection = .row
                    scrollView.alwaysBounceHorizontal = true
                    scrollView.alwaysBounceVertical = false
                    
                case "vertical":
                    contentContainer.yoga.flexDirection = .column
                    scrollView.alwaysBounceHorizontal = false
                    scrollView.alwaysBounceVertical = true
                    
                case "both":
                    contentContainer.yoga.flexDirection = .column
                    scrollView.alwaysBounceHorizontal = true
                    scrollView.alwaysBounceVertical = true
                    
                default:
                    break
                }
            }
            
            // Scroll enabled
            if let scrollEnabled = scrollStyle["scrollEnabled"] as? Bool {
                scrollView.isScrollEnabled = scrollEnabled
            }
            
            // Initial scroll position
            if let initialX = scrollStyle["initialScrollX"] as? Double {
                scrollView.contentOffset.x = CGFloat(initialX)
            }
            
            if let initialY = scrollStyle["initialScrollY"] as? Double {
                scrollView.contentOffset.y = CGFloat(initialY)
            }
        }
        
        // Trigger layout update
        setNeedsLayout()
    }

    // Ensure all children are added to the content container
    override func addSubview(_ view: UIView) {
        if view != scrollView {
            contentContainer.addSubview(view)
            setNeedsLayout()
        } else {
            super.addSubview(view)
        }
    }
    
    // Main layout logic
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make scrollView fill our bounds
        scrollView.frame = bounds
        
        // Set content container width/height based on direction for proper scrolling
        let isHorizontal = contentContainer.yoga.flexDirection == .row
        
        // Configure contentContainer dimensions based on scroll direction
        if isHorizontal {
            // For horizontal scrolling:
            // - Height: Fixed to match scrollView
            // - Width: Auto calculated based on content
            contentContainer.yoga.height = YGValue(value: Float(scrollView.bounds.height), unit: .point)
            contentContainer.yoga.width = YGValue(value: 0, unit: .auto)
        } else {
            // For vertical scrolling:
            // - Width: Fixed to match scrollView
            // - Height: Auto calculated based on content
            contentContainer.yoga.width = YGValue(value: Float(scrollView.bounds.width), unit: .point)
            contentContainer.yoga.height = YGValue(value: 0, unit: .auto)
        }
        
        // Apply Yoga layout to position all children
        contentContainer.yoga.applyLayout(preservingOrigin: true)
        
        // Use improved content size calculation that ensures all items are visible
        calculateAndSetContentSizeWithFullVisibility()
    }
    
    // Improved content size calculation to ensure full visibility of all items
    private func calculateAndSetContentSizeWithFullVisibility() {
        // Start with the basic content container size after layout
        let baseContentSize = contentContainer.frame.size
        
        // Add extra space to ensure last item is fully visible - usually this is needed
        // because there might be calculations that don't account for margins, padding, etc.
        let extraBottomSpace: CGFloat = 50  // Add ample padding at the bottom to ensure visibility
        let extraRightSpace: CGFloat = 50   // Same for horizontal scrolling
        
        let isHorizontal = contentContainer.yoga.flexDirection == .row
        var contentSize = baseContentSize
        
        // Calculate bottom padding or right padding depending on scroll direction
        if isHorizontal {
            contentSize.width += extraRightSpace
        } else {
            contentSize.height += extraBottomSpace
        }
        
        // Set the calculated content size to the scroll view
        scrollView.contentSize = contentSize
        
        // Debug output
        print("ScrollView final contentSize: \(scrollView.contentSize)")
        print("  - Base contentSize: \(baseContentSize)")
        print("  - Added padding: \(isHorizontal ? extraRightSpace : extraBottomSpace) to \(isHorizontal ? "right" : "bottom")")
        
        // Debug items positions
        for (index, view) in contentContainer.subviews.enumerated() {
            print("  - Item \(index) frame: \(view.frame)")
        }
    }
    
    func setContent(_ view: DCView) {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        contentContainer.addSubview(view)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
