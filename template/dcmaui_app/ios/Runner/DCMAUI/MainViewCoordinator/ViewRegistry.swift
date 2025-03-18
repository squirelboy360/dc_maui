//
//  ViewRegistry.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Registry for tracking native views
class ViewRegistry {
    // Map of view ID to view
    private var viewMap = [String: UIView]()
    
    // Map of parent ID to child IDs
    private var parentChildMap = [String: [String]]()
    
    // Map of child ID to parent ID
    private var childParentMap = [String: String]()
    
    /// Register a view with an ID
    func registerView(_ view: UIView, withId viewId: String) {
        // Add view to the registry
        viewMap[viewId] = view
        
        // Set view ID on DCBaseView if applicable
        if let dcView = view as? DCBaseView {
            // Instead of directly assigning to viewId (which is a let constant),
            // use an initializer method or another approach
            dcView.setViewIdIfNeeded(viewId)
        }
    }
    
    /// Get a view by its ID
    func getView(_ viewId: String) -> UIView? {
        return viewMap[viewId]
    }
    
    /// Remove a view and its children
    func removeView(_ viewId: String) {
        // Remove all child views first
        let childIds = parentChildMap[viewId] ?? []
        for childId in childIds {
            removeView(childId)
        }
        
        // Remove this view from parent's children list
        if let parentId = childParentMap[viewId] {
            parentChildMap[parentId]?.removeAll { $0 == viewId }
        }
        
        // Remove mappings
        childParentMap.removeValue(forKey: viewId)
        parentChildMap.removeValue(forKey: viewId)
        viewMap.removeValue(forKey: viewId)
    }
    
    /// Add a child view to a parent
    func addChild(_ childId: String, toParent parentId: String) {
        // Remove from previous parent if exists
        if let oldParentId = childParentMap[childId], oldParentId != parentId {
            parentChildMap[oldParentId]?.removeAll { $0 == childId }
        }
        
        // Add to new parent
        if parentChildMap[parentId] == nil {
            parentChildMap[parentId] = [childId]
        } else if !parentChildMap[parentId]!.contains(childId) {
            parentChildMap[parentId]!.append(childId)
        }
        
        // Update child->parent reference
        childParentMap[childId] = parentId
    }
    
    /// Set the children of a parent view
    func setChildren(_ childIds: [String], forParent parentId: String) {
        // Remove old parent references for current children
        let currentChildren = parentChildMap[parentId] ?? []
        for childId in currentChildren {
            if !childIds.contains(childId) {
                childParentMap.removeValue(forKey: childId)
            }
        }
        
        // Update parent->children map
        parentChildMap[parentId] = childIds
        
        // Update children->parent map
        for childId in childIds {
            childParentMap[childId] = parentId
        }
    }
    
    /// Get all registered views
    func getAllViews() -> [String: UIView] {
        return viewMap
    }
    
    /// Get the children of a view
    func getChildren(forParent parentId: String) -> [String] {
        return parentChildMap[parentId] ?? []
    }
    
    /// Get the parent of a view
    func getParent(forChild childId: String) -> String? {
        return childParentMap[childId]
    }
    
    /// Get a string representation of the view hierarchy
    func describeViewHierarchy() -> String {
        var description = "View Hierarchy:\n"
        
        // Find root views (those without parents)
        let rootViewIds = viewMap.keys.filter { !childParentMap.keys.contains($0) }
        
        for rootId in rootViewIds {
            if let rootView = viewMap[rootId] {
                description += describeView(rootView, viewId: rootId, depth: 0)
            }
        }
        
        return description
    }
    
    /// Describe a single view and its children
    private func describeView(_ view: UIView, viewId: String, depth: Int) -> String {
        let indent = String(repeating: "  ", count: depth)
        var description = "\(indent)- \(viewId): \(type(of: view))\n"
        
        // Add child descriptions
        let childIds = parentChildMap[viewId] ?? []
        for childId in childIds {
            if let childView = viewMap[childId] {
                description += describeView(childView, viewId: childId, depth: depth + 1)
            }
        }
        
        return description
    }
}
