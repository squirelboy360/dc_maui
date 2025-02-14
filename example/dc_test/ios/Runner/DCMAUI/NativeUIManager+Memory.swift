import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    func performMemoryCleanup() {
        accessQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // Clear unused views
            let activeViewIds = Set(self.childViews.values.flatMap { $0 })
            let allViewIds = Set(self.views.keys)
            
            let unusedViewIds = allViewIds.subtracting(activeViewIds)
            for viewId in unusedViewIds {
                self.views.removeValue(forKey: viewId)
                self.childViews.removeValue(forKey: viewId)
                if let recognizers = self.registeredGestureRecognizers[viewId] {
                    for recognizer in recognizers {
                        recognizer.view?.removeGestureRecognizer(recognizer)
                    }
                    self.registeredGestureRecognizers.removeValue(forKey: viewId)
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
