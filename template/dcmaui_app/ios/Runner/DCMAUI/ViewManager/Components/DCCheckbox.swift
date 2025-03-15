//
//  DCCheckbox.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit


/// Custom Checkbox component (since iOS doesn't have a native checkbox)
class DCCheckbox: DCBaseView {
    private let checkboxView = UIView()
    private let checkmarkImageView = UIImageView()
    private var isChecked = false
    
    // Renamed to avoid conflicts with UIView's tintColor
    private var checkboxTintColor: UIColor = .systemBlue
    private var checkedColor: UIColor = .systemBlue
    
    override func setupView() {
        super.setupView()
        
        // Set up the checkbox container
        checkboxView.translatesAutoresizingMaskIntoConstraints = false
        checkboxView.layer.borderWidth = 2.0
        checkboxView.layer.borderColor = checkboxTintColor.cgColor
        checkboxView.layer.cornerRadius = 4.0
        addSubview(checkboxView)
        
        // Set up checkmark image
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.tintColor = .white
        checkmarkImageView.isHidden = true
        
        // Create a checkmark image programmatically
        let size = CGSize(width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2.0)
        context.move(to: CGPoint(x: 8, y: 14))
        context.addLine(to: CGPoint(x: 11, y: 17))
        context.addLine(to: CGPoint(x: 16, y: 9))
        context.strokePath()
        
        let checkmarkImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysTemplate)
        UIGraphicsEndImageContext()
        
        checkmarkImageView.image = checkmarkImage
        checkboxView.addSubview(checkmarkImageView)
        
        // Add constraints for checkbox
        NSLayoutConstraint.activate([
            checkboxView.widthAnchor.constraint(equalToConstant: 24.0),
            checkboxView.heightAnchor.constraint(equalToConstant: 24.0),
            checkboxView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkboxView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            checkmarkImageView.topAnchor.constraint(equalTo: checkboxView.topAnchor, constant: 2.0),
            checkmarkImageView.leadingAnchor.constraint(equalTo: checkboxView.leadingAnchor, constant: 2.0),
            checkmarkImageView.trailingAnchor.constraint(equalTo: checkboxView.trailingAnchor, constant: -2.0),
            checkmarkImageView.bottomAnchor.constraint(equalTo: checkboxView.bottomAnchor, constant: -2.0)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle checked state
        if let value = props["value"] as? Bool {
            setChecked(value, animated: false)
        }
        
        // Handle disabled state
        if let disabled = props["disabled"] as? Bool {
            isUserInteractionEnabled = !disabled
            alpha = disabled ? 0.5 : 1.0
        }
        
        // Handle tint color (border color when unchecked)
        if let tintColorString = props["tintColor"] as? String, tintColorString.hasPrefix("#") {
            checkboxTintColor = UIColor(hexString: tintColorString)
            if !isChecked {
                checkboxView.layer.borderColor = checkboxTintColor.cgColor
            }
        }
        
        // Handle checked color (background when checked)
        if let checkedColorString = props["checkedColor"] as? String, checkedColorString.hasPrefix("#") {
            checkedColor = UIColor(hexString: checkedColorString)
            if isChecked {
                checkboxView.backgroundColor = checkedColor
            }
        }
    }
    
    @objc private func handleTap() {
        setChecked(!isChecked, animated: true)
        
        // Send event to Flutter
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onValueChange",
            params: ["value": isChecked]
        )
    }
    
    private func setChecked(_ checked: Bool, animated: Bool) {
        isChecked = checked
        
        let updateUI = {
            if checked {
                self.checkboxView.backgroundColor = self.checkedColor
                self.checkboxView.layer.borderColor = self.checkedColor.cgColor
                self.checkmarkImageView.isHidden = false
            } else {
                self.checkboxView.backgroundColor = .clear
                self.checkboxView.layer.borderColor = self.checkboxTintColor.cgColor
                self.checkmarkImageView.isHidden = true
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                updateUI()
            }
        } else {
            updateUI()
        }
    }
}
