//
//  DCButton.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Button component
class DCButton: DCBaseView {
    private let button = UIButton(type: .system)
    
    override func setupView() {
        super.setupView()
        
        // Set up button
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        // Add target for tap event
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        // Constrain button to fill the view
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle title
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        // Handle disabled state
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
            button.alpha = disabled ? 0.5 : 1.0
        }
        
        // Handle color
        if let color = props["color"] as? String, color.hasPrefix("#") {
            button.tintColor = UIColor(hexString: color)
        }
        
        // Handle title style
        if let titleStyle = props["titleStyle"] as? [String: Any] {
            applyTitleStyle(titleStyle)
        }
        
        // Handle button style
        if let style = props["style"] as? [String: Any] {
            applyButtonStyle(style)
        }
    }
    
    private func applyTitleStyle(_ style: [String: Any]) {
        // Font customization
        var font = button.titleLabel?.font ?? UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        
        if let fontSize = style["fontSize"] as? CGFloat {
            font = font.withSize(fontSize)
        }
        
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
        
        button.titleLabel?.font = font
        
        // Color customization
        if let colorString = style["color"] as? String, colorString.hasPrefix("#") {
            button.setTitleColor(UIColor(hexString: colorString), for: .normal)
        }
        
        // Other text attributes could be added here
    }
    
    private func applyButtonStyle(_ style: [String: Any]) {
        // Handle button-specific styling like insets, image placement, etc.
        if let contentInsets = style["contentInsets"] as? [String: CGFloat] {
            let top = contentInsets["top"] ?? 0
            let left = contentInsets["left"] ?? 0
            let bottom = contentInsets["bottom"] ?? 0
            let right = contentInsets["right"] ?? 0
            button.contentEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        // Handle background color
        if let backgroundColorString = style["backgroundColor"] as? String, 
           backgroundColorString.hasPrefix("#") {
            button.backgroundColor = UIColor(hexString: backgroundColorString)
        }
    }
    
    @objc private func buttonPressed() {
        // Send event to Flutter
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "press", // Changed from "onPress" to "press" to match Dart side
            params: [:]
        )
    }
}
