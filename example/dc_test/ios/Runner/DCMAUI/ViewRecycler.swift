import UIKit

@available(iOS 13.0, *)
class ViewRecycler {
    private var recycledViews: [String: [UIView]] = [:]
    private var registeredTypes: Set<String> = []
    private let maxRecycledViews = 20
    
    func register(viewType: String) {
        registeredTypes.insert(viewType)
    }
    
    func dequeueView(ofType type: String) -> UIView? {
        guard registeredTypes.contains(type) else { return nil }
        return recycledViews[type]?.popLast()
    }
    
    func recycle(view: UIView, type: String) {
        guard registeredTypes.contains(type) else { return }
        view.removeFromSuperview()
        cleanupView(view)
        
        if (recycledViews[type]?.count ?? 0) < maxRecycledViews {
            recycledViews[type, default: []].append(view)
        }
    }
    
    private func cleanupView(_ view: UIView) {
        view.gestureRecognizers?.removeAll()
        view.layer.removeAllAnimations()
        view.transform = .identity
        
        if let imageView = view as? UIImageView {
            imageView.image = nil
        } else if let button = view as? UIButton {
            button.removeTarget(nil, action: nil, for: .allEvents)
        }
    }
    
    func clear() {
        recycledViews.removeAll()
    }
}
