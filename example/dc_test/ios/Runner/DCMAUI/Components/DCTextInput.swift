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

class DCTextInput: DCView, UITextFieldDelegate {
    private let textField = UITextField()
    private weak var methodChannel: FlutterMethodChannel?
    private var subscriptions = Set<AnyCancellable>()
    
    // New keyboard features
    private var keyboardToolbar: UIToolbar?
    private var keyboardObserver: NSObjectProtocol?
    private var keyboardHeight: CGFloat = 0
    
    override func setupDefaults() {
        super.setupDefaults()
        setupTextField()
        setupKeyboardHandling()
        setupTextChangePublisher()
    }
    
    private func setupTextField() {
        textField.delegate = self
        textField.borderStyle = .roundedRect
        textField.yoga.isEnabled = true
        addSubview(textField)
        
        // Smart features
        textField.smartDashesType = .yes
        textField.smartQuotesType = .yes
        textField.smartInsertDeleteType = .yes
        
        // Better text handling
        textField.autocorrectionType = .default
        textField.spellCheckingType = .default
        textField.textContentType = .none
    }
    
    private func setupKeyboardHandling() {
        // Add keyboard toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        
        textField.inputAccessoryView = toolbar
        keyboardToolbar = toolbar
        
        // Observe keyboard
        keyboardObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardChange(notification)
        }
    }
    
    private func setupTextChangePublisher() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleTextChange()
            }
            .store(in: &subscriptions)
    }
    
    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    private func handleKeyboardChange(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardHeight = keyboardFrame.height
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onKeyboardChange",
            "data": ["height": keyboardHeight],
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
    }
    
    @objc private func textDidChange() {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onTextChange",
            "data": [
                "text": textField.text ?? "",
                "selectionStart": textField.selectedTextRange?.start.offset ?? 0,
                "selectionEnd": textField.selectedTextRange?.end.offset ?? 0,
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onFocus",
            "data": [
                "timestamp": Date().timeIntervalSince1970
            ]
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
    
    override func handleStateChange(_ newState: [String: Any]) {
        if let text = newState["text"] as? String {
            textField.text = text
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let inputStyle = style["inputStyle"] as? [String: Any] {
            if let placeholder = inputStyle["placeholder"] as? String {
                textField.placeholder = placeholder
            }
            if let keyboardType = inputStyle["keyboardType"] as? String {
                textField.keyboardType = KeyboardType(rawValue: keyboardType)?.uiKeyboardType ?? .default
            }
            if let returnKeyType = inputStyle["returnKeyType"] as? String {
                textField.returnKeyType = ReturnKeyType(rawValue: returnKeyType)?.uiReturnKeyType ?? .default
            }
            if let textColor = inputStyle["textColor"] as? UInt32 {
                textField.textColor = UIColor(rgb: textColor)
            }
            if let fontSize = inputStyle["fontSize"] as? CGFloat {
                textField.font = .systemFont(ofSize: fontSize)
            }
            if let alignment = inputStyle["textAlign"] as? String {
                textField.textAlignment = TextAlignment(rawValue: alignment)?.nsTextAlignment ?? .left
            }
            if let isSecure = inputStyle["isSecure"] as? Bool {
                textField.isSecureTextEntry = isSecure
            }
            // New style options
            if let autocorrection = inputStyle["autocorrection"] as? Bool {
                textField.autocorrectionType = autocorrection ? .yes : .no
            }
            if let contentType = inputStyle["contentType"] as? String {
                textField.textContentType = TextContentType(rawValue: contentType)?.uiTextContentType
            }
            if let toolbarStyle = inputStyle["toolbarStyle"] as? String {
                keyboardToolbar?.barStyle = ToolbarStyle(rawValue: toolbarStyle)?.uiBarStyle ?? .default
            }
        }
    }
    
    // Helper enums for keyboard configuration
    private enum KeyboardType: String {
        case `default`, number, email, phone, url
        
        var uiKeyboardType: UIKeyboardType {
            switch self {
            case .default: return .default
            case .number: return .numberPad
            case .email: return .emailAddress
            case .phone: return .phonePad
            case .url: return .URL
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
    
    private enum TextAlignment: String {
        case left, center, right
        
        var nsTextAlignment: NSTextAlignment {
            switch self {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            }
        }
    }
    
    // Helper enum for content type
    private enum TextContentType: String {
        case username, password, email, name, phone, address, none
        
        var uiTextContentType: UITextContentType? {
            switch self {
            case .username: return .username
            case .password: return .password
            case .email: return .emailAddress
            case .name: return .name
            case .phone: return .telephoneNumber
            case .address: return .fullStreetAddress
            case .none: return nil
            }
        }
    }
    
    private enum ToolbarStyle: String {
        case `default`, dark
        
        var uiBarStyle: UIBarStyle {
            switch self {
            case .default: return .default
            case .dark: return .black
            }
        }
    }
}
