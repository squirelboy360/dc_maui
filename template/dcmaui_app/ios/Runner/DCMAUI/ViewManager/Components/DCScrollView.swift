//
//  DCScrollView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// ScrollView component - a generic scrolling container
class DCScrollView: DCBaseView, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var isHorizontal = false
    private var refreshControl: UIRefreshControl?
    
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
        
        // Content layout will determine height
        let heightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
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
        
        // Content layout will determine width
        let widthConstraint = contentView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor)
        widthConstraint.priority = .defaultLow
        widthConstraint.isActive = true
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
        if let showsVerticalScrollIndicator = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
        
        if let showsHorizontalScrollIndicator = props["showsHorizontalScrollIndicator"] as? Bool {
            scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
        
        // Handle bounces (elastic scrolling)
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        // Handle paging
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        // Handle scroll indicator insets
        if let scrollIndicatorInsets = props["scrollIndicatorInsets"] as? [String: CGFloat] {
            let top = scrollIndicatorInsets["top"] ?? 0
            let left = scrollIndicatorInsets["left"] ?? 0
            let bottom = scrollIndicatorInsets["bottom"] ?? 0
            let right = scrollIndicatorInsets["right"] ?? 0
            
            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        // Handle content insets
        if let contentInset = props["contentInset"] as? [String: CGFloat] {
            let top = contentInset["top"] ?? 0
            let left = contentInset["left"] ?? 0
            let bottom = contentInset["bottom"] ?? 0
            let right = contentInset["right"] ?? 0
            
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        // Handle keyboard dismiss mode
        if let keyboardDismissMode = props["keyboardDismissMode"] as? String {
            switch keyboardDismissMode {
                case "none":
                    scrollView.keyboardDismissMode = .none
                case "interactive":
                    scrollView.keyboardDismissMode = .interactive
                case "onDrag":
                    scrollView.keyboardDismissMode = .onDrag
                default:
                    scrollView.keyboardDismissMode = .none
            }
        }
        
        // Handle refresh control
        if let refreshing = props["refreshing"] as? Bool {
            handleRefreshControl(refreshing, props: props)
        }
        
        // Handle initial scroll position (if specified)
        if let offset = props["contentOffset"] as? [String: CGFloat] {
            let x = offset["x"] ?? 0
            let y = offset["y"] ?? 0
            let animated = props["scrollToOffsetAnimated"] as? Bool ?? false
            
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
        }
    }
    
    private func handleRefreshControl(_ refreshing: Bool, props: [String: Any]) {
        // If we need refresh control but don't have one yet
        if refreshControl == nil && (props["onRefresh"] != nil) {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
        
        // Update refreshing state
        if refreshing {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    @objc private func handleRefresh() {
        // Send refresh event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onRefresh",
            params: ["target": viewId]
        )
    }
    
    // Override addSubview to add children to the contentView instead of self
    override func addSubview(_ view: UIView) {
        if view == scrollView {
            super.addSubview(view)
        } else {
            contentView.addSubview(view)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let layoutMeasurement = scrollView.bounds.size
        
        // Standard event format
        let scrollEvent: [String: Any] = [
            "contentOffset": [
                "x": contentOffset.x,
                "y": contentOffset.y
            ],
            "contentSize": [
                "width": contentSize.width,
                "height": contentSize.height
            ],
            "layoutMeasurement": [
                "width": layoutMeasurement.width,
                "height": layoutMeasurement.height
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
        
        // Check if we've reached the end
        let threshold = props["onEndReachedThreshold"] as? CGFloat ?? 0.5
        
        if isHorizontal {
            let visibleWidth = scrollView.bounds.width
            let contentWidth = scrollView.contentSize.width
            let distanceFromEnd = contentWidth - contentOffset.x - visibleWidth
            
            if distanceFromEnd < visibleWidth * threshold {
                // Send end reached event
                DCViewCoordinator.shared?.sendEvent(
                    viewId: viewId,
                    eventName: "onEndReached",
                    params: ["distanceFromEnd": distanceFromEnd]
                )
            }
        } else {
            let visibleHeight = scrollView.bounds.height
            let contentHeight = scrollView.contentSize.height
            let distanceFromEnd = contentHeight - contentOffset.y - visibleHeight
            
            if distanceFromEnd < visibleHeight * threshold {
                // Send end reached event
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
        // Send onMomentumScrollBegin to match React Native behavior
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onScrollBeginDrag",
            params: [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "target": viewId,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Send standard onScrollEndDrag event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onScrollEndDrag",
            params: [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "target": viewId,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )
        
        // If not decelerating, also send momentum end (matches React Native)
        if !decelerate {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onMomentumScrollEnd",
                params: [
                    "contentOffset": [
                        "x": scrollView.contentOffset.x,
                        "y": scrollView.contentOffset.y
                    ],
                    "contentSize": [
                        "width": scrollView.contentSize.width,
                        "height": scrollView.contentSize.height
                    ],
                    "layoutMeasurement": [
                        "width": scrollView.bounds.size.width,
                        "height": scrollView.bounds.size.height
                    ],
                    "target": viewId,
                    "timestamp": Date().timeIntervalSince1970 * 1000
                ]
            )
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        // Add onMomentumScrollBegin to match React Native
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onMomentumScrollBegin",
            params: [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "target": viewId,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onMomentumScrollEnd",
            params: ["target": viewId]
        )
    }
    
    // Expose scroll methods that can be called from Dart
    func scrollTo(x: CGFloat, y: CGFloat, animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
    func scrollToEnd(animated: Bool) {
        if isHorizontal {
            let x = scrollView.contentSize.width - scrollView.bounds.width
            scrollView.setContentOffset(CGPoint(x: max(0, x), y: 0), animated: animated)
        } else {
            let y = scrollView.contentSize.height - scrollView.bounds.height
            scrollView.setContentOffset(CGPoint(x: 0, y: max(0, y)), animated: animated)
        }
    }
    
    // Expose flashScrollIndicators to match React Native API
    func flashScrollIndicators() {
        scrollView.flashScrollIndicators()
    }
}
