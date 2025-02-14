import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    func setupAutomaticCleanup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBackgroundTransition),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        performMemoryCleanup()
        viewRecycler.clear()
    }
    
    @objc private func handleBackgroundTransition() {
        saveState()
    }
    
    func performMemoryCleanup() {
        accessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Find unused views
            let activeViewIds = Set(self.childViews.values.flatMap { $0 })
            let allViewIds = Set(self.views.keys)
            let unusedViewIds = allViewIds.subtracting(activeViewIds)
            
            // Recycle unused views
            for viewId in unusedViewIds {
                self.safeRemoveView(viewId)
            }
            
            // Clear empty state bindings
            for (key, viewIds) in self.stateBindings {
                self.stateBindings[key] = viewIds.filter { self.views[$0] != nil }
                if self.stateBindings[key]?.isEmpty ?? true {
                    self.stateBindings.removeValue(forKey: key)
                }
            }
            
            // Clear recycled views if memory is tight
            if UIApplication.shared.applicationState == .background {
                self.viewRecycler.clear()
            }
        }
    }
}
