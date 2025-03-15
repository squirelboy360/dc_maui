/*
 BSD 3-Clause License

Copyright (c) 2025, Tahiru Agbanwa

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import Combine

/**
 DCTextInput: Native text input component

 Expected Input Properties:
 {
   "inputStyle": {
     "placeholder": String,          // Placeholder text
     "textColor": UInt32,           // Text color as ARGB
     "fontSize": CGFloat,           // Font size in points
     "textAlign": String,           // "left", "center", "right"
     "keyboardType": String,        // "default", "number", "email", "phone", "url"
     "returnKeyType": String,       // "done", "go", "next", "search", "send"
     "isSecure": Bool,             // Password input mode
     "autocorrection": Bool,       // Enable/disable autocorrection
     "contentType": String,        // "username", "password", "email", etc.
     "toolbarStyle": String       // "default", "dark"
   },
   "layout": {
     // Yoga layout properties
   }
 }

 Event Data Emitted:
 onTextChange: {
   "text": String,               // Current text value
   "selectionStart": Int,        // Cursor selection start
   "selectionEnd": Int,         // Cursor selection end
   "timestamp": TimeInterval
 }
 onFocus: {
   "timestamp": TimeInterval
 }
 onBlur: {
   "text": String,              // Final text value
   "timestamp": TimeInterval
 }
 onKeyboardChange: {
   "height": CGFloat,           // Keyboard height
   "timestamp": TimeInterval
 }
*/

class DCTextInput: DCView {
    // Use lazy initialization for text field
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.delegate = self
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return field
    }()
    
    private weak var methodChannel: FlutterMethodChannel?
    private var textChangeObserver: NSObjectProtocol?
    private var isRendered = false
    
    // Cache commonly accessed properties
    private var currentText: String = ""
    private var currentPlaceholder: String = ""
    private var isSecureEntry = false
    
    override init(viewId: String) {
        super.init(viewId: viewId)
        setupDefaults()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func setupDefaults() {
        super.setupDefaults()
        backgroundColor = .clear
        
        // Configure text field with additional settings
        textField.autocorrectionType = .no // Disable autocorrection by default
        textField.smartDashesType = .no // Disable smart dashes
        textField.smartQuotesType = .no // Disable smart quotes
        textField.smartInsertDeleteType = .no // Disable smart insert/delete
        
        // Set default text input traits
        textField.textContentType = nil // Prevent unwanted system behaviors
        
        // Add text field to view
        addSubview(textField)
        textField.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }
    
    override func becomeFirstResponder() -> Bool {
        // Ensure proper focus handling
        textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        // Ensure proper blur handling
        textField.resignFirstResponder()
    }
    
    // Optimize layout updates
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.size.width > 0 && bounds.size.height > 0 {
            // Use CATransaction to batch layout updates
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            textField.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
            CATransaction.commit()
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        guard let inputStyle = style["inputStyle"] as? [String: Any] else { return }
        
        // Batch UI updates
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Cache and compare values before updating
        if let placeholder = inputStyle["placeholder"] as? String,
           placeholder != currentPlaceholder {
            currentPlaceholder = placeholder
            textField.placeholder = placeholder
        }
        
        if let textColor = inputStyle["textColor"] as? UInt32 {
            textField.textColor = UIColor(rgb: textColor)
        }
        
        if let fontSize = inputStyle["fontSize"] as? CGFloat {
            textField.font = .systemFont(ofSize: max(1, fontSize))
        }
        
        if let isSecure = inputStyle["isSecure"] as? Bool,
           isSecure != isSecureEntry {
            isSecureEntry = isSecure
            textField.isSecureTextEntry = isSecure
        }
        
        if let keyboardType = inputStyle["keyboardType"] as? String {
            textField.keyboardType = keyboardType == "email" ? .emailAddress : .default
        }
        
        if let returnKeyType = inputStyle["returnKeyType"] as? String {
            textField.returnKeyType = returnKeyType == "next" ? .next : .default
        }
        
        CATransaction.commit()
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        
        // Use a single observer and remove old one if exists
        if let observer = textChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        textChangeObserver = NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: textField,
            queue: .main) { [weak self] _ in
                self?.handleTextChange()
            }
    }
    
    @objc private func handleTextChange() {
        guard let text = textField.text, text != currentText else { return }
        currentText = text
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onTextChange",
            "data": ["text": text]
        ])
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        if let text = newState["text"] as? String, text != currentText {
            currentText = text
            textField.text = text
        }
        
        if let enabled = newState["enabled"] as? Bool {
            textField.isEnabled = enabled
        }
        
        if let focused = newState["focused"] as? Bool, focused {
            textField.becomeFirstResponder()
        } else if let focused = newState["focused"] as? Bool, !focused {
            textField.resignFirstResponder()
        }
        
        if let placeholder = newState["placeholder"] as? String {
            textField.placeholder = placeholder
        }
    }
    
    override func captureCurrentState() -> [String: Any] {
        var state = super.captureCurrentState()
        state["text"] = textField.text ?? ""
        state["enabled"] = textField.isEnabled
        state["focused"] = textField.isFirstResponder
        state["placeholder"] = textField.placeholder ?? ""
        return state
    }
    
    // Clean up properly
    deinit {
        NotificationCenter.default.removeObserver(self)
        textField.delegate = nil
    }
}

// Separate delegate methods for better organization
extension DCTextInput: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onFocus",
            "data": [:]
        ])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onBlur",
            "data": ["text": textField.text ?? ""]
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onSubmit",
            "data": ["text": textField.text ?? ""]
        ])
        textField.resignFirstResponder()
        return true
    }
}
