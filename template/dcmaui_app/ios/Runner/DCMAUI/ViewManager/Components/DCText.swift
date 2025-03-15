//
//  DCText.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Text component
class DCText: DCBaseView {
    private let label = UILabel()
    
    override func setupView() {
        super.setupView()
        
        // Set up label
        label.numberOfLines = 0  // Default to multiline
        addSubview(label)
        
        // Add constraints to make label fill the view
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle text
        if let text = props["text"] as? String {
            label.text = text
        }
        
        // Handle style properties
        if let style = props["style"] as? [String: Any] {
            applyTextStyle(style)
        }
        
        // Handle selectable text
        if let selectable = props["selectable"] as? Bool {
            label.isUserInteractionEnabled = selectable
        }
        
        // Handle onPress callback
        if props["onPress"] != nil {
            // Add tap gesture recognizer if not already added
            if gestureRecognizers?.contains(where: { $0 is UITapGestureRecognizer }) != true {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                addGestureRecognizer(tapGesture)
                isUserInteractionEnabled = true
            }
        }
    }
    
    private func applyTextStyle(_ style: [String: Any]) {
        var font = label.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        var textColor = label.textColor ?? .black
        
        // Font size
        if let fontSize = style["fontSize"] as? CGFloat {
            font = font.withSize(fontSize)
        }
        
        // Font weight
        if let fontWeight = style["fontWeight"] as? String {
            switch fontWeight {
                case "100": font = UIFont.systemFont(ofSize: font.pointSize, weight: .ultraLight)
                case "200": font = UIFont.systemFont(ofSize: font.pointSize, weight: .thin)
                case "300": font = UIFont.systemFont(ofSize: font.pointSize, weight: .light)
                case "normal", "400": font = UIFont.systemFont(ofSize: font.pointSize, weight: .regular)
                case "500": font = UIFont.systemFont(ofSize: font.pointSize, weight: .medium)
                case "600": font = UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)
                case "bold", "700": font = UIFont.systemFont(ofSize: font.pointSize, weight: .bold)
                case "800": font = UIFont.systemFont(ofSize: font.pointSize, weight: .heavy)
                case "900": font = UIFont.systemFont(ofSize: font.pointSize, weight: .black)
                default: break
            }
        }
        
        // Font family
        if let fontFamily = style["fontFamily"] as? String {
            if let customFont = UIFont(name: fontFamily, size: font.pointSize) {
                font = customFont
            }
        }
        
        // Text color
        if let colorString = style["color"] as? String, colorString.hasPrefix("#") {
            textColor = UIColor(hexString: colorString)
        }
        
        // Text alignment
        if let textAlign = style["textAlign"] as? String {
            switch textAlign {
                case "left": label.textAlignment = .left
                case "center": label.textAlignment = .center
                case "right": label.textAlignment = .right
                case "justify": label.textAlignment = .justified
                default: label.textAlignment = .natural
            }
        }
        
        // Text decoration
        if let decoration = style["textDecorationLine"] as? String {
            var attributes: [NSAttributedString.Key: Any] = [:]
            
            switch decoration {
                case "underline":
                    attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                case "line-through":
                    attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                case "underline line-through":
                    attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                    attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                default:
                    break
            }
            
            if let text = label.text, !attributes.isEmpty {
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                label.attributedText = attributedString
            }
        }
        
        // Line height
        if let lineHeight = style["lineHeight"] as? CGFloat {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight - font.lineHeight
            
            if let text = label.text {
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
                label.attributedText = attributedString
            }
        }
        
        // Max lines
        if let maxLines = style["maxLines"] as? Int {
            label.numberOfLines = maxLines
        }
        
        // Text overflow
        if let overflow = style["textOverflow"] as? String {
            switch overflow {
                case "ellipsis":
                    label.lineBreakMode = .byTruncatingTail
                case "clip":
                    label.lineBreakMode = .byClipping
                default:
                    label.lineBreakMode = .byWordWrapping
            }
        }
        
        // Letter spacing
        if let letterSpacing = style["letterSpacing"] as? CGFloat {
            if let text = label.text {
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(.kern, value: letterSpacing, range: NSRange(location: 0, length: text.count))
                label.attributedText = attributedString
            }
        }
        
        // Apply font
        label.font = font
        
        // Apply color (if not using attributed string)
        if label.attributedText == nil {
            label.textColor = textColor
        }
    }
    
    @objc private func handleTap() {
        // Send event to Flutter
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onPress",
            params: ["text": label.text ?? ""]
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return label.sizeThatFits(size)
    }
}
