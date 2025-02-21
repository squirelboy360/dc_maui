import UIKit

class DCText: DCView {
    private let label = UILabel()
    
    init(viewId: String, text: String) {
        super.init(viewId: viewId)
        setupLabel(withText: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func setupLabel(withText text: String) {
        label.text = text
        label.numberOfLines = 0
        label.yoga.isEnabled = true
        addSubview(label)
        
        // Make label fill parent
        label.yoga.position = .absolute
        label.yoga.left = YGValue(value: 0, unit: .point)
        label.yoga.top = YGValue(value: 0, unit: .point)
        label.yoga.right = YGValue(value: 0, unit: .point)
        label.yoga.bottom = YGValue(value: 0, unit: .point)
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        if let text = newState["text"] as? String {
            label.text = text
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let textStyle = style["textStyle"] as? [String: Any] {
            if let color = textStyle["color"] as? UInt32 {
                label.textColor = UIColor(rgb: color)
            }
            if let fontSize = textStyle["fontSize"] as? CGFloat {
                label.font = .systemFont(ofSize: fontSize)
            }
            if let alignment = textStyle["textAlign"] as? String {
                label.textAlignment = TextAlignment(rawValue: alignment)?.nsTextAlignment ?? .left
            }
        }
    }
}

private enum TextAlignment: String {
    case left, center, right, justify
    
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justify: return .justified
        }
    }
}
