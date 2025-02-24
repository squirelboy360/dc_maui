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
import YogaKit 

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
    private var textField: UITextField?
    private var textView: UITextView?
    private weak var methodChannel: FlutterMethodChannel?
    private var isMultiline = false
    
    override func setupDefaults() {
        super.setupDefaults()
        backgroundColor = .clear
        self.yoga.isEnabled = true
        self.yoga.flex = 0
    }
    
    private func setupTextInput(_ style: [String: Any]) {
        textField?.removeFromSuperview()
        textView?.removeFromSuperview()
        
        if isMultiline {
            let view = UITextView()
            view.delegate = self
            view.backgroundColor = .clear
            view.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            view.textContainer.lineFragmentPadding = 0
            
            // Use constraints instead of frame
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            textView = view
            textField = nil
            
        } else {
            let field = UITextField()
            field.delegate = self
            field.backgroundColor = .clear
            field.borderStyle = .none
            
            // Use constraints instead of frame
            field.translatesAutoresizingMaskIntoConstraints = false
            addSubview(field)
            
            NSLayoutConstraint.activate([
                field.topAnchor.constraint(equalTo: topAnchor),
                field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                field.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                field.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            textField = field
            textView = nil
        }
        
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Important: Update input view frames to match bounds
        if let field = textField {
            field.frame = bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        }
        if let view = textView {
            view.frame = bounds
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        // First apply container styles
        super.applyStyle(style)
        
        if let inputStyle = style["inputStyle"] as? [String: Any] {
            isMultiline = (inputStyle["multiline"] as? Bool) == true
            setupTextInput(inputStyle)
            applyTextStyle(inputStyle)
            
            // Force layout after applying styles
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private func applyTextStyle(_ style: [String: Any]) {
        // Apply styles based on input type
        if isMultiline {
            guard let textView = textView else { return }
            
            if let text = style["text"] as? String {
                textView.text = text
            }
            if let textColor = style["textColor"] as? UInt32 {
                textView.textColor = UIColor(rgb: textColor)
            }
            if let fontSize = style["fontSize"] as? CGFloat {
                textView.font = UIFont.systemFont(ofSize: fontSize)
            }
            if let textAlign = style["textAlign"] as? String {
                textView.textAlignment = textAlign == "right" ? .right :
                                       textAlign == "center" ? .center : .left
            }
            if let keyboardType = style["keyboardType"] as? String {
                textView.keyboardType = keyboardType == "number" ? .numberPad :
                                      keyboardType == "email" ? .emailAddress :
                                      keyboardType == "phone" ? .phonePad :
                                      keyboardType == "url" ? .URL : .default
            }
            if let returnKey = style["returnKeyType"] as? String {
                textView.returnKeyType = returnKey == "done" ? .done :
                                       returnKey == "go" ? .go :
                                       returnKey == "next" ? .next :
                                       returnKey == "search" ? .search :
                                       returnKey == "send" ? .send : .default
            }
            if let maxLines = style["maxLines"] as? Int {
                textView.textContainer.maximumNumberOfLines = maxLines
            }
            if let editable = style["editable"] as? Bool {
                textView.isEditable = editable
            }
        } else {
            guard let field = textField else { return }
            
            if let text = style["text"] as? String {
                field.text = text
            }
            if let placeholder = style["placeholder"] as? String {
                field.placeholder = placeholder
            }
            if let textColor = style["textColor"] as? UInt32 {
                field.textColor = UIColor(rgb: textColor)
            }
            if let fontSize = style["fontSize"] as? CGFloat {
                field.font = UIFont.systemFont(ofSize: fontSize)
            }
            if let textAlign = style["textAlign"] as? String {
                field.textAlignment = textAlign == "right" ? .right :
                                    textAlign == "center" ? .center : .left
            }
            if let keyboardType = style["keyboardType"] as? String {
                field.keyboardType = keyboardType == "number" ? .numberPad :
                                   keyboardType == "email" ? .emailAddress :
                                   keyboardType == "phone" ? .phonePad :
                                   keyboardType == "url" ? .URL : .default
            }
            if let returnKey = style["returnKeyType"] as? String {
                field.returnKeyType = returnKey == "done" ? .done :
                                    returnKey == "go" ? .go :
                                    returnKey == "next" ? .next :
                                    returnKey == "search" ? .search :
                                    returnKey == "send" ? .send : .default
            }
            if let isSecure = style["isSecure"] as? Bool {
                field.isSecureTextEntry = isSecure
            }
            if let editable = style["editable"] as? Bool {
                field.isEnabled = editable
            }
        }
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        
        // Add listeners only if needed
        if events["onTextChange"] != nil {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleTextChange),
                name: isMultiline ? UITextView.textDidChangeNotification : UITextField.textDidChangeNotification,
                object: isMultiline ? textView : textField
            )
        }
    }
    
    @objc private func handleTextChange() {
        let text = isMultiline ? textView?.text : textField?.text
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onTextChange",
            "data": ["text": text ?? ""]
        ])
    }
}

extension DCTextInput: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onFocus",
            "data": [:]
        ])
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onBlur",
            "data": ["text": textView.text]
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            methodChannel?.invokeMethod("onComponentEvent", arguments: [
                "viewId": viewId,
                "type": "onSubmit",
                "data": ["text": textView.text]
            ])
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
