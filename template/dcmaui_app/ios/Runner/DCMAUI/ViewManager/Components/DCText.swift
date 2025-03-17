//
//  DCText.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Text component implementation that matches React Native's Text component
class DCText: DCBaseView {
    private let label = UILabel()
    
    override func setupView() {
        super.setupView()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // Allow multiple lines by default
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.text = ""
        
        addSubview(label)
        
        // Constrain label to fill the view with respect to padding
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Set text content
        if let text = props["text"] as? String {
            label.text = text
        }
        
        // Set whether the text is selectable
        if let selectable = props["selectable"] as? Bool {
            label.isUserInteractionEnabled = selectable
        }
        
        // Process style properties
        if let style = props["style"] as? [String: Any] {
            applyTextStyle(style)
        }
        
        // Handle number of lines
        if let numberOfLines = props["numberOfLines"] as? Int {
            label.numberOfLines = numberOfLines
        }
        
        // Handle text alignment (directly on props or in style)
        if let textAlign = props["textAlign"] as? String {
            label.textAlignment = getTextAlignment(textAlign)
        }
        
        setNeedsLayout()
    }
    
    private func applyTextStyle(_ style: [String: Any]) {
        // Start with current font or system font
        var font = label.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        // Text color
        if let colorStr = style["color"] as? String, colorStr.hasPrefix("#") {
            label.textColor = UIColor(hexString: colorStr)
        }
        
        // Font size
        if let fontSize = style["fontSize"] as? CGFloat {
            font = UIFont(name: font.fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        }
        
        // Font weight
        if let fontWeight = style["fontWeight"] as? String {
            var weight = UIFont.Weight.regular
            
            switch fontWeight {
            case "bold": weight = .bold
            case "normal": weight = .regular
            case "100": weight = .ultraLight
            case "200": weight = .thin
            case "300": weight = .light
            case "400": weight = .regular
            case "500": weight = .medium
            case "600": weight = .semibold
            case "700": weight = .bold
            case "800": weight = .heavy
            case "900": weight = .black
            default: break
            }
            
            font = UIFont.systemFont(ofSize: font.pointSize, weight: weight)
        }
        
        // Font family
        if let fontFamily = style["fontFamily"] as? String {
            if let newFont = UIFont(name: fontFamily, size: font.pointSize) {
                font = newFont
            }
        }
        
        // Text alignment
        if let textAlign = style["textAlign"] as? String {
            label.textAlignment = getTextAlignment(textAlign)
        }
        
        // Line height
        if let lineHeight = style["lineHeight"] as? CGFloat {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            let attributedText = NSMutableAttributedString(string: label.text ?? "")
            attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, 
                                        range: NSRange(location: 0, length: attributedText.length))
            
            // Add baseline adjustment to center text vertically within line height
            let baselineOffset = (lineHeight - font.lineHeight) / 4
            attributedText.addAttribute(.baselineOffset, value: baselineOffset, 
                                        range: NSRange(location: 0, length: attributedText.length))
            
            label.attributedText = attributedText
        }
        
        // Text decoration
        if let textDecoration = style["textDecorationLine"] as? String {
            var attributes: [NSAttributedString.Key: Any] = [:]
            
            if textDecoration == "underline" {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            } else if textDecoration == "line-through" {
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
            
            if !attributes.isEmpty {
                let attributedText = NSMutableAttributedString(string: label.text ?? "")
                attributedText.addAttributes(attributes, range: NSRange(location: 0, length: attributedText.length))
                label.attributedText = attributedText
            }
        }
        
        // Apply the font
        label.font = font
    }
    
    private func getTextAlignment(_ textAlign: String) -> NSTextAlignment {
        switch textAlign {
        case "auto": return .natural
        case "left": return .left
        case "right": return .right
        case "center": return .center
        case "justify": return .justified
        default: return .natural
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return label.intrinsicContentSize
    }
}
