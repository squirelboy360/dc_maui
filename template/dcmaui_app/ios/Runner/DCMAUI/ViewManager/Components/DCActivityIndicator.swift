//
//  DCActivityIndicator.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// ActivityIndicator component that matches React Native's ActivityIndicator
class DCActivityIndicator: DCBaseView {
    private let indicator = UIActivityIndicatorView()
    
    override func setupView() {
        super.setupView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Use large style by default on iOS 13+
        if #available(iOS 13.0, *) {
            indicator.style = .medium
        } else {
            indicator.style = .gray
        }
        
        addSubview(indicator)
        
        // Center the indicator in the view
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        // Start animating by default
        indicator.startAnimating()
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle animating state
        if let animating = props["animating"] as? Bool {
            if animating {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
        }
        
        // Handle size property
        if let size = props["size"] as? String {
            if #available(iOS 13.0, *) {
                indicator.style = size == "large" ? .large : .medium
            } else {
                indicator.style = size == "large" ? .whiteLarge : .gray
            }
        }
        
        // Handle color property
        if let colorStr = props["color"] as? String, colorStr.hasPrefix("#") {
            indicator.color = UIColor(hexString: colorStr)
        }
        
        // Handle hide when stopped property
        if let hidesWhenStopped = props["hidesWhenStopped"] as? Bool {
            indicator.hidesWhenStopped = hidesWhenStopped
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return indicator.intrinsicContentSize
    }
}
