import UIKit

class DCCollectionView: UICollectionView {
    private var items: [DCListItem] = []
    private let itemSpacing: CGFloat
    private let sectionInsets: UIEdgeInsets
    private let flowLayout: UICollectionViewFlowLayout
    private let style: DCListViewStyle
    
    init(style: DCListViewStyle = .list, spacing: CGFloat = 8, padding: UIEdgeInsets = .zero) {
        self.style = style
        self.itemSpacing = spacing
        self.sectionInsets = padding
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = style.scrollDirection
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = style.isGrid ? spacing : 0
        layout.sectionInset = padding
        self.flowLayout = layout
        
        super.init(frame: .zero, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
        delegate = self
        dataSource = self
        register(DCListItemCell.self, forCellWithReuseIdentifier: DCListItemCell.reuseId)
        
        alwaysBounceVertical = style.scrollDirection == .vertical
        alwaysBounceHorizontal = style.scrollDirection == .horizontal
        showsVerticalScrollIndicator = style.scrollDirection == .vertical
        showsHorizontalScrollIndicator = style.scrollDirection == .horizontal
        
        contentInsetAdjustmentBehavior = .never
        
        // Enable refresh control if needed
        if style.enablePullToRefresh {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        }
    }
    
    @objc private func handleRefresh() {
        onRefresh?()
    }
    
    // Callback for refresh
    var onRefresh: (() -> Void)?
    
    // Callback for pagination
    var onLoadMore: (() -> Void)?
    
    func addItem(_ view: UIView, height: CGFloat? = nil) {
        let item = DCListItem(view: view, height: height)
        items.append(item)
        reloadData()
    }
    
    func removeItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
        reloadData()
    }
    
    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}

extension DCCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DCListItemCell.reuseId, for: indexPath) as! DCListItemCell
        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.item]
        let width: CGFloat
        let height: CGFloat
        
        switch style {
        case .list:
            width = collectionView.bounds.width - (sectionInsets.left + sectionInsets.right)
            height = item.height ?? 60
        case .grid(let columns):
            let totalSpacing = itemSpacing * (CGFloat(columns) - 1)
            let availableWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right - totalSpacing
            width = availableWidth / CGFloat(columns)
            height = item.height ?? width // Square by default
        }
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard style.enablePagination else { return }
        
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        let reloadDistance = bounds.size.height * 0.5 // Half screen height
        if y > h + reloadDistance {
            onLoadMore?()
        }
    }
}

// MARK: - Supporting Types
enum DCListViewStyle {
    case list
    case grid(columns: Int)
    
    var isGrid: Bool {
        switch self {
        case .grid: return true
        case .list: return false
        }
    }
    
    var scrollDirection: UICollectionView.ScrollDirection {
        switch self {
        case .list: return .vertical
        case .grid: return .vertical
        }
    }
    
    var enablePullToRefresh: Bool {
        return true // Can be configured per style if needed
    }
    
    var enablePagination: Bool {
        return true // Can be configured per style if needed
    }
}

private struct DCListItem {
    let view: UIView
    let height: CGFloat?
}

private class DCListItemCell: UICollectionViewCell {
    static let reuseId = "DCListItemCell"
    
    private var contentContainer: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: DCListItem) {
        contentContainer?.removeFromSuperview()
        
        contentContainer = item.view
        if let container = contentContainer {
            container.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(container)
            
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: contentView.topAnchor),
                container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
    }
}
