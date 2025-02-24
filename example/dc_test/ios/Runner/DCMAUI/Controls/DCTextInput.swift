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
    private let textField: UITextField
    private weak var methodChannel: FlutterMethodChannel?
    
    override init(viewId: String) {
        textField = UITextField()
        super.init(viewId: viewId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func setupDefaults() {
        super.setupDefaults()
        
        // Configure self (container)
        self.yoga.isEnabled = true
        self.clipsToBounds = true
        
        // Configure textField
        textField.delegate = self
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        
        // Use frame-based layout like RN
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(textField)
        
        // Important: Set initial frame
        textField.frame = bounds
        
        print("TextInput setupDefaults - bounds: \(bounds), textField frame: \(textField.frame)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update text field frame when container is laid out
        textField.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        
        print("TextInput layoutSubviews - bounds: \(bounds), textField frame: \(textField.frame)")
    }
    
    override func applyStyle(_ style: [String: Any]) {
        print("TextInput applying style: \(style)")
        
        // First apply container styles (background, border etc)
        super.applyStyle(style)
        
        if let inputStyle = style["inputStyle"] as? [String: Any] {
            print("Applying input style: \(inputStyle)")
            
            // Text properties
            if let placeholder = inputStyle["placeholder"] as? String {
                textField.placeholder = placeholder
            }
            if let textColor = inputStyle["textColor"] as? UInt32 {
                textField.textColor = UIColor(rgb: textColor)
            }
            if let fontSize = inputStyle["fontSize"] as? CGFloat {
                textField.font = .systemFont(ofSize: fontSize)
            }
            
            // Input properties
            if let isSecure = inputStyle["isSecure"] as? Bool {
                textField.isSecureTextEntry = isSecure
            }
            if let keyboardType = inputStyle["keyboardType"] as? String {
                textField.keyboardType = keyboardType == "email" ? .emailAddress : .default
            }
            if let returnKeyType = inputStyle["returnKeyType"] as? String {
                textField.returnKeyType = returnKeyType == "next" ? .next : .default
            }
        }
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        print("Setting up events for text input: \(viewId)")
        self.methodChannel = channel
        
        // Add text change observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextChange),
            name: UITextField.textDidChangeNotification,
            object: textField
        )
    }
    
    // MARK: - Event Handlers
    
    @objc private func handleTextChange() {
        guard let text = textField.text else { return }
        print("Text changed: \(text)")
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onTextChange",
            "data": ["text": text]
        ])
    }
}

extension DCTextInput: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Text field focused")
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onFocus",
            "data": [:]
        ])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Text field blurred")
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
