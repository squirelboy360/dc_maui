//
//  DCTextInput.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Text input control for single-line text entry
class DCTextInput: DCBaseView, UITextFieldDelegate {
    private let textField = UITextField()
    
    override func setupView() {
        super.setupView()
        
        // Configure text field
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.returnKeyType = .done
        
        // Add to view hierarchy
        addSubview(textField)
        
        // Layout constraints - make it fill the container
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set up event handling
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Emit onChangeText event
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onChangeText", data: textField.text ?? "")
    }
    
    // UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onFocus", data: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onBlur", data: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let viewId = self.viewId else { return true }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onSubmitEditing", data: textField.text ?? "")
        return true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle value
        if let value = props["value"] as? String {
            textField.text = value
        }
        
        // Handle placeholder
        if let placeholder = props["placeholder"] as? String {
            textField.placeholder = placeholder
        }
        
        // Handle placeholder style
        if let placeholderStyle = props["placeholderStyle"] as? [String: Any] {
            if let colorHex = placeholderStyle["color"] as? String, colorHex.hasPrefix("#"),
               let placeholderColor = UIColor(hexString: colorHex) {
                
                let placeholder = textField.placeholder ?? ""
                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: placeholderColor]
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
            }
        }
        
        // Handle text style
        if let style = props["style"] as? [String: Any] {
            if let colorHex = style["color"] as? String, colorHex.hasPrefix("#"),
               let textColor = UIColor(hexString: colorHex) {
                textField.textColor = textColor
            }
            
            if let fontSize = style["fontSize"] as? CGFloat {
                textField.font = UIFont.systemFont(ofSize: fontSize)
            }
            
            if let fontWeight = style["fontWeight"] as? String {
                var weightValue: UIFont.Weight = .regular
                
                switch fontWeight {
                case "bold": weightValue = .bold
                case "normal": weightValue = .regular
                case "100": weightValue = .ultraLight
                case "200": weightValue = .thin
                case "300": weightValue = .light
                case "400": weightValue = .regular
                case "500": weightValue = .medium
                case "600": weightValue = .semibold
                case "700": weightValue = .bold
                case "800": weightValue = .heavy
                case "900": weightValue = .black
                default: weightValue = .regular
                }
                
                if let fontSize = textField.font?.pointSize {
                    textField.font = UIFont.systemFont(ofSize: fontSize, weight: weightValue)
                }
            }
        }
        
        // Handle input style
        if let inputStyle = props["inputStyle"] as? [String: Any] {
            if let colorHex = inputStyle["backgroundColor"] as? String, colorHex.hasPrefix("#"),
               let bgColor = UIColor(hexString: colorHex) {
                textField.backgroundColor = bgColor
            }
            
            if let borderColorHex = inputStyle["borderColor"] as? String, borderColorHex.hasPrefix("#"),
               let borderColor = UIColor(hexString: borderColorHex) {
                textField.layer.borderColor = borderColor.cgColor
            }
            
            if let borderWidth = inputStyle["borderWidth"] as? CGFloat {
                textField.layer.borderWidth = borderWidth
                textField.borderStyle = .none  // Remove default style when using custom border
            }
            
            if let borderRadius = inputStyle["borderRadius"] as? CGFloat {
                textField.layer.cornerRadius = borderRadius
                textField.clipsToBounds = true
            }
            
            if let paddingValue = inputStyle["padding"] as? CGFloat {
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingValue, height: textField.frame.height))
                textField.leftView = paddingView
                textField.leftViewMode = .always
                
                let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingValue, height: textField.frame.height))
                textField.rightView = rightPaddingView
                textField.rightViewMode = .always
            }
        }
        
        // Handle editable state
        if let editable = props["editable"] as? Bool {
            textField.isEnabled = editable
        }
        
        // Handle keyboard type
        if let keyboardType = props["keyboardType"] as? String {
            switch keyboardType {
            case "numeric": textField.keyboardType = .numberPad
            case "phone-pad": textField.keyboardType = .phonePad
            case "email-address": textField.keyboardType = .emailAddress
            case "url": textField.keyboardType = .URL
            case "visible-password": 
                textField.keyboardType = .default
                textField.isSecureTextEntry = false
            default: textField.keyboardType = .default
            }
        }
        
        // Handle secure text entry
        if let secureTextEntry = props["secureTextEntry"] as? Bool {
            textField.isSecureTextEntry = secureTextEntry
        }
        
        // Handle auto focus
        if let autoFocus = props["autoFocus"] as? Bool, autoFocus {
            textField.becomeFirstResponder()
        }
        
        // Handle text alignment
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "left": textField.textAlignment = .left
            case "right": textField.textAlignment = .right
            case "center": textField.textAlignment = .center
            default: textField.textAlignment = .left
            }
        }
        
        // Handle iOS-specific props
        if let clearButtonMode = props["clearButtonMode"] as? String {
            switch clearButtonMode {
            case "never": textField.clearButtonMode = .never
            case "while-editing": textField.clearButtonMode = .whileEditing
            case "unless-editing": textField.clearButtonMode = .unlessEditing
            case "always": textField.clearButtonMode = .always
            default: textField.clearButtonMode = .whileEditing
            }
        }
        
        if let returnKeyType = props["returnKeyType"] as? String {
            switch returnKeyType {
            case "done": textField.returnKeyType = .done
            case "go": textField.returnKeyType = .go
            case "next": textField.returnKeyType = .next
            case "search": textField.returnKeyType = .search
            case "send": textField.returnKeyType = .send
            default: textField.returnKeyType = .default
            }
        }
    }
}

// Helper extension for UIColor from hex (if not already defined elsewhere)
extension UIColor {
    convenience init?(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        var hexInt: UInt64 = 0
        
        let scanner = Scanner(string: hexString.replacingOccurrences(of: "#", with: ""))
        guard scanner.scanHexInt64(&hexInt) else { return nil }
        
        let red, green, blue, alpha: CGFloat
        
        if hexString.count == 9 {
            // 8-digit hex (with alpha)
            alpha = CGFloat((hexInt & 0xFF000000) >> 24) / 255
            red = CGFloat((hexInt & 0x00FF0000) >> 16) / 255
            green = CGFloat((hexInt & 0x0000FF00) >> 8) / 255
            blue = CGFloat(hexInt & 0x000000FF) / 255
        } else {
            // 6-digit hex (assumes full opacity)
            red = CGFloat((hexInt & 0xFF0000) >> 16) / 255
            green = CGFloat((hexInt & 0x00FF00) >> 8) / 255
            blue = CGFloat(hexInt & 0x0000FF) / 255
            alpha = 1.0
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
