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

class DCListView: DCView, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var isHorizontal = false
    private var itemSpacing: CGFloat = 0
    private var methodChannel: FlutterMethodChannel?
    private var lastContentOffset: CGPoint = .zero
    private var dataLength: Int = 0
    
    // Store rendered items with their indices
    private var renderedItems: [Int: DCView] = [:]
    private var itemKeys: [Int: String] = [:]
    private var initialNumToRender: Int = 10
    private var windowSize: Int = 21
    private var visibleIndices: [Int] = []
    
    enum ListEvent: String {
        case onScroll
        case onScrollBegin
        case onScrollEnd
        case onEndReached
        case requestItem
    }
    
    override init(viewId: String) {
        super.init(viewId: viewId)
        setupListView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupListView() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.bounces = true
        scrollView.clipsToBounds = true
        scrollView.backgroundColor = .clear
        
        contentView.yoga.isEnabled = true
        contentView.backgroundColor = .clear
        
        // Configure content view based on orientation
        contentView.yoga.flexDirection = isHorizontal ? .row : .column
        
        scrollView.addSubview(contentView)
        addSubview(scrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        
        // Apply layout to content view
        contentView.yoga.applyLayout(preservingOrigin: true)
        
        // Set content view dimension based on orientation
        if isHorizontal {
            contentView.frame.size.height = bounds.height
            updateHorizontalContentSize()
        } else {
            contentView.frame.size.width = bounds.width
            updateVerticalContentSize()
        }
        
        // Ensure content view's position is at origin
        contentView.frame.origin = .zero
        
        // Update visible items based on current scroll position
        updateVisibleItems()
        print("ListView layout: \(scrollView.contentSize), items: \(renderedItems.count)")
    }
    
    private func updateVerticalContentSize() {
        // Calculate total height based on rendered items
        var maxHeight: CGFloat = 0
        
        // Find the highest Y value among rendered items
        for (_, itemView) in renderedItems {
            let bottomEdge = itemView.frame.maxY
            if bottomEdge > maxHeight {
                maxHeight = bottomEdge
            }
        }
        
        // Add spacing for the last item
        if !renderedItems.isEmpty {
            maxHeight += itemSpacing
        }
        
        // Ensure minimum size
        maxHeight = max(maxHeight, 1)
        
        // Set content size
        scrollView.contentSize = CGSize(width: bounds.width, height: maxHeight)
    }
    
    private func updateHorizontalContentSize() {
        // Calculate total width based on rendered items
        var maxWidth: CGFloat = 0
        
        // Find the rightmost edge among rendered items
        for (_, itemView) in renderedItems {
            let rightEdge = itemView.frame.maxX
            if rightEdge > maxWidth {
                maxWidth = rightEdge
            }
        }
        
        // Add spacing for the last item
        if !renderedItems.isEmpty {
            maxWidth += itemSpacing
        }
        
        // Ensure minimum size
        maxWidth = max(maxWidth, 1)
        
        // Set content size
        scrollView.contentSize = CGSize(width: maxWidth, height: bounds.height)
    }
    
    func setItem(_ index: Int, itemView: DCView, key: String? = nil) {
        print("Setting item at index \(index), key: \(key ?? "nil")")
        
        // Remove existing item at this index if present
        if let existingItem = renderedItems[index] {
            existingItem.removeFromSuperview()
        }
        
        // Add new item to content view
        contentView.addSubview(itemView)
        renderedItems[index] = itemView
        
        if let key = key {
            itemKeys[index] = key
        }
        
        // Position item in list based on orientation and previous items
        positionItem(at: index, view: itemView)
        
        // Make sure the item takes proper width
        if !isHorizontal {
            if itemView.yoga.width.unit != .percent {
                // For items without percent width, set them to almost full width
                let width = contentView.bounds.width - 32
                itemView.frame.size.width = width
                if itemView.yoga.isEnabled {
                    itemView.yoga.width = YGValue(value: Float(width), unit: .point)
                    itemView.yoga.applyLayout(preservingOrigin: true)
                }
            } else {
                // For percentage-based width, calculate the actual width
                let percentWidth = CGFloat(itemView.yoga.width.value) / 100.0
                itemView.frame.size.width = contentView.bounds.width * percentWidth
            }
        }
        
        // Apply layout to ensure proper dimensions
        itemView.setNeedsLayout()
        itemView.layoutIfNeeded()
        
        // Request layout update
        setNeedsLayout()
    }
    
    private func positionItem(at index: Int, view: DCView) {
        // Get the previous item for positioning reference
        var yPosition: CGFloat = 0
        var xPosition: CGFloat = 0
        
        if isHorizontal {
            // Find the rightmost positioned item before this index
            for i in 0..<index {
                if let item = renderedItems[i] {
                    let rightEdge = item.frame.maxX + itemSpacing
                    if rightEdge > xPosition {
                        xPosition = rightEdge
                    }
                }
            }
            
            // Set position
            view.frame.origin.x = xPosition
            view.frame.origin.y = 0
        } else {
            // Find the lowest positioned item before this index
            for i in 0..<index {
                if let item = renderedItems[i] {
                    let bottomEdge = item.frame.maxY + itemSpacing
                    if bottomEdge > yPosition {
                        yPosition = bottomEdge
                    }
                }
            }
            
            // Set position
            view.frame.origin.x = 0
            view.frame.origin.y = yPosition
        }
    }
    
    func removeAllItems() {
        // Remove all rendered items
        for (_, itemView) in renderedItems {
            itemView.removeFromSuperview()
        }
        renderedItems.removeAll()
        itemKeys.removeAll()
        visibleIndices.removeAll()
    }
    
    private func updateVisibleItems() {
        // Determine which indices are now visible
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        
        // Calculate visible indices
        var newVisibleIndices: [Int] = []
        for (index, itemView) in renderedItems {
            if itemView.frame.intersects(visibleRect) {
                newVisibleIndices.append(index)
            }
        }
        
        // Update visible items tracking
        visibleIndices = newVisibleIndices
        
        // Calculate indices that should be rendered based on window size
        let windowIndices = calculateWindowIndices()
        
        // Request items that should be visible but aren't rendered
        for index in windowIndices {
            if index >= 0 && index < dataLength && renderedItems[index] == nil {
                requestItem(at: index)
            }
        }
    }
    
    private func calculateWindowIndices() -> [Int] {
        guard !visibleIndices.isEmpty else {
            // No visible items, return initial range
            return Array(0..<min(initialNumToRender, dataLength))
        }
        
        // Find min/max visible indices
        let minVisibleIndex = visibleIndices.min() ?? 0
        let maxVisibleIndex = visibleIndices.max() ?? 0
        
        // Calculate window size on either side
        let halfWindow = windowSize / 2
        
        let startIndex = max(0, minVisibleIndex - halfWindow)
        let endIndex = min(dataLength - 1, maxVisibleIndex + halfWindow)
        
        return Array(startIndex...endIndex)
    }
    
    private func requestItem(at index: Int) {
        guard let methodChannel = methodChannel else { return }
        print("Requesting item at index \(index)")
        
        methodChannel.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": ListEvent.requestItem.rawValue,
            "data": [
                "index": index
            ]
        ])
    }
    
    // Method to scroll to a specific index
    func scrollToIndex(_ index: Int, animated: Bool) {
        guard let itemView = renderedItems[index] else {
            // Item not rendered, request it
            requestItem(at: index)
            return
        }
        
        let rect = itemView.frame
        scrollView.scrollRectToVisible(rect, animated: animated)
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        if let dataLengthValue = newState["dataLength"] as? Int {
            dataLength = dataLengthValue
        }
        
        if let horizontal = newState["horizontal"] as? Bool {
            isHorizontal = horizontal
            contentView.yoga.flexDirection = isHorizontal ? .row : .column
        }
        
        if let spacing = newState["itemSpacing"] as? CGFloat {
            itemSpacing = spacing
        }
        
        if let showsIndicators = newState["showsIndicators"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsIndicators
            scrollView.showsHorizontalScrollIndicator = showsIndicators
        }
        
        if let bounces = newState["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        if let initialScrollY = newState["initialScrollY"] as? CGFloat {
            scrollView.contentOffset.y = initialScrollY
        }
        
        if let scrollEnabled = newState["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        }
        
        if let pagingEnabled = newState["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        if let initial = newState["initialNumToRender"] as? Int {
            initialNumToRender = initial
        }
        
        if let window = newState["windowSize"] as? Int {
            windowSize = window
        }
        
        if let contentInset = newState["contentInset"] as? [String: CGFloat] {
            let top = contentInset["top"] ?? 0
            let left = contentInset["left"] ?? 0
            let bottom = contentInset["bottom"] ?? 0
            let right = contentInset["right"] ?? 0
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        setNeedsLayout()
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let listViewStyle = style["listViewStyle"] as? [String: Any] {
            if let backgroundColor = listViewStyle["backgroundColor"] as? UInt32 {
                scrollView.backgroundColor = UIColor(rgb: backgroundColor)
            }
            
            if let horizontal = listViewStyle["horizontal"] as? Bool {
                isHorizontal = horizontal
                contentView.yoga.flexDirection = isHorizontal ? .row : .column
            }
            
            if let itemSpacing = listViewStyle["itemSpacing"] as? CGFloat {
                self.itemSpacing = itemSpacing
            }
            
            if let showsIndicators = listViewStyle["showsIndicators"] as? Bool {
                scrollView.showsVerticalScrollIndicator = showsIndicators
                scrollView.showsHorizontalScrollIndicator = showsIndicators
            }
            
            if let bounces = listViewStyle["bounces"] as? Bool {
                scrollView.bounces = bounces
            }
            
            if let initialScrollY = listViewStyle["initialScrollY"] as? CGFloat {
                scrollView.contentOffset.y = initialScrollY
            }
            
            if let scrollEnabled = listViewStyle["scrollEnabled"] as? Bool {
                scrollView.isScrollEnabled = scrollEnabled
            }
            
            if let pagingEnabled = listViewStyle["pagingEnabled"] as? Bool {
                scrollView.isPagingEnabled = pagingEnabled
            }
            
            if let initialNumToRender = listViewStyle["initialNumToRender"] as? Int {
                self.initialNumToRender = initialNumToRender
            }
            
            if let windowSize = listViewStyle["windowSize"] as? Int {
                self.windowSize = windowSize
            }
            
            if let contentInsets = listViewStyle["contentInset"] as? [String: CGFloat] {
                let top = contentInsets["top"] ?? 0
                let left = contentInsets["left"] ?? 0
                let bottom = contentInsets["bottom"] ?? 0
                let right = contentInsets["right"] ?? 0
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
            }
        }
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        super.setupEvents(events, channel: channel)
        self.methodChannel = channel
    }
    
    // MARK: - ScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let methodChannel = methodChannel else { return }
        
        // Update visible items
        updateVisibleItems()
        
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
            "type": ListEvent.onScroll.rawValue,
            "data": data
        ])
        
        // Check if we've reached the end
        let endReachedThreshold: CGFloat = 20.0
        let isEndReached: Bool
        
        if isHorizontal {
            isEndReached = scrollView.contentOffset.x + scrollView.frame.width + endReachedThreshold >= scrollView.contentSize.width
        } else {
            isEndReached = scrollView.contentOffset.y + scrollView.frame.height + endReachedThreshold >= scrollView.contentSize.height
        }
        
        if isEndReached {
            methodChannel.invokeMethod("onComponentEvent", arguments: [
                "viewId": viewId,
                "type": ListEvent.onEndReached.rawValue,
                "data": data
            ])
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let methodChannel = methodChannel else { return }
        lastContentOffset = scrollView.contentOffset
        
        methodChannel.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": ListEvent.onScrollBegin.rawValue,
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
            "type": ListEvent.onScrollEnd.rawValue,
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
            "type": ListEvent.onScrollEnd.rawValue,
            "data": [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
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
        state["horizontal"] = isHorizontal
        state["scrollEnabled"] = scrollView.isScrollEnabled
        
        return state
    }
}
