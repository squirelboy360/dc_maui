import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    // Thread-safe view access queue
    private let accessQueue = DispatchQueue(label: "com.dcmaui.accessQueue", attributes: .concurrent)
    
    // Thread-safe view access
    func safeGetView(_ viewId: String) -> UIView? {
        accessQueue.sync { views[viewId] }
    }
    
    func safeSetView(_ view: UIView, forId viewId: String) {
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.views[viewId] = view
            self?.viewRecycler.register(viewType: String(describing: type(of: view)))
        }
    }
    
    func safeRemoveView(_ viewId: String) {
        accessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if let view = self.views[viewId] {
                self.viewRecycler.recycle(view: view, type: String(describing: type(of: view)))
                self.views.removeValue(forKey: viewId)
            }
        }
    }
}
