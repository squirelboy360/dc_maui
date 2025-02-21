import UIKit

class DCSafeAreaView: DCView {
    private var edges: UIEdgeInsets = .zero
    
    override func setupDefaults() {
        super.setupDefaults()
        updateSafeAreaInsets()
    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        updateSafeAreaInsets()
    }
    
    private func updateSafeAreaInsets() {
        let safeArea = self.safeAreaInsets
        
        // Apply safe area as padding
        yoga.paddingTop = YGValue(value: Float(safeArea.top), unit: .point)
        yoga.paddingLeft = YGValue(value: Float(safeArea.left), unit: .point)
        yoga.paddingBottom = YGValue(value: Float(safeArea.bottom), unit: .point)
        yoga.paddingRight = YGValue(value: Float(safeArea.right), unit: .point)
        
        yoga.applyLayout(preservingOrigin: true)
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let edges = style["edges"] as? [String: Bool] {
            var insets = UIEdgeInsets.zero
            
            if edges["top"] == true {
                insets.top = safeAreaInsets.top
            }
            if edges["left"] == true {
                insets.left = safeAreaInsets.left
            }
            if edges["bottom"] == true {
                insets.bottom = safeAreaInsets.bottom
            }
            if edges["right"] == true {
                insets.right = safeAreaInsets.right
            }
            
            self.edges = insets
            updateSafeAreaInsets()
        }
    }
}
