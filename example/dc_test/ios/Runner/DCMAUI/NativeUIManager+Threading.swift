import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    // Remove stored property and use the one from main class
    
    // Thread-safe view access
    func safeGetView(_ viewId: String) -> UIView? {
        accessQueue.sync { views[viewId] }
    }
    
    func safeSetView(_ view: UIView, forId viewId: String) {
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.views[viewId] = view
        }
    }
    
    func safeRemoveView(_ viewId: String) {
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.views.removeValue(forKey: viewId)
        }
    }
}
