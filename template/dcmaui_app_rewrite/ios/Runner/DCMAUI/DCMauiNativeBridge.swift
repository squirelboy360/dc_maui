import Flutter
import UIKit

@objc public class DCMauiNativeBridge: NSObject {
    // Singleton instance
    @objc public static let shared = DCMauiNativeBridge()
    
    // View registry to keep track of created views
    private var viewRegistry = [String: (view: UIView, componentType: String)]()
    
    // Root view for all DCMAUI components
    private var rootView: UIView?
    
    // Event callback for sending events back to Dart
    private var eventCallback: ((String, String, [String: Any]) -> Void)?
    
    private override init() {
        super.init()
    }
    
    // Called by FFI to initialize the native bridge
    @objc public func dcmaui_initialize() -> Int8 {
        print("DCMauiNativeBridge: initialize() called from FFI")
        // Set up any necessary initialization
        return 1
    }
    
    // Create a view with the given ID, type and properties
    @objc public func dcmaui_create_view(_ viewId: UnsafePointer<CChar>, 
                                      _ type: UnsafePointer<CChar>,
                                      _ propsJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let typeString = String(cString: type)
        let propsString = String(cString: propsJson)
        
        print("DCMauiNativeBridge: Creating view - ID: \(viewIdString), Type: \(typeString)")
        
        // Parse props JSON
        guard let propsData = propsString.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData) as? [String: Any] else {
            print("DCMauiNativeBridge: Failed to parse props JSON")
            return 0
        }
        
        // Get the component type from registry
        guard let componentType = DCMauiComponentRegistry.shared.getComponentType(for: typeString) else {
            print("DCMauiNativeBridge: Unsupported component type: \(typeString)")
            return 0
        }
        
        // Create the view using the component
        let view = componentType.createView(props: props)
        
        // Store in registry with component type info
        viewRegistry[viewIdString] = (view, typeString)
        
        print("DCMauiNativeBridge: View created successfully: \(viewIdString)")
        return 1
    }
    
    // Update a view's properties - now uses the stored component type
    @objc public func dcmaui_update_view(_ viewId: UnsafePointer<CChar>,
                                      _ propsJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let propsString = String(cString: propsJson)
        
        // Parse props JSON
        guard let propsData = propsString.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData) as? [String: Any],
              let viewInfo = viewRegistry[viewIdString] else {
            return 0
        }
        
        // Get component handler by the registered type and update
        let view = viewInfo.view
        let componentType = viewInfo.componentType
        
        if let handler = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
            handler.updateView(view, props: props)
            return 1
        }
        
        return 0
    }
    
    // Delete a view
    @objc public func dcmaui_delete_view(_ viewId: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        
        guard let view = viewRegistry[viewIdString]?.view else {
            return 0
        }
        
        // Remove from parent view
        view.removeFromSuperview()
        
        // Remove from registry
        viewRegistry.removeValue(forKey: viewIdString)
        
        return 1
    }
    
    // Attach a child view to a parent view
    @objc public func dcmaui_attach_view(_ childId: UnsafePointer<CChar>,
                                      _ parentId: UnsafePointer<CChar>,
                                      _ index: Int32) -> Int8 {
        let childIdString = String(cString: childId)
        let parentIdString = String(cString: parentId)
        
        guard let childView = viewRegistry[childIdString]?.view,
              let parentView = viewRegistry[parentIdString]?.view else {
            return 0
        }
        
        // Add child to parent
        parentView.addSubview(childView)
        
        // Position the view appropriately
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            childView.topAnchor.constraint(equalTo: parentView.topAnchor),
            childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
        
        return 1
    }
    
    // Set children for a view
    @objc public func dcmaui_set_children(_ viewId: UnsafePointer<CChar>,
                                       _ childrenJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let childrenString = String(cString: childrenJson)
        
        guard let childrenData = childrenString.data(using: .utf8),
              let childrenIds = try? JSONSerialization.jsonObject(with: childrenData) as? [String],
              let parentView = viewRegistry[viewIdString]?.view else {
            return 0
        }
        
        // Set z-order of children based on array order
        for (index, childId) in childrenIds.enumerated() {
            if let childView = viewRegistry[childId]?.view {
                parentView.insertSubview(childView, at: index)
            }
        }
        
        return 1
    }
    
    // Add event listeners to a view - uses the stored component type
    @objc public func dcmaui_add_event_listeners(_ viewId: UnsafePointer<CChar>,
                                              _ eventsJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let eventsString = String(cString: eventsJson)
        
        guard let eventsData = eventsString.data(using: .utf8),
              let eventNames = try? JSONSerialization.jsonObject(with: eventsData) as? [String],
              let viewInfo = viewRegistry[viewIdString] else {
            return 0
        }
        
        // Get the component handler by the registered type and add listeners
        let view = viewInfo.view
        let componentType = viewInfo.componentType
        
        // The key part is this delegation to the component handler:
        if let handler = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
            handler.addEventListeners(to: view, viewId: viewIdString, eventTypes: eventNames) { [weak self] viewId, eventType, eventData in
                self?.sendEventToDart(viewId: viewId, eventName: eventType, eventData: eventData)
            }
            return 1
        }
        
        return 0
    }
    
    // Remove event listeners from a view - uses the stored component type
    @objc public func dcmaui_remove_event_listeners(_ viewId: UnsafePointer<CChar>,
                                                 _ eventsJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let eventsString = String(cString: eventsJson)
        
        guard let eventsData = eventsString.data(using: .utf8),
              let eventNames = try? JSONSerialization.jsonObject(with: eventsData) as? [String],
              let viewInfo = viewRegistry[viewIdString] else {
            return 0
        }
        
        // Get the component handler by the registered type and remove listeners
        let view = viewInfo.view
        let componentType = viewInfo.componentType
        
        if let handler = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
            handler.removeEventListeners(from: view, viewId: viewIdString, eventTypes: eventNames)
            return 1
        }
        
        return 0
    }
    
    // Set the event callback function
    func setEventCallback(_ callback: @escaping (String, String, [String: Any]) -> Void) {
        self.eventCallback = callback
    }
    
    // Send an event back to Dart
    func sendEventToDart(viewId: String, eventName: String, eventData: [String: Any]) {
        // Call the local callback first
        eventCallback?(viewId, eventName, eventData)
        
        // DEBUG: Log the event for now
        print("DCMauiNativeBridge: Event fired - \(viewId) - \(eventName)")
        
        // In a complete implementation, this would properly forward to the C layer
    }
    
    // Method for direct view setup without going through C layer
    func manuallyCreateRootView(_ view: UIView, viewId: String, props: [String: Any]) {
        // Create the appropriate component type (assuming View)
        if let componentType = DCMauiComponentRegistry.shared.getComponentType(for: "View") {
            componentType.updateView(view, props: props)
            
            // Store in registry
            viewRegistry[viewId] = (view, "View")
            
            print("Root view manually created with ID: \(viewId)")
        }
    }
}
