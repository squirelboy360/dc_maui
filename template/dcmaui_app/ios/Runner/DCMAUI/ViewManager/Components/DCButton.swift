import UIKit

/// Button component similar to React Native's TouchableOpacity+Text
class DCButton: DCBaseView {
    private let button = UIButton(type: .system)
    
    // Touchable properties
    private var activeOpacity: CGFloat = 0.2
    private var delayLongPress: TimeInterval = 0.5
    private var delayPressIn: TimeInterval = 0
    private var delayPressOut: TimeInterval = 0
    private var disabled: Bool = false
    private var pressOutTimeout: Timer?
    private var pressInTimeout: Timer?
    
    override func setupView() {
        super.setupView()
        
        // Configure button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5.0
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.setTitle("Button", for: .normal)
        
        addSubview(button)
        
        // Constrain button to fill the view
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set default size
        frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        
        // Set up direct touch handling (not relying on UIButton's target-action)
        isUserInteractionEnabled = true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Update button properties
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        // Touchable properties
        if let disabled = props["disabled"] as? Bool {
            self.disabled = disabled
            button.isEnabled = !disabled
            button.alpha = disabled ? 0.5 : 1.0
        }
        
        if let activeOpacity = props["activeOpacity"] as? CGFloat {
            self.activeOpacity = activeOpacity
        }
        
        if let delayLongPress = props["delayLongPress"] as? TimeInterval {
            self.delayLongPress = delayLongPress
        }
        
        if let delayPressIn = props["delayPressIn"] as? TimeInterval {
            self.delayPressIn = delayPressIn
        }
        
        if let delayPressOut = props["delayPressOut"] as? TimeInterval {
            self.delayPressOut = delayPressOut
        }
        
        // Apply style properties
        if let style = props["style"] as? [String: Any] {
            applyButtonStyle(style)
        }
        
        // Force layout
        setNeedsLayout()
    }
    
    private func applyButtonStyle(_ style: [String: Any]) {
        // Background color
        if let backgroundColor = style["backgroundColor"] as? String, backgroundColor.hasPrefix("#") {
            button.backgroundColor = UIColor(hexString: backgroundColor)
        }
        
        // Text style properties
        var font = button.titleLabel?.font ?? UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        
        // Font size
        if let fontSize = style["fontSize"] as? CGFloat {
            font = UIFont.systemFont(ofSize: fontSize)
        }
        
        // Font weight
        if let fontWeight = style["fontWeight"] as? String {
            var weight = UIFont.Weight.regular
            
            switch fontWeight {
            case "bold": weight = .bold
            case "normal": weight = .regular
            case "100": weight = .ultraLight
            case "200": weight = .thin
            case "300": weight = .light
            case "400": weight = .regular
            case "500": weight = .medium
            case "600": weight = .semibold
            case "700": weight = .bold
            case "800": weight = .heavy
            case "900": weight = .black
            default: break
            }
            
            font = UIFont.systemFont(ofSize: font.pointSize, weight: weight)
        }
        
        // Text color
        if let textColor = style["color"] as? String, textColor.hasPrefix("#") {
            button.setTitleColor(UIColor(hexString: textColor), for: .normal)
        }
        
        // Border radius
        if let borderRadius = style["borderRadius"] as? CGFloat {
            button.layer.cornerRadius = borderRadius
            button.clipsToBounds = true
        }
        
        // Apply font
        button.titleLabel?.font = font
    }
    
    // MARK: - Touch Handling (React Native style)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if disabled { return }
        
        // Cancel any existing timeouts
        pressInTimeout?.invalidate()
        pressOutTimeout?.invalidate()
        
        // Schedule onPressIn with delay (React Native behavior)
        if delayPressIn > 0 {
            pressInTimeout = Timer.scheduledTimer(withTimeInterval: delayPressIn, repeats: false) { [weak self] _ in
                self?.handlePressIn(touches.first)
            }
        } else {
            handlePressIn(touches.first)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if disabled { return }
        
        // Cancel any existing timeouts
        pressInTimeout?.invalidate()
        pressOutTimeout?.invalidate()
        
        // Check if touch ended inside view bounds (for press event)
        let isInside = touches.first.map { touch in
            bounds.contains(touch.location(in: self))
        } ?? false
        
        // Schedule onPressOut with delay (React Native behavior)
        if delayPressOut > 0 {
            pressOutTimeout = Timer.scheduledTimer(withTimeInterval: delayPressOut, repeats: false) { [weak self] _ in
                self?.handlePressOut(touches.first)
                
                // Send onPress only if touch ended inside view
                if isInside {
                    self?.handlePress(touches.first)
                }
            }
        } else {
            handlePressOut(touches.first)
            
            // Send onPress only if touch ended inside view
            if isInside {
                handlePress(touches.first)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if disabled { return }
        
        // Cancel any existing timeouts
        pressInTimeout?.invalidate()
        pressOutTimeout?.invalidate()
        
        // Handle press out immediately on cancel (React Native behavior)
        handlePressOut(touches.first)
    }
    
    // MARK: - Event Handlers
    
    private func handlePressIn(_ touch: UITouch?) {
        // Apply active opacity
        UIView.animate(withDuration: 0.15) {
            self.button.alpha = self.activeOpacity
        }
        
        // Create event data
        var eventData: [String: Any] = [
            "target": viewId,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]
        
        // Add touch location data if available
        if let touch = touch {
            let point = touch.location(in: self)
            let pagePoint = touch.location(in: nil)
            
            eventData["locationX"] = point.x
            eventData["locationY"] = point.y
            eventData["pageX"] = pagePoint.x
            eventData["pageY"] = pagePoint.y
        }
        
        // Send event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onPressIn",
            params: eventData
        )
    }
    
    private func handlePressOut(_ touch: UITouch?) {
        // Restore original opacity
        UIView.animate(withDuration: 0.15) {
            self.button.alpha = self.disabled ? 0.5 : 1.0
        }
        
        // Create event data
        var eventData: [String: Any] = [
            "target": viewId,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]
        
        // Add touch location data if available
        if let touch = touch {
            let point = touch.location(in: self)
            let pagePoint = touch.location(in: nil)
            
            eventData["locationX"] = point.x
            eventData["locationY"] = point.y
            eventData["pageX"] = pagePoint.x
            eventData["pageY"] = pagePoint.y
        }
        
        // Send event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onPressOut",
            params: eventData
        )
    }
    
    private func handlePress(_ touch: UITouch?) {
        // Create event data
        var eventData: [String: Any] = [
            "target": viewId,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]
        
        // Add touch location data if available
        if let touch = touch {
            let point = touch.location(in: self)
            let pagePoint = touch.location(in: nil)
            
            eventData["locationX"] = point.x
            eventData["locationY"] = point.y
            eventData["pageX"] = pagePoint.x
            eventData["pageY"] = pagePoint.y
        }
        
        // Send onPress event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onPress",
            params: eventData
        )
    }
    
    // Size handling methods
    override var intrinsicContentSize: CGSize {
        let buttonSize = button.intrinsicContentSize
        return CGSize(
            width: max(buttonSize.width + 32, 100),
            height: max(buttonSize.height + 16, 44)
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let buttonSize = button.sizeThatFits(size)
        return CGSize(
            width: max(buttonSize.width, 100),
            height: max(buttonSize.height, 44)
        )
    }
}
