import UIKit
import YogaKit
import Flutter

@available(iOS 13.0, *)
class DCListView: DCView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Collection view for virtualization
    private var collectionView: UICollectionView!
    private let cellIdentifier = "DCListViewCell"
    
    // Data state
    private var dataLength: Int = 0
    private var renderedItems: [Int: UIView] = [:]
    private var itemKeys: [Int: String] = [:]
    
    // Configuration
    private var itemSpacing: CGFloat = 8
    private var isHorizontal: Bool = false
    private var windowSize: Int = 21
    
    // Tracking
    private var visibleIndices: Set<Int> = []
    private var requestedIndices: Set<Int> = []
    
    override init(viewId: String) {
        super.init(viewId: viewId)
        setupCollectionView()
        print("DCListView: Initialized with ID \(viewId)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    private func setupCollectionView() {
        // Create a proper UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = itemSpacing
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // Register cell
        collectionView.register(DCListViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        // Add to view hierarchy with constraints
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        print("DCListView: Collection view setup complete")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Critical: Ensure we have a valid frame before proceeding
        guard frame.width > 0 && frame.height > 0 else {
            print("DCListView: Invalid frame dimensions: \(frame)")
            return
        }
        
        print("DCListView: layoutSubviews with frame \(frame), bounds \(bounds)")
        collectionView.frame = bounds
        
        // Update collection view layout if needed
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            if isHorizontal {
                flowLayout.scrollDirection = .horizontal
            } else {
                flowLayout.scrollDirection = .vertical
            }
            flowLayout.invalidateLayout()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("DCListView: numberOfItemsInSection returning \(dataLength)")
        return dataLength
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! DCListViewCell
        let index = indexPath.item
        
        if let itemView = renderedItems[index] {
            // We already have this item rendered
            cell.configure(with: itemView)
            print("DCListView: Reused existing item at index \(index)")
        } else {
            // Request the item to be rendered
            requestItemAt(index)
            cell.configurePlaceholder()
            print("DCListView: Using placeholder for index \(index)")
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = indexPath.item
        
        if let itemView = renderedItems[index] {
            // If we have the item view, use its measured size
            itemView.layoutIfNeeded()
            let targetWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
            var itemSize = itemView.systemLayoutSizeFitting(
                CGSize(width: targetWidth, height: UIView.layoutFittingExpandedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            
            // Minimum height for items
            if itemSize.height < 44 {
                itemSize.height = 44
            }
            
            return itemSize
        }
        
        // Default size for placeholder
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        visibleIndices.insert(indexPath.item)
        updateVisibleRange()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        visibleIndices.remove(indexPath.item)
        updateVisibleRange()
    }
    
    // MARK: - Scroll Events
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = ["x": scrollView.contentOffset.x, "y": scrollView.contentOffset.y]
        let contentSize = ["width": scrollView.contentSize.width, "height": scrollView.contentSize.height]
        let layoutMeasurement = ["width": scrollView.frame.width, "height": scrollView.frame.height]
        
        triggerEvent("onScroll", [
            "contentOffset": contentOffset,
            "contentSize": contentSize,
            "layoutMeasurement": layoutMeasurement
        ])
        
        // Check if near end of content
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if contentHeight > 0 && offset > 0 && (offset + scrollViewHeight) > (contentHeight - 200) {
            triggerEvent("onEndReached", nil)
        }
    }
    
    // MARK: - Public API
    
    func setItem(_ index: Int, itemView: UIView, key: String?) {
        // Store the item
        renderedItems[index] = itemView
        if let key = key {
            itemKeys[index] = key
        }
        
        // Prepare the view
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        // Update the cell if visible
        if visibleIndices.contains(index) {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func removeAllItems() {
        renderedItems.removeAll()
        itemKeys.removeAll()
        requestedIndices.removeAll()
        visibleIndices.removeAll()
        
        collectionView.reloadData()
    }
    
    func scrollToIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < dataLength else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .top, animated: animated)
        }
    }
    
    // MARK: - State Handling
    
    override func handleStateChange(_ state: [String: Any]) {
        super.handleStateChange(state)
        
        var needsReload = false
        
        if let dataLen = state["dataLength"] as? Int {
            dataLength = dataLen
            needsReload = true
            print("DCListView: Data length updated to \(dataLen)")
        }
        
        if let spacing = state["itemSpacing"] as? CGFloat {
            itemSpacing = spacing
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = spacing
            }
            needsReload = true
        }
        
        if let horizontal = state["horizontal"] as? Bool {
            isHorizontal = horizontal
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = horizontal ? .horizontal : .vertical
            }
            needsReload = true
        }
        
        if let showsIndicators = state["showsIndicators"] as? Bool {
            collectionView.showsVerticalScrollIndicator = showsIndicators
            collectionView.showsHorizontalScrollIndicator = showsIndicators
        }
        
        if let bounces = state["bounces"] as? Bool {
            collectionView.alwaysBounceVertical = bounces
        }
        
        if let windowSizeValue = state["windowSize"] as? Int {
            windowSize = windowSizeValue
        }
        
        // Fix: Convert Int to UInt32 properly
        if let backgroundColor = state["backgroundColor"] as? Int {
            let color = UIColor(rgb: UInt32(backgroundColor))
            collectionView.backgroundColor = color
        }
        
        if let contentInset = state["contentInset"] as? [String: CGFloat] {
            let top = contentInset["top"] ?? 0
            let left = contentInset["left"] ?? 0
            let bottom = contentInset["bottom"] ?? 0
            let right = contentInset["right"] ?? 0
            collectionView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        if needsReload {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
                print("DCListView: Reloaded collection view")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateVisibleRange() {
        guard !visibleIndices.isEmpty else { return }
        
        // Fix: Use min() and max() functions properly
        let minIndex = visibleIndices.min() ?? 0
        let maxIndex = visibleIndices.max() ?? 0
        
        // Calculate the window of indices to render
        let halfWindow = windowSize / 2
        let start = Swift.max(0, minIndex - halfWindow)
        let end = Swift.min(dataLength - 1, maxIndex + halfWindow)
        
        if start <= end {
            for index in start...end {
                if !renderedItems.keys.contains(index) && !requestedIndices.contains(index) {
                    requestItemAt(index)
                }
            }
        }
    }
    
    private func requestItemAt(_ index: Int) {
        guard !requestedIndices.contains(index) else { return }
        
        requestedIndices.insert(index)
        // Fix: Use dictionary with string keys
        triggerEvent("requestItem", ["index": index])
        print("DCListView: Requested item at index \(index)")
    }
    
    private func triggerEvent(_ type: String, _ data: [String: Any]?) {
        NotificationCenter.default.post(
            name: NSNotification.Name("ComponentEvent"),
            object: nil,
            userInfo: [
                "viewId": viewId,
                "type": type,
                "data": data as Any
            ]
        )
    }
}

// MARK: - Cell Implementation

class DCListViewCell: UICollectionViewCell {
    private var contentItemView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func configure(with itemView: UIView) {
        // Remove existing content if any
        contentItemView?.removeFromSuperview()
        
        // Add the new item view
        contentView.addSubview(itemView)
        contentItemView = itemView
        
        // Setup constraints - fill the cell
        itemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            itemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configurePlaceholder() {
        // Remove any existing content
        contentItemView?.removeFromSuperview()
        
        // Create a simple placeholder view
        let placeholder = UIView()
        placeholder.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.3)
        placeholder.layer.cornerRadius = 8
        
        contentView.addSubview(placeholder)
        contentItemView = placeholder
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            placeholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            placeholder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            placeholder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            placeholder.heightAnchor.constraint(greaterThanOrEqualToConstant: 88)
        ])
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        // Ensure we maintain the width but allow height to be dynamic
        let targetSize = CGSize(
            width: layoutAttributes.frame.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        
        // Calculate the size needed to display the content
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        attributes.frame.size.height = size.height
        return attributes
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentItemView?.removeFromSuperview()
        contentItemView = nil
    }
}

