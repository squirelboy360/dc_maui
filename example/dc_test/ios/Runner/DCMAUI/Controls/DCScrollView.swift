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
import Flutter

class DCScrollView: DCView, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var didSetupScrollView = false
    private var scrollDirection: UIScrollView.Direction = .vertical
    private var lastContentOffset: CGPoint = .zero
    private var methodChannel: FlutterMethodChannel?
    
    enum ScrollEvent: String {
        case onScroll
        case onScrollBegin
        case onScrollEnd
        case onMomentumScrollBegin
        case onMomentumScrollEnd
        case onEndReached
    }
    
    override init(viewId: String) {
        super.init(viewId: viewId)
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.bounces = true
        scrollView.clipsToBounds = true
        
        // Set a clear background to see through to parents
        scrollView.backgroundColor = .clear
        
        // Setup the content view
        contentView.yoga.isEnabled = true
        contentView.backgroundColor = .clear
        
        // Ensure content view has a minimum size
        contentView.yoga.minHeight = YGValue(value: 1, unit: .point)
        contentView.yoga.minWidth = YGValue(value: 1, unit: .point)
        
        scrollView.addSubview(contentView)
        addSubview(scrollView)
        
        didSetupScrollView = true
    }
    
    private func getContentWidth() -> CGFloat {
        return scrollView.bounds.width - 32 // 16pt padding on each side
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set the scroll view to fill the DCScrollView bounds
        scrollView.frame = bounds
        
        // For vertical scrolling, content view should have fixed width matching the scroll view
        if scrollDirection == .vertical {
            contentView.frame.size.width = scrollView.bounds.width
        }
        
        // Apply yoga layout to the content view 
        contentView.yoga.applyLayout(preservingOrigin: true)
        
        print("DCScrollView layout: frame=\(frame), bounds=\(bounds)")
        print("ScrollView frame: \(scrollView.frame), contentSize before: \(scrollView.contentSize)")
        print("ContentView frame: \(contentView.frame), subviews count: \(contentView.subviews.count)")
        
        // Calculate content size based on children for proper scrolling
        if scrollDirection == .vertical {
            // Find the maximum Y position of all subviews to determine content height
            var maxY: CGFloat = 0
            
            // Print each child's frame for debugging
            for (index, subview) in contentView.subviews.enumerated() {
                print("Child \(index) frame before: \(subview.frame), yoga.width=\(subview.yoga.width)")
                
                // Ensure horizontal positioning is correct
                if subview.yoga.alignSelf.rawValue == YGAlign.center.rawValue {
                    // Center horizontally
                    subview.center.x = contentView.frame.width / 2
                }
                
                // Handle percentage widths
                if subview.yoga.width.unit == .percent {
                    let percentWidth = CGFloat(subview.yoga.width.value) / 100.0
                    let newWidth = contentView.bounds.width * percentWidth
                    subview.frame.size.width = newWidth
                }
                
                // Update max Y position for content height calculation
                let subviewMaxY = subview.frame.maxY
                if subviewMaxY > maxY {
                    maxY = subviewMaxY
                }
                
                print("Child \(index) frame after: \(subview.frame)")
            }
            
            // Add padding to ensure scrolling works well
            maxY += 20
            
            // Update scroll view content size to allow for proper scrolling
            scrollView.contentSize = CGSize(
                width: contentView.bounds.width,
                height: max(maxY, bounds.height + 1)  // Ensure scrollable even with small content
            )
            
            // Update content view frame to match the content size
            contentView.frame.size = CGSize(width: contentView.frame.width, height: maxY)
        } else if scrollDirection == .horizontal {
            // For horizontal scrolling, we need to calculate the total width
            var maxX: CGFloat = 0
            for subview in contentView.subviews {
                let subviewMaxX = subview.frame.maxX
                if subviewMaxX > maxX {
                    maxX = subviewMaxX
                }
            }
            
            // Add padding to the total width
            maxX += 20
            
            // Set content view height to match scroll view
            contentView.frame.size.height = scrollView.bounds.height
            
            // Determine the content size
            scrollView.contentSize = CGSize(
                width: max(maxX, bounds.width + 1), // Ensure it's scrollable
                height: contentView.frame.height
            )
        } else {
            // Both directions
            scrollView.contentSize = CGSize(
                width: max(contentView.frame.width, bounds.width + 1),
                height: max(contentView.frame.height, bounds.height + 1)
            )
        }
        
        // Ensure content view's position is at origin
        contentView.frame.origin = .zero
        
        print("ScrollView contentSize after: \(scrollView.contentSize)")
        print("Children frames:")
        for (index, subview) in contentView.subviews.enumerated() {
            print("Child \(index): frame=\(subview.frame), yoga.width=\(subview.yoga.width)")
        }
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        // Handle scroll-specific state changes
        if let showsIndicators = newState["showsIndicators"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsIndicators
            scrollView.showsHorizontalScrollIndicator = showsIndicators
        }
        
        if let bounces = newState["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        if let direction = newState["direction"] as? String {
            scrollDirection = UIScrollView.Direction(rawValue: direction) ?? .vertical
            updateScrollDirection()
        }
        
        if let contentInsets = newState["contentInset"] as? [String: CGFloat] {
            let top = contentInsets["top"] ?? 0
            let left = contentInsets["left"] ?? 0
            let bottom = contentInsets["bottom"] ?? 0
            let right = contentInsets["right"] ?? 0
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        if let scrollsToTop = newState["scrollsToTop"] as? Bool {
            scrollView.scrollsToTop = scrollsToTop
        }
        
        if let initialOffset = newState["initialScrollY"] as? CGFloat {
            scrollView.contentOffset.y = initialOffset
        }
        
        if let scrollEnabled = newState["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        }
        
        if let pagingEnabled = newState["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
    }
    
    private func updateScrollDirection() {
        switch scrollDirection {
        case .vertical:
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = false
            contentView.yoga.flexDirection = .column
        case .horizontal:
            scrollView.alwaysBounceVertical = false
            scrollView.alwaysBounceHorizontal = true
            contentView.yoga.flexDirection = .row
        case .both:
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = true
        }
        
        setNeedsLayout()
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let scrollViewStyle = style["scrollViewStyle"] as? [String: Any] {
            if let backgroundColor = scrollViewStyle["backgroundColor"] as? UInt32 {
                scrollView.backgroundColor = UIColor(rgb: backgroundColor)
            }
            
            if let showsIndicators = scrollViewStyle["showsIndicators"] as? Bool {
                scrollView.showsVerticalScrollIndicator = showsIndicators
                scrollView.showsHorizontalScrollIndicator = showsIndicators
            }
            
            if let bounces = scrollViewStyle["bounces"] as? Bool {
                scrollView.bounces = bounces
            }
            
            if let direction = scrollViewStyle["direction"] as? String {
                scrollDirection = UIScrollView.Direction(rawValue: direction) ?? .vertical
                updateScrollDirection()
            }
            
            if let initialScrollY = scrollViewStyle["initialScrollY"] as? CGFloat {
                scrollView.contentOffset.y = initialScrollY
            }
            
            if let scrollEnabled = scrollViewStyle["scrollEnabled"] as? Bool {
                scrollView.isScrollEnabled = scrollEnabled
            }
            
            if let decelerationRate = scrollViewStyle["decelerationRate"] as? String {
                switch decelerationRate {
                case "fast":
                    scrollView.decelerationRate = .fast
                case "normal":
                    scrollView.decelerationRate = .normal
                default:
                    break
                }
            }
            
            if let contentInsets = scrollViewStyle["contentInset"] as? [String: CGFloat] {
                let top = contentInsets["top"] ?? 0
                let left = contentInsets["left"] ?? 0
                let bottom = contentInsets["bottom"] ?? 0
                let right = contentInsets["right"] ?? 0
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
            }
        }
    }
    
    override func addSubview(_ view: UIView) {
        if view === scrollView {
            super.addSubview(view)
        } else {
            // Add to content view instead
            contentView.addSubview(view)
            
            print("Adding subview to content view: \(view), frame: \(view.frame), yoga config: \(view.yoga.width), alignSelf: \(view.yoga.alignSelf.rawValue)")
            
            // After adding a view to the content view, we need to make sure positions don't overlap
            var yPosition: CGFloat = 0
            
            // Find the current maximum Y position to place new views
            for subview in contentView.subviews where subview != view {
                let subviewMaxY = subview.frame.maxY
                if subviewMaxY > yPosition {
                    yPosition = subviewMaxY
                }
            }
            
            // Set vertical position for stack-like layout if this is a vertical scroll
            if scrollDirection == .vertical && contentView.subviews.count > 1 {
                // Respect the margin from yoga if available
                let topMargin = CGFloat(view.yoga.marginTop.value)
                // Only override position if not explicitly set through yoga
                if view.frame.origin.y < yPosition && topMargin <= 0 {
                    var newFrame = view.frame
                    newFrame.origin.y = yPosition + 16  // Add spacing between items
                    view.frame = newFrame
                }
            }
            
            // Force layout update to calculate content size
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            // Update our layout as well
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        super.setupEvents(events, channel: channel)
        self.methodChannel = channel
    }
    
    // MARK: - UIScrollViewDelegate methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let methodChannel = methodChannel else { return }
        
        let data: [String: Any] = [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ],
            "contentSize": [
                "width": scrollView.contentSize.width,
                "height": scrollView.contentSize.height
            ]
        ]
        
        methodChannel.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": ScrollEvent.onScroll.rawValue,
            "data": data
        ])
        
        // Check if we've reached the end of the scroll view
        let endReachedThreshold: CGFloat = 20.0
        let isNearEndVertical = scrollView.contentOffset.y + scrollView.frame.height + endReachedThreshold >= scrollView.contentSize.height
        let isNearEndHorizontal = scrollView.contentOffset.x + scrollView.frame.width + endReachedThreshold >= scrollView.contentSize.width
        
        if (scrollDirection == .vertical && isNearEndVertical) || 
           (scrollDirection == .horizontal && isNearEndHorizontal) {
            methodChannel.invokeMethod("onComponentEvent", arguments: [
                "viewId": viewId,
                "type": ScrollEvent.onEndReached.rawValue,
                "data": data
            ])
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let methodChannel = methodChannel else { return }
        lastContentOffset = scrollView.contentOffset
        
        methodChannel.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": ScrollEvent.onScrollBegin.rawValue,
            "data": [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ]
            ]
        ])
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let methodChannel = methodChannel, !decelerate else { return }
        
        methodChannel.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": ScrollEvent.onScrollEnd.rawValue,
            "data": [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ]
            ]
        ])
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard let methodChannel = methodChannel else { return }
        
        methodChannel.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": ScrollEvent.onMomentumScrollBegin.rawValue,
            "data": [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ]
            ]
        ])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let methodChannel = methodChannel else { return }
        
        methodChannel.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": ScrollEvent.onMomentumScrollEnd.rawValue,
            "data": [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "contentSize": [
                    "width": scrollView.contentSize.width,
                    "height": scrollView.contentSize.height
                ]
            ]
        ])
    }
    
    override func captureCurrentState() -> [String: Any] {
        var state = super.captureCurrentState()
        
        state["contentOffset"] = [
            "x": scrollView.contentOffset.x,
            "y": scrollView.contentOffset.y
        ]
        
        state["contentSize"] = [
            "width": scrollView.contentSize.width,
            "height": scrollView.contentSize.height
        ]
        
        state["showsIndicators"] = scrollView.showsVerticalScrollIndicator
        state["bounces"] = scrollView.bounces
        state["direction"] = scrollDirection.rawValue
        state["scrollEnabled"] = scrollView.isScrollEnabled
        
        return state
    }
}

// Extension to define scroll direction enum
extension UIScrollView {
    enum Direction: String {
        case vertical
        case horizontal
        case both
    }
}

