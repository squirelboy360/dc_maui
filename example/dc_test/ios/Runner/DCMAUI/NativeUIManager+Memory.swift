import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    func performMemoryCleanup() {
        viewAccessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Clear unused views
            let activeViewIds = Set(self.childViews.values.flatMap { $0 })
            let allViewIds = Set(self.views.keys)
            
            let unusedViewIds = allViewIds.subtracting(activeViewIds)
            for viewId in unusedViewIds {
                self.views.removeValue(forKey: viewId)
                self.childViews.removeValue(forKey: viewId)
                self.registeredGestureRecognizers.removeValue(forKey: viewId)
            }
            
            // Clear gesture recognizers
            for (viewId, recognizers) in self.registeredGestureRecognizers {
                guard let view = self.views[viewId] else {
                    self.registeredGestureRecognizers.removeValue(forKey: viewId)
                    continue
                }
                
                for recognizer in recognizers where recognizer.view == nil {
                    if let index = self.registeredGestureRecognizers[viewId]?.firstIndex(of: recognizer) {
                        self.registeredGestureRecognizers[viewId]?.remove(at: index)
                    }
                }
            }
            
            // Clear empty state bindings
            for (key, viewIds) in self.stateBindings {
                self.stateBindings[key] = viewIds.filter { self.views[$0] != nil }
                if self.stateBindings[key]?.isEmpty ?? true {
                    self.stateBindings.removeValue(forKey: key)
                }
            }
        }
    }
}
