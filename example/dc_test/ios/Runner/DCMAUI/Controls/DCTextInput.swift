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
import YogaKit // Add this import

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

import UIKit
import YogaKit

class DCTextInput: DCView {
    // Use UITextField instead of UITextView for better default behavior
    private var textField: UITextField!
    private weak var methodChannel: FlutterMethodChannel?
    
    override init(viewId: String) {
        super.init(viewId: viewId)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func setupTextField() {
        textField = UITextField()
        textField.delegate = self
        
        // Reset all default styles
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        
        // Add to view hierarchy
        addSubview(textField)
        
        // Use frame-based layout (more reliable than constraints for text fields)
        textField.translatesAutoresizingMaskIntoConstraints = true
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Size to fit parent
        textField.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep text field sized to bounds
        textField.frame = bounds
    }
    
    override func applyStyle(_ style: [String: Any]) {
        // Apply container style first
        super.applyStyle(style)
        
        if let inputStyle = style["inputStyle"] as? [String: Any] {
            if let text = inputStyle["text"] as? String {
                textField.text = text
            }
            if let placeholder = inputStyle["placeholder"] as? String {
                textField.placeholder = placeholder
            }
            if let textColor = inputStyle["textColor"] as? UInt32 {
                textField.textColor = UIColor(rgb: textColor)
            }
            if let fontSize = inputStyle["fontSize"] as? CGFloat {
                textField.font = .systemFont(ofSize: fontSize)
            }
            if let textAlign = inputStyle["textAlign"] as? String {
                textField.textAlignment = textAlign == "right" ? .right :
                                        textAlign == "center" ? .center : .left
            }
            if let keyboardType = inputStyle["keyboardType"] as? String {
                textField.keyboardType = keyboardType == "number" ? .numberPad :
                                       keyboardType == "email" ? .emailAddress :
                                       keyboardType == "phone" ? .phonePad :
                                       keyboardType == "url" ? .URL : .default
            }
            if let returnKeyType = inputStyle["returnKeyType"] as? String {
                textField.returnKeyType = returnKeyType == "done" ? .done :
                                        returnKeyType == "go" ? .go :
                                        returnKeyType == "next" ? .next :
                                        returnKeyType == "search" ? .search :
                                        returnKeyType == "send" ? .send : .default
            }
            if let isSecure = inputStyle["isSecure"] as? Bool {
                textField.isSecureTextEntry = isSecure
            }
            if let autocorrection = inputStyle["autocorrection"] as? Bool {
                textField.autocorrectionType = autocorrection ? .yes : .no
            }
        }
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        
        // Add text change notification observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextChange),
            name: UITextField.textDidChangeNotification,
            object: textField
        )
    }
    
    @objc private func handleTextChange() {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onTextChange",
            "data": [
                "text": textField.text ?? "",
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
}

extension DCTextInput: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onFocus",
            "data": ["timestamp": Date().timeIntervalSince1970]
        ])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onBlur",
            "data": [
                "text": textField.text ?? "",
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onSubmit",
            "data": [
                "text": textField.text ?? "",
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
        textField.resignFirstResponder()
        return true
    }
}
