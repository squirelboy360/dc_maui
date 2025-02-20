import UIKit
import Flutter

@available(iOS 13.0, *)
extension NativeUIManager {
    internal enum EventType: String {
        case onPress
        case onLongPress
        case onPressIn
        case onPressOut
        case onDoubleTap
        case onPanStart
        case onPanUpdate
        case onPanEnd
        case onScaleStart
        case onScaleUpdate
        case onScaleEnd
        case onScroll
        case onScrollEnd
    }
    
    internal struct EventData {
        let viewId: String
        let type: EventType
        let timestamp: TimeInterval
        var location: CGPoint?
        var scale: CGFloat?
        var translation: CGPoint?
        var velocity: CGPoint?
        
        var toDictionary: [String: Any] {
            var dict: [String: Any] = [
                "viewId": viewId,
                "type": type.rawValue,
                "timestamp": timestamp
            ]
            
            if let location = location {
                dict["x"] = location.x
                dict["y"] = location.y
            }
            
            if let scale = scale {
                dict["scale"] = scale
            }
            
            if let translation = translation {
                dict["translation"] = ["x": translation.x, "y": translation.y]
            }
            
            if let velocity = velocity {
                dict["velocity"] = ["x": velocity.x, "y": velocity.y]
            }
            
            return dict
        }
    }
    
    internal func registerEvent(_ viewId: String, type: EventType) {
        guard let view = views[viewId] else { return }
        
        switch type {
        case .onPress, .onPressIn, .onPressOut, .onLongPress:
            setupButtonEvent(view, viewId: viewId, type: type)
        case .onPanStart, .onPanUpdate, .onPanEnd:
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            view.addGestureRecognizer(panGesture)
            registeredGestureRecognizers[viewId, default: []].append(panGesture)
        case .onScaleStart, .onScaleUpdate, .onScaleEnd:
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            view.addGestureRecognizer(pinchGesture)
            registeredGestureRecognizers[viewId, default: []].append(pinchGesture)
        case .onScroll, .onScrollEnd:
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        case .onDoubleTap:
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleButtonDoublePress(_:)))
            doubleTap.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTap)
        }
    }
    
    internal func setupButtonEvent(_ view: UIView, viewId: String, type: EventType) {
        guard let button = view as? UIButton else { return }
        
        switch type {
        case .onPress:
            button.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        case .onLongPress:
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleButtonLongPress(_:)))
            button.addGestureRecognizer(longPress)
        case .onPressIn:
            button.addTarget(self, action: #selector(handleButtonPressIn(_:)), for: .touchDown)
        case .onPressOut:
            button.addTarget(self, action: #selector(handleButtonPressOut(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        case .onDoubleTap:
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleButtonDoublePress(_:)))
            doubleTap.numberOfTapsRequired = 2
            button.addGestureRecognizer(doubleTap)
        case .onPanStart, .onPanUpdate, .onPanEnd,
                .onScaleStart, .onScaleUpdate, .onScaleEnd,
                .onScroll, .onScrollEnd:
            // These events are not applicable to buttons
            break
        }
    }
    
    @objc internal func handleButtonClick(_ sender: UIButton) {
        guard let viewId = getViewId(for: sender) else { return }
        let data = EventData(
            viewId: viewId,
            type: .onPress,
            timestamp: Date().timeIntervalSince1970
        )
        sendEventToFlutter(data)
    }
    
    @objc internal func handleButtonPressIn(_ sender: UIButton) {
        guard let viewId = getViewId(for: sender) else { return }
        let data = EventData(
            viewId: viewId,
            type: .onPressIn,
            timestamp: Date().timeIntervalSince1970
        )
        sendEventToFlutter(data)
    }
    
    @objc internal func handleButtonPressOut(_ sender: UIButton) {
        guard let viewId = getViewId(for: sender) else { return }
        let data = EventData(
            viewId: viewId,
            type: .onPressOut,
            timestamp: Date().timeIntervalSince1970
        )
        sendEventToFlutter(data)
    }
    
    @objc internal func handleButtonLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let button = sender.view as? UIButton,
              let viewId = getViewId(for: button),
              sender.state == .began else { return }
        
        let data = EventData(
            viewId: viewId,
            type: .onLongPress,
            timestamp: Date().timeIntervalSince1970,
            location: sender.location(in: button)
        )
        sendEventToFlutter(data)
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view,
              let viewId = getViewId(for: view) else { return }
        
        let type: EventType
        switch sender.state {
        case .began: type = .onPanStart
        case .changed: type = .onPanUpdate
        case .ended, .cancelled: type = .onPanEnd
        default: return
        }
        
        let data = EventData(
            viewId: viewId,
            type: type,
            timestamp: Date().timeIntervalSince1970,
            location: sender.location(in: view),
            translation: sender.translation(in: view),
            velocity: sender.velocity(in: view)
        )
        sendEventToFlutter(data)
    }
    
    @objc private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view,
              let viewId = getViewId(for: view) else { return }
        
        let type: EventType
        switch sender.state {
        case .began: type = .onScaleStart
        case .changed: type = .onScaleUpdate
        case .ended, .cancelled: type = .onScaleEnd
        default: return
        }
        
        let data = EventData(
            viewId: viewId,
            type: type,
            timestamp: Date().timeIntervalSince1970,
            location: sender.location(in: view),
            scale: sender.scale
        )
        sendEventToFlutter(data)
    }
    
    @objc internal func handleTouchablePress(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let viewId = getViewId(for: view) else { return }
        let data = EventData(
            viewId: viewId,
            type: .onPress,
            timestamp: Date().timeIntervalSince1970,
            location: sender.location(in: view)
        )
        sendEventToFlutter(data)
    }
    
    @objc internal func handleTouchableDoublePress(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let viewId = getViewId(for: view) else { return }
        let data = EventData(
            viewId: viewId,
            type: .onDoubleTap,
            timestamp: Date().timeIntervalSince1970,
            location: sender.location(in: view)
        )
        sendEventToFlutter(data)
    }
    
    @objc private func handleButtonDoublePress(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view as? UIButton,
              let viewId = getViewId(for: button) else { return }
        
        let data = EventData(
            viewId: viewId,
            type: .onDoubleTap,
            timestamp: Date().timeIntervalSince1970,
            location: sender.location(in: button)
        )
        sendEventToFlutter(data)
    }
    
    internal func sendEventToFlutter(_ event: EventData) {
        methodChannel?.invokeMethod("onNativeEvent", arguments: event.toDictionary)
    }
    
}
