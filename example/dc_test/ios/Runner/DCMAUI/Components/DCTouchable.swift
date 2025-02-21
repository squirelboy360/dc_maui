import UIKit

class DCTouchable: DCView {
    private var activeOpacity: CGFloat = 0.2
    private var defaultOpacity: CGFloat = 1.0
    
    override func setupDefaults() {
        super.setupDefaults()
        
        isUserInteractionEnabled = true
        
        // Add gesture recognizers
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(longPressGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(to: activeOpacity)
        eventHandlers["onPressIn"]?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(to: defaultOpacity)
        eventHandlers["onPressOut"]?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(to: defaultOpacity)
        eventHandlers["onPressOut"]?()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        eventHandlers["onPress"]?()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            eventHandlers["onLongPress"]?()
        }
    }
    
    private func animate(to opacity: CGFloat) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction) {
            self.alpha = opacity
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let activeOpacity = style["activeOpacity"] as? CGFloat {
            self.activeOpacity = activeOpacity
        }
    }
}
