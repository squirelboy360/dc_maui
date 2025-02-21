import UIKit

class DCListView: DCView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView
    private let layout = UICollectionViewFlowLayout()
    private var items: [DCView] = []
    
    override init(viewId: String) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(viewId: viewId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func setupDefaults() {
        super.setupDefaults()
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView.yoga.isEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DCListViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        addSubview(collectionView)
        
        // Make collection view fill parent
        collectionView.yoga.position = .absolute
        collectionView.yoga.left = .zero
        collectionView.yoga.top = .zero
        collectionView.yoga.right = .zero
        collectionView.yoga.bottom = .zero
    }
    
    func setItems(_ items: [DCView]) {
        self.items = items
        collectionView.reloadData()
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
}

class DCListViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        yoga.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func setContent(_ view: DCView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(view)
        view.yoga.isEnabled = true
        view.yoga.flexGrow = 1
    }
}
