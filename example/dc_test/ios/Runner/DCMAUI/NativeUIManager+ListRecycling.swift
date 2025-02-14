import UIKit

@available(iOS 13.0, *)
class RecyclableCell: UICollectionViewCell {
    static let reuseIdentifier = "RecyclableCell"
    var viewId: String?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewId = nil
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
}

@available(iOS 13.0, *)
extension NativeUIManager: UICollectionViewDataSource, UICollectionViewDelegate {
    private struct ListViewState {
        var items: [String] = []
        var recycledViews: [String: UIView] = [:]
    }
    
    private var listStates: [String: ListViewState] = [:]
    
    func setupListView(_ collectionView: UICollectionView, viewId: String) {
        collectionView.register(RecyclableCell.self, forCellWithReuseIdentifier: RecyclableCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        listStates[viewId] = ListViewState()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewId = views.first(where: { $0.value == collectionView })?.key,
              let state = listStates[viewId] else { return 0 }
        return state.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecyclableCell.reuseIdentifier, for: indexPath) as! RecyclableCell
        
        guard let viewId = views.first(where: { $0.value == collectionView })?.key,
              let state = listStates[viewId],
              indexPath.item < state.items.count else { return cell }
        
        let itemId = state.items[indexPath.item]
        
        // Reuse or create view
        if let view = state.recycledViews[itemId] {
            cell.contentView.addSubview(view)
            view.frame = cell.contentView.bounds
        }
        
        cell.viewId = itemId
        return cell
    }
}
