//
//  DCListView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit


/// A ListView component that displays a scrollable list of items
class DCListView: DCBaseView, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var isHorizontal = false
    
    override func setupView() {
        super.setupView()
        
        // Set up scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.clipsToBounds = true
        addSubview(scrollView)
        
        // Set up content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Set constraints for scrollView to fill this view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Default vertical layout constraints
        setupVerticalLayoutConstraints()
    }
    
    private func setupVerticalLayoutConstraints() {
        // Remove all existing constraints on contentView
        contentView.removeConstraints(contentView.constraints)
        
        // Add constraints for vertical scrolling
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHorizontalLayoutConstraints() {
        // Remove all existing constraints on contentView
        contentView.removeConstraints(contentView.constraints)
        
        // Add constraints for horizontal scrolling
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle horizontal scrolling
        if let horizontal = props["horizontal"] as? Bool {
            isHorizontal = horizontal
            scrollView.showsVerticalScrollIndicator = !horizontal
            scrollView.showsHorizontalScrollIndicator = horizontal
            
            if horizontal {
                setupHorizontalLayoutConstraints()
            } else {
                setupVerticalLayoutConstraints()
            }
        }
        
        // Handle scroll indicators
        if let showsScrollIndicator = props["showsScrollIndicator"] as? Bool {
            if isHorizontal {
                scrollView.showsHorizontalScrollIndicator = showsScrollIndicator
            } else {
                scrollView.showsVerticalScrollIndicator = showsScrollIndicator
            }
        }
        
        // Handle bounce (elastic scrolling)
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        // Handle initial scroll index (would need special handling for real implementation)
        if let initialScrollIndex = props["initialScrollIndex"] as? Int {
            // For a real implementation, would scroll to this index
            // This would require knowledge of item heights/positions
        }
    }
    
    // Override addSubview to add children to the contentView instead of self
    override func addSubview(_ view: UIView) {
        if view == scrollView {
            super.addSubview(view)
        } else {
            contentView.addSubview(view)
            // No need for Taitank references here, just add the subview directly
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    // Standard scroll event handling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let layoutMeasurement = scrollView.bounds.size
        
        // Calculate metrics
        let contentOffsetX = contentOffset.x
        let contentOffsetY = contentOffset.y
        let contentSizeWidth = contentSize.width
        let contentSizeHeight = contentSize.height
        let layoutMeasurementWidth = layoutMeasurement.width
        let layoutMeasurementHeight = layoutMeasurement.height
        
        // Standard event payload format for DCMAUI
        let scrollEvent: [String: Any] = [
            "contentOffset": [
                "x": contentOffsetX,
                "y": contentOffsetY
            ],
            "contentSize": [
                "width": contentSizeWidth,
                "height": contentSizeHeight
            ],
            "layoutMeasurement": [
                "width": layoutMeasurementWidth,
                "height": layoutMeasurementHeight
            ],
            "zoomScale": scrollView.zoomScale,
            "contentInset": [
                "top": scrollView.contentInset.top,
                "left": scrollView.contentInset.left,
                "bottom": scrollView.contentInset.bottom,
                "right": scrollView.contentInset.right
            ],
            "target": viewId,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]
        
        // Send scroll event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onScroll",
            params: scrollEvent
        )
        
        // Calculate end reached state
        let threshold = props["onEndReachedThreshold"] as? CGFloat ?? 0.5
        
        if isHorizontal {
            let visibleWidth = scrollView.bounds.width
            let contentWidth = scrollView.contentSize.width
            let distanceFromEnd = contentWidth - contentOffsetX - visibleWidth
            
            if distanceFromEnd < visibleWidth * threshold {
                // Send onEndReached like React Native FlatList
                DCViewCoordinator.shared?.sendEvent(
                    viewId: viewId,
                    eventName: "onEndReached",
                    params: ["distanceFromEnd": distanceFromEnd]
                )
            }
        } else {
            let visibleHeight = scrollView.bounds.height
            let contentHeight = scrollView.contentSize.height
            let distanceFromEnd = contentHeight - contentOffsetY - visibleHeight
            
            if distanceFromEnd < visibleHeight * threshold {
                // Send onEndReached like React Native FlatList
                DCViewCoordinator.shared?.sendEvent(
                    viewId: viewId,
                    eventName: "onEndReached",
                    params: ["distanceFromEnd": distanceFromEnd]
                )
            }
        }
    }
    
    // Standard momentum scroll events
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onScrollBeginDrag",
            params: ["target": viewId]
        )
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onScrollEndDrag",
            params: ["target": viewId]
        )
        
        if !decelerate {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onMomentumScrollEnd",
                params: ["target": viewId]
            )
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onMomentumScrollEnd",
            params: ["target": viewId]
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update content size after layout
        DispatchQueue.main.async {
            if self.isHorizontal {
                var maxWidth: CGFloat = 0
                for subview in self.contentView.subviews {
                    maxWidth = max(maxWidth, subview.frame.maxX)
                }
                self.scrollView.contentSize = CGSize(width: maxWidth, height: self.scrollView.bounds.height)
            } else {
                var maxHeight: CGFloat = 0
                for subview in self.contentView.subviews {
                    maxHeight = max(maxHeight, subview.frame.maxY)
                }
                self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: maxHeight)
            }
        }
    }
}
