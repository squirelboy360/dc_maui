//
//  DCSwitch.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Switch component
class DCSwitch: DCBaseView {
    private let switchControl = UISwitch()
    
    override func setupView() {
        super.setupView()
        
        // Set up switch control
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(switchControl)
        
        // Add target for value change
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        // Center the switch in the view
        NSLayoutConstraint.activate([
            switchControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle value
        if let value = props["value"] as? Bool {
            switchControl.isOn = value
        }
        
        // Handle disabled state
        if let disabled = props["disabled"] as? Bool {
            switchControl.isEnabled = !disabled
        }
        
        // Handle track color (off state)
        if let trackColorString = props["trackColor"] as? String, trackColorString.hasPrefix("#") {
            switchControl.tintColor = UIColor(hexString: trackColorString).withAlphaComponent(0.4)
        }
        
        // Handle thumb color (off state)
        if let thumbColorString = props["thumbColor"] as? String, thumbColorString.hasPrefix("#") {
            // Note: iOS doesn't allow customizing thumb color directly in standard UISwitch
            // This would require a custom switch implementation
        }
        
        // Handle active track color (on state)
        if let activeTrackColorString = props["activeTrackColor"] as? String, activeTrackColorString.hasPrefix("#") {
            switchControl.onTintColor = UIColor(hexString: activeTrackColorString)
        }
        
        // Apply any custom style
        if let style = props["style"] as? [String: Any] {
            // iOS UISwitch has limited customization options
            // For extensive styling, we would need a custom implementation
        }
    }
    
    @objc private func switchValueChanged() {
        // Send event to Flutter
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onValueChange",
            params: ["value": switchControl.isOn]
        )
    }
}
