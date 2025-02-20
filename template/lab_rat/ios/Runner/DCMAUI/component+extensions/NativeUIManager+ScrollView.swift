import UIKit
import YogaKit

@available(iOS 13.0, *)
extension NativeUIManager {
    // Move listData to main class
    internal var listData: [UICollectionView: [[String: Any]]] {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.listDataKey) as? [UICollectionView: [[String: Any]]] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.listDataKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Shared scroll view creation
    internal func createScrollableBase(viewType: String, args: [String: Any]) -> UIView {
        let isListView = viewType == "ListView"
        let view: UIView
        
        if isListView {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.scrollDirection = .vertical
            
            let listView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            listView.backgroundColor = .clear
            listView.delegate = self as? UICollectionViewDelegate
            listView.dataSource = self as? UICollectionViewDataSource
            listView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
            listView.isPrefetchingEnabled = true
            
            // Handle list data if provided
            if let data = args["data"] as? [[String: Any]] {
                listData[listView] = data
            }
            
            view = listView
        } else {
            let scrollView = UIScrollView()
            scrollView.showsVerticalScrollIndicator = true
            scrollView.showsHorizontalScrollIndicator = true
            scrollView.delegate = self as? UIScrollViewDelegate
            scrollView.backgroundColor = .clear
            
            view = scrollView
        }
        
        // Common configuration
        view.yoga.isEnabled = true
        view.clipsToBounds = true
        
        // Apply layout if provided
        if let layout = args["layout"] as? [String: Any] {
            let config = LayoutConfig(from: layout)
            applyYogaLayout(to: view, config: config)
        }
        
        return view
    }
    
    // Helper method for scroll events
    internal func sendScrollEvent(viewId: String, type: String, offset: CGPoint) {
        methodChannel?.invokeMethod("onScrollEvent", arguments: [
            "viewId": viewId,
            "type": type,
            "offset": [
                "x": offset.x,
                "y": offset.y
            ]
        ])
    }
    
    internal func configureCell(_ cell: UICollectionViewCell, withData data: [String: Any]) {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        if let viewType = data["type"] as? String {
            let childView = createScrollableBase(viewType: viewType, args: data)
            cell.contentView.addSubview(childView)
            
            childView.yoga.isEnabled = true
            childView.yoga.width = YGValue(value: 100, unit: .percent)
            childView.yoga.height = YGValue(value: 100, unit: .percent)
            
            cell.contentView.yoga.applyLayout(preservingOrigin: true)
        }
    }
}

// Add associated object key for list data storage
private struct AssociatedKeys {
    static var listDataKey = "listDataKey"
}

// Add protocol conformance in main class
@available(iOS 13.0, *)
extension NativeUIManager: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData[collectionView]?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let data = listData[collectionView]?[indexPath.item] {
            configureCell(cell, withData: data)
        }
        
        return cell
    }
}

// Add ScrollView delegate in main class
@available(iOS 13.0, *)
extension NativeUIManager: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let viewId = views.first(where: { $0.value == scrollView })?.key {
            sendScrollEvent(viewId: viewId, type: "onScroll", offset: scrollView.contentOffset)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let viewId = views.first(where: { $0.value == scrollView })?.key {
            sendScrollEvent(viewId: viewId, type: "onScrollEnd", offset: scrollView.contentOffset)
        }
    }
}
