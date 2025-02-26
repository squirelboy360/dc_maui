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
                    // Configure for horizontal scrolling
                    contentContainer.yoga.flexDirection = .row
                    scrollView.alwaysBounceHorizontal = true
                    scrollView.alwaysBounceVertical = false
                    
                    // Don't set yoga dimensions directly - will cause crash with YGValueUndefined
                    // Instead, set frame dimensions after layout
                    if bounds.height > 0 {
                        contentContainer.frame.size.height = scrollView.bounds.height
                    }
                case "vertical":
                    // Configure for vertical scrolling
                    contentContainer.yoga.flexDirection = .column
                    scrollView.alwaysBounceHorizontal = false
                    scrollView.alwaysBounceVertical = true
                    
                    // Don't set yoga dimensions directly
                    if bounds.width > 0 {
                        contentContainer.frame.size.width = scrollView.bounds.width
                    }
                case "both":
                    // Configure for both directions
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

    override func addSubview(_ view: UIView) {
        if view != scrollView {
            print("DCScrollView: Adding child view to content container")
            contentContainer.addSubview(view)
            
            // Force layout when a child is added
            view.yoga.applyLayout(preservingOrigin: true)
            contentContainer.yoga.applyLayout(preservingOrigin: true)
            
            // Update scroll content size
            updateContentSize()
        } else {
            super.addSubview(view)
        }
    }
    
    // Override to ensure yoga layout is applied properly
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update scrollView frame to match our bounds
        scrollView.frame = bounds
        
        // Configure content container based on orientation
        let isHorizontal = contentContainer.yoga.flexDirection == .row
        
        if isHorizontal {
            // For horizontal scrolling, fix the height but allow width to be determined by content
            contentContainer.frame.size.height = scrollView.bounds.height
        } else {
            // For vertical scrolling, fix the width but allow height to be determined by content
            contentContainer.frame.size.width = scrollView.bounds.width
        }
        
        // Apply yoga layout to content container and its children
        contentContainer.yoga.applyLayout(preservingOrigin: true)
        
        // Update content size after layout
        updateContentSize()
    }

    private func updateContentSize() {
        // Check if we're in horizontal or vertical mode
        let isHorizontal = contentContainer.yoga.flexDirection == .row
        
        if contentContainer.subviews.isEmpty {
            // If no subviews, use default size
            contentContainer.frame.size = scrollView.bounds.size
            scrollView.contentSize = scrollView.bounds.size
            return
        }
        
        if isHorizontal {
            // Horizontal scroll view content size calculation
            updateHorizontalContentSize()
        } else {
            // Vertical scroll view content size calculation
            updateVerticalContentSize()
        }
    }

    private func updateHorizontalContentSize() {
        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = scrollView.bounds.height
        
        // Calculate actual content width including margins and padding
        let subviews = contentContainer.subviews.sorted(by: { $0.frame.minX < $1.frame.minX })
        
        // Find first and last view for accurate total width calculation
        if let firstView = subviews.first, let lastView = subviews.last {
            // Calculate total width from left of first view to right of last view
            totalWidth = (lastView.frame.maxX - firstView.frame.minX)
            
            // Add left margin/padding of first view
            if let firstDCView = firstView as? DCView {
                if firstDCView.yoga.paddingLeft.unit != .undefined {
                    totalWidth += CGFloat(firstDCView.yoga.paddingLeft.value)
                }
                if firstDCView.yoga.marginLeft.unit != .undefined {
                    totalWidth += CGFloat(firstDCView.yoga.marginLeft.value)
                }
            }
            
            // Add right margin/padding of last view
            if let lastDCView = lastView as? DCView {
                if lastDCView.yoga.paddingRight.unit != .undefined {
                    totalWidth += CGFloat(lastDCView.yoga.paddingRight.value)
                }
                if lastDCView.yoga.marginRight.unit != .undefined {
                    totalWidth += CGFloat(lastDCView.yoga.marginRight.value)
                }
            }
        }
        
        // Add content container's own padding
        if contentContainer.yoga.paddingLeft.unit != .undefined {
            totalWidth += CGFloat(contentContainer.yoga.paddingLeft.value)
        }
        if contentContainer.yoga.paddingRight.unit != .undefined {
            totalWidth += CGFloat(contentContainer.yoga.paddingRight.value)
        }
        
        // Find maximum height needed
        for subview in contentContainer.subviews {
            let subviewHeight = subview.frame.maxY
            maxHeight = max(maxHeight, subviewHeight)
            
            // Account for bottom padding/margin if available
            if let dcView = subview as? DCView {
                if dcView.yoga.paddingBottom.unit != .undefined {
                    maxHeight += CGFloat(dcView.yoga.paddingBottom.value)
                }
                if dcView.yoga.marginBottom.unit != .undefined {
                    maxHeight += CGFloat(dcView.yoga.marginBottom.value)
                }
            }
        }
        
        // Add extra padding at the right to ensure last item is fully visible
        let extraRightPadding: CGFloat = 50.0
        totalWidth += extraRightPadding
        
        // Ensure minimum sizes
        totalWidth = max(totalWidth, scrollView.bounds.width)
        maxHeight = max(maxHeight, scrollView.bounds.height)
        
        // Apply calculated sizes
        contentContainer.frame.size = CGSize(width: totalWidth, height: maxHeight)
        scrollView.contentSize = contentContainer.frame.size
        
        print("Horizontal ScrollView content size: \(scrollView.contentSize)")
    }

    private func updateVerticalContentSize() {
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = scrollView.bounds.width
        
        // Calculate actual content height including margins and padding
        let subviews = contentContainer.subviews.sorted(by: { $0.frame.minY < $1.frame.minY })
        
        // Find first and last view for accurate total height calculation
        if let firstView = subviews.first, let lastView = subviews.last {
            // Calculate total height from top of first view to bottom of last view
            totalHeight = (lastView.frame.maxY - firstView.frame.minY)
            
            // Add top margin/padding of first view
            if let firstDCView = firstView as? DCView {
                // Add top padding from yoga if available
                if firstDCView.yoga.paddingTop.unit != .undefined {
                    totalHeight += CGFloat(firstDCView.yoga.paddingTop.value)
                }
                // Add top margin from yoga if available
                if firstDCView.yoga.marginTop.unit != .undefined {
                    totalHeight += CGFloat(firstDCView.yoga.marginTop.value)
                }
            }
            
            // Add bottom margin/padding of last view
            if let lastDCView = lastView as? DCView {
                // Add bottom padding from yoga if available
                if lastDCView.yoga.paddingBottom.unit != .undefined {
                    totalHeight += CGFloat(lastDCView.yoga.paddingBottom.value)
                }
                // Add bottom margin from yoga if available
                if lastDCView.yoga.marginBottom.unit != .undefined {
                    totalHeight += CGFloat(lastDCView.yoga.marginBottom.value)
                }
            }
        }
        
        // Add content container's own padding
        if contentContainer.yoga.paddingTop.unit != .undefined {
            totalHeight += CGFloat(contentContainer.yoga.paddingTop.value)
        }
        if contentContainer.yoga.paddingBottom.unit != .undefined {
            totalHeight += CGFloat(contentContainer.yoga.paddingBottom.value)
        }
        
        // Find maximum width needed
        for subview in contentContainer.subviews {
            let subviewWidth = subview.frame.maxX
            maxWidth = max(maxWidth, subviewWidth)
            
            // Account for right padding/margin if available
            if let dcView = subview as? DCView {
                if dcView.yoga.paddingRight.unit != .undefined {
                    maxWidth += CGFloat(dcView.yoga.paddingRight.value)
                }
                if dcView.yoga.marginRight.unit != .undefined {
                    maxWidth += CGFloat(dcView.yoga.marginRight.value)
                }
            }
        }
        
        // Account for content container's right padding
        if contentContainer.yoga.paddingRight.unit != .undefined {
            maxWidth += CGFloat(contentContainer.yoga.paddingRight.value)
        }
        
        // Add extra padding at the bottom to ensure last item is fully visible
        // This accounts for potential inaccuracies in margin calculations
        let extraBottomPadding: CGFloat = 50.0
        totalHeight += extraBottomPadding
        
        // Ensure minimum sizes
        totalHeight = max(totalHeight, scrollView.bounds.height)
        maxWidth = max(maxWidth, scrollView.bounds.width)
        
        // Apply calculated sizes
        contentContainer.frame.size = CGSize(width: maxWidth, height: totalHeight)
        scrollView.contentSize = contentContainer.frame.size
        
        print("Vertical ScrollView content size: \(scrollView.contentSize)")
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
