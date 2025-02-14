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
        cleanupUnusedViews()
        clearImageCache()
    }
    
    @objc private func handleBackgroundTransition() {
        saveState()
    }
    
    private func cleanupUnusedViews() {
        viewAccessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            let activeViewIds = Set(self.childViews.values.flatMap { $0 })
            let allViewIds = Set(self.views.keys)
            let unusedViewIds = allViewIds.subtracting(activeViewIds)
            
            for viewId in unusedViewIds {
                self.views.removeValue(forKey: viewId)
                self.childViews.removeValue(forKey: viewId)
            }
            
            // Using internal stateBindings
            for (key, viewIds) in self.stateBindings {
                self.stateBindings[key] = viewIds.filter { self.views[$0] != nil }
                if self.stateBindings[key]?.isEmpty ?? true {
                    self.stateBindings.removeValue(forKey: key)
                }
            }
        }
    }
    
    private func clearImageCache() {
        IconRegistry.shared.clearCache()
    }
}
