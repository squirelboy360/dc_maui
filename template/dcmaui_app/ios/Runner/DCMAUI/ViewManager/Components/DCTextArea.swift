//
//  DCTextArea.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Text area control for multi-line text entry
class DCTextArea: DCBaseView, UITextViewDelegate {
    private let textView = UITextView()
    private var placeholderLabel: UILabel?
    private var placeholderText: String?
    
    override func setupView() {
        super.setupView()
        
        // Configure text view
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5.0
        textView.clipsToBounds = true
        
        // Add to view hierarchy
        addSubview(textView)
        
        // Layout constraints - make it fill the container
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Create placeholder label
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.isHidden = true  // Initially hidden, will show if needed
        
        textView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -5),
            label.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
        ])
        
        self.placeholderLabel = label
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel?.isHidden = (textView.text.count > 0)
    }
    
    // UITextViewDelegate methods
    func textViewDidChange(_ textView: UITextView) {
        guard let viewId = self.viewId else { return }
        updatePlaceholderVisibility()
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onChangeText", data: textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onFocus", data: nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let viewId = self.viewId else { return }
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onBlur", data: nil)
        MainViewCoordinator.shared.emitEvent(viewId: viewId, eventName: "onSubmitEditing", data: textView.text)
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle value
        if let value = props["value"] as? String {
            textView.text = value
            updatePlaceholderVisibility()
        }
        
        // Handle placeholder
        if let placeholder = props["placeholder"] as? String {
            placeholderText = placeholder
            placeholderLabel?.text = placeholder
            updatePlaceholderVisibility()
        }
        
        // Handle placeholder style
        if let placeholderStyle = props["placeholderStyle"] as? [String: Any] {
            if let colorHex = placeholderStyle["color"] as? String, colorHex.hasPrefix("#"),
               let placeholderColor = UIColor(hexString: colorHex) {
                placeholderLabel?.textColor = placeholderColor
            }
            
            if let fontSize = placeholderStyle["fontSize"] as? CGFloat {
                placeholderLabel?.font = UIFont.systemFont(ofSize: fontSize)
            }
        }
        
        // Handle text style
        if let style = props["style"] as? [String: Any] {
            if let colorHex = style["color"] as? String, colorHex.hasPrefix("#"),
               let textColor = UIColor(hexString: colorHex) {
                textView.textColor = textColor
            }
            
            if let fontSize = style["fontSize"] as? CGFloat {
                textView.font = UIFont.systemFont(ofSize: fontSize)
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
                
                if let fontSize = textView.font?.pointSize {
                    textView.font = UIFont.systemFont(ofSize: fontSize, weight: weightValue)
                }
            }
        }
        
        // Handle input style
        if let inputStyle = props["inputStyle"] as? [String: Any] {
            if let colorHex = inputStyle["backgroundColor"] as? String, colorHex.hasPrefix("#"),
               let bgColor = UIColor(hexString: colorHex) {
                textView.backgroundColor = bgColor
            }
            
            if let borderColorHex = inputStyle["borderColor"] as? String, borderColorHex.hasPrefix("#"),
               let borderColor = UIColor(hexString: borderColorHex) {
                textView.layer.borderColor = borderColor.cgColor
            }
            
            if let borderWidth = inputStyle["borderWidth"] as? CGFloat {
                textView.layer.borderWidth = borderWidth
            }
            
            if let borderRadius = inputStyle["borderRadius"] as? CGFloat {
                textView.layer.cornerRadius = borderRadius
            }
            
            // Handle padding (for TextView, this requires insets)
            if let paddingValue = inputStyle["padding"] as? CGFloat {
                textView.textContainerInset = UIEdgeInsets(top: paddingValue, left: paddingValue, 
                                                          bottom: paddingValue, right: paddingValue)
            }
        }
        
        // Handle editable state
        if let editable = props["editable"] as? Bool {
            textView.isEditable = editable
        }
        
        // Handle auto focus
        if let autoFocus = props["autoFocus"] as? Bool, autoFocus {
            textView.becomeFirstResponder()
        }
        
        // Handle text alignment
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "left": textView.textAlignment = .left
            case "right": textView.textAlignment = .right
            case "center": textView.textAlignment = .center
            case "justify": textView.textAlignment = .justified
            default: textView.textAlignment = .left
            }
        }
    }
}
