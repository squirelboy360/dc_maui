import UIKit

class DCTextInput: DCView {
    private let textField = UITextField()
    
    override func setupDefaults() {
        super.setupDefaults()
        textField.yoga.isEnabled = true
        addSubview(textField)
        
        textField.yoga.position = .absolute
        textField.yoga.left = .zero
        textField.yoga.top = .zero
        textField.yoga.right = .zero
        textField.yoga.bottom = .zero
        
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    @objc private func textChanged() {
        if let callback = eventHandlers["onTextChange"] {
            callback()
        }
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        if let text = newState["text"] as? String {
            textField.text = text
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let textStyle = style["textStyle"] as? [String: Any] {
            if let color = textStyle["color"] as? UInt32 {
                textField.textColor = UIColor(rgb: color)
            }
            if let fontSize = textStyle["fontSize"] as? CGFloat {
                textField.font = .systemFont(ofSize: fontSize)
            }
            if let placeholder = textStyle["placeholder"] as? String {
                textField.placeholder = placeholder
            }
        }
        
        if let keyboard = style["keyboard"] as? [String: Any] {
            if let type = keyboard["type"] as? String {
                textField.keyboardType = KeyboardType(rawValue: type)?.uiKeyboardType ?? .default
            }
            if let returnKey = keyboard["returnKeyType"] as? String {
                textField.returnKeyType = ReturnKeyType(rawValue: returnKey)?.uiReturnKeyType ?? .default
            }
        }
    }
}

private enum KeyboardType: String {
    case `default`, number, email, phone
    
    var uiKeyboardType: UIKeyboardType {
        switch self {
        case .default: return .default
        case .number: return .numberPad
        case .email: return .emailAddress
        case .phone: return .phonePad
        }
    }
}

private enum ReturnKeyType: String {
    case done, go, next, search, send
    
    var uiReturnKeyType: UIReturnKeyType {
        switch self {
        case .done: return .done
        case .go: return .go
        case .next: return .next
        case .search: return .search
        case .send: return .send
        }
    }
}
