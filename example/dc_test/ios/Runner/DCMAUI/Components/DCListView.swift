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

/**
 DCListView: Native list/collection view

 Expected Input Properties:
 {
   "style": {
     "horizontal": Bool,          // Horizontal scrolling
     "itemSpacing": CGFloat,     // Space between items
     "showsIndicators": Bool,    // Show scroll indicators
   },
   "layout": {
     // Yoga layout properties for container
   },
   "items": [                    // Array of child view configs
     { view configuration }
   ]
 }

 Event Data Emitted:
 onScroll: {
   "offset": {
     "x": CGFloat,              // Scroll position
     "y": CGFloat
   },
   "visibleItems": [Int],       // Indices of visible items
   "contentSize": {
     "width": CGFloat,
     "height": CGFloat
   },
   "timestamp": TimeInterval
 }
 onEndReached: {
   "distanceFromEnd": CGFloat,  // Distance to content end
   "timestamp": TimeInterval
 }
 onItemPress: {
   "index": Int,               // Pressed item index
   "timestamp": TimeInterval
 }
*/

class DCListView: DCView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    private let collectionView: UICollectionView
    private let layout = UICollectionViewFlowLayout()
    private var items: [DCView] = []
    private weak var methodChannel: FlutterMethodChannel?
    
    // Add performance optimizations
    private var visibleIndexPaths = Set<IndexPath>()
    private var prefetchIndexPaths = Set<IndexPath>()
    private var cellSizeCache: [Int: CGSize] = [:]
    private let reuseQueue = DispatchQueue(label: "com.dcmaui.listview.reuse")
    
    // Configuration
    private var prefetchingEnabled = true
    private var estimatedItemSize: CGSize = CGSize(width: 100, height: 100)
    
    override init(viewId: String) {
        layout.estimatedItemSize = .zero
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(viewId: viewId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func setupDefaults() {
        super.setupDefaults()
        
        // Enable performance optimizations
        collectionView.isPrefetchingEnabled = true
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView.yoga.isEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(DCListViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // Add memory warning observer
        NotificationCenter.default.addObserver(self, 
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil)
        
        setupCollectionView()
        
        addSubview(collectionView)
        
        // Make collection view fill parent
        collectionView.yoga.position = .absolute
        collectionView.yoga.left = .zero
        collectionView.yoga.top = .zero
        collectionView.yoga.right = .zero
        collectionView.yoga.bottom = .zero
    }
    
    private func setupCollectionView() {
        // Enable cell prefetching
        if #available(iOS 15.0, *) {
            collectionView.isPrefetchingEnabled = true
        }
        
        // Optimize scrolling
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    @objc private func handleMemoryWarning() {
        // Clear caches
        cellSizeCache.removeAll()
        reuseQueue.async { [weak self] in
            self?.cleanupOffscreenContent()
        }
    }
    
    private func cleanupOffscreenContent() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        items.enumerated().forEach { index, view in
            let indexPath = IndexPath(item: index, section: 0)
            if !visibleIndexPaths.contains(indexPath) {
                view.layer.contents = nil // Release image contents
            }
        }
    }
    
    func setItems(_ items: [DCView]) {
        self.items = items
        collectionView.reloadData()
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        
        if events["onScroll"] != nil {
            collectionView.delegate = self  // Ensure delegate is set
        }
        
        if events["onEndReached"] != nil {
            // End reached is handled in scrollViewDidScroll
            collectionView.delegate = self
        }
    }
    
    private func handleScroll() {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onScroll",
            "data": ["offset": collectionView.contentOffset.y],
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DCListViewCell
        cell.setContent(items[indexPath.item])
        return cell
    }
    
    // Implement UICollectionViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { prefetchIndexPaths.insert($0) }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { prefetchIndexPaths.remove($0) }
    }
}

extension DCListView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onScroll",
            "data": [
                "offset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "visibleItems": collectionView.indexPathsForVisibleItems.map { $0.item },
                "contentSize": [
                    "width": scrollView.contentSize.width,
                    "height": scrollView.contentSize.height
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
        
        // Check if reached end
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if offset > contentHeight - scrollViewHeight - 100 {
            methodChannel?.invokeMethod("onComponentEvent", arguments: [
                "viewId": viewId,
                "type": "onEndReached",
                "data": [
                    "distanceFromEnd": contentHeight - (offset + scrollViewHeight),
                    "timestamp": Date().timeIntervalSince1970
                ]
            ])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onItemPress",
            "data": [
                "index": indexPath.item,
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
}

class DCListViewCell: UICollectionViewCell {
    private var currentView: DCView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        yoga.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentView?.removeFromSuperview()
        currentView = nil
    }
    
    func setContent(_ view: DCView) {
        if currentView !== view {
            currentView?.removeFromSuperview()
            currentView = view
            contentView.addSubview(view)
            view.yoga.isEnabled = true
            view.yoga.flexGrow = 1
        }
    }
}
