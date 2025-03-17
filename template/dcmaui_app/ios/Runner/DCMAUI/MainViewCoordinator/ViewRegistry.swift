import UIKit

/// Class to manage view registry for DCViewCoordinator
class ViewRegistry {
    // Map of view IDs to views
    private var views: [String: UIView] = [:]
    
    // Map of parent view IDs to child view IDs
    private var childViews: [String: [String]] = [:]
    
    // Register a view
    func registerView(_ view: UIView, withId viewId: String) {
        views[viewId] = view
        // Initialize empty children array
        if childViews[viewId] == nil {
            childViews[viewId] = []
        }
    }
    
    // Get a view by ID
    func getView(_ viewId: String) -> UIView? {
        return views[viewId]
    }
    
    // Add a child to a parent
    func addChild(_ childId: String, toParent parentId: String) {
        childViews[parentId] = childViews[parentId] ?? []
        if !childViews[parentId]!.contains(childId) {
            childViews[parentId]!.append(childId)
        }
    }
    
    // Set all children for a parent
    func setChildren(_ childIds: [String], forParent parentId: String) {
        childViews[parentId] = childIds
    }
    
    // Get children for a parent
    func getChildren(forParent parentId: String) -> [String] {
        return childViews[parentId] ?? []
    }
    
    // Remove a view and its children
    func removeView(_ viewId: String) {
        // Remove view and any references to it
        views.removeValue(forKey: viewId)
        
        // Remove any children references
        if let children = childViews[viewId] {
            for childId in children {
                removeView(childId)
            }
        }
        childViews.removeValue(forKey: viewId)
        
        // Remove from any parent's children list
        for (parentId, children) in childViews {
            if children.contains(viewId) {
                childViews[parentId] = children.filter { $0 != viewId }
            }
        }
    }
    
    // Clear the entire registry
    func clear() {
        views.removeAll()
        childViews.removeAll()
    }
    
    // Get a description of the view hierarchy
    func describeViewHierarchy() -> String {
        var description = "View Hierarchy:\n"
        
        // Find root views (those not in any children arrays)
        let allChildIds = Set(childViews.values.flatMap { $0 })
        let rootViewIds = Set(views.keys).subtracting(allChildIds)
        
        for rootId in rootViewIds {
            description += describeView(rootId, depth: 0)
        }
        
        return description
    }
    
    private func describeView(_ viewId: String, depth: Int) -> String {
        guard let view = views[viewId] else {
            return ""
        }
        
        let indent = String(repeating: "  ", count: depth)
        var result = "\(indent)- \(viewId): \(type(of: view))"
        
        if let children = childViews[viewId] {
            for childId in children {
                result += "\n" + describeView(childId, depth: depth + 1)
            }
        }
        
        return result
    }
}
