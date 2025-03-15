//
//  DCModal.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit


/// Modal component for presenting content modally
class DCModal: DCBaseView {
    private var isVisible = false
    private var contentView: UIView?
    private var backgroundView = UIView()
    private var modalViewController: UIViewController?
    private var presentationStyle: String = "fullScreen"
    private var animationType: String = "slide"
    private var isTransparent = false
    
    override func setupView() {
        super.setupView()
        
        // Setup background view - this will be used for modals presented directly
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.alpha = 0
        
        // Add tap gesture to dismiss if tapped outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle visibility
        if let visible = props["visible"] as? Bool {
            if visible != isVisible {
                isVisible = visible
                
                if visible {
                    showModal()
                } else {
                    hideModal()
                }
            }
        }
        
        // Handle transparent background
        if let transparent = props["transparent"] as? Bool {
            isTransparent = transparent
            backgroundView.backgroundColor = transparent ? 
                UIColor.clear : 
                UIColor.black.withAlphaComponent(0.5)
        }
        
        // Handle animation type
        if let animType = props["animationType"] as? String {
            animationType = animType
        }
        
        // Handle presentation style
        if let presStyle = props["presentationStyle"] as? String {
            presentationStyle = presStyle
        }
    }
    
    private func showModal() {
        // Signal that the modal is being shown
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onShow",
            params: [:]
        )
        
        // Find the root view controller
        guard let rootViewController = findRootViewController() else {
            return
        }
        
        // Choose presentation method based on props
        switch presentationStyle {
            case "pageSheet", "formSheet":
                presentUsingViewController(rootViewController)
            default:
                presentDirectlyOverWindow()
        }
    }
    
    private func findRootViewController() -> UIViewController? {
        // Find the key window in iOS 13+
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first(where: { $0.isKeyWindow })
            return window?.rootViewController
        } else {
            // Fallback for earlier versions
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    private func presentUsingViewController(_ rootViewController: UIViewController) {
        // Create content in a UIViewController
        modalViewController = UIViewController()
        guard let modalVC = modalViewController else { return }
        
        // Configure based on presentation style
        switch presentationStyle {
            case "pageSheet":
                modalVC.modalPresentationStyle = .pageSheet
            case "formSheet":
                modalVC.modalPresentationStyle = .formSheet
            case "overFullScreen":
                modalVC.modalPresentationStyle = .overFullScreen
            default:
                modalVC.modalPresentationStyle = .fullScreen
        }
        
        // Set animation style
        switch animationType {
            case "none":
                modalVC.modalTransitionStyle = .crossDissolve
            case "slide":
                modalVC.modalTransitionStyle = .coverVertical
            case "fade":
                modalVC.modalTransitionStyle = .crossDissolve
            default:
                modalVC.modalTransitionStyle = .coverVertical
        }
        
        // Set background color based on transparency
        modalVC.view.backgroundColor = isTransparent ? .clear : .white
        
        // Add all subviews to the modal's view
        for subview in subviews {
            if subview != backgroundView {
                modalVC.view.addSubview(subview)
            }
        }
        
        // Present the modal
        rootViewController.present(modalVC, animated: animationType != "none", completion: nil)
    }
    
    private func presentDirectlyOverWindow() {
        // Find the key window
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        // Create a container view for our modal content
        contentView = UIView(frame: keyWindow.bounds)
        contentView?.backgroundColor = isTransparent ? .clear : .white
        
        // Add the background view to fill the screen
        backgroundView.frame = keyWindow.bounds
        backgroundView.alpha = 0
        keyWindow.addSubview(backgroundView)
        
        // Add the content view to the window
        if let contentView = contentView {
            keyWindow.addSubview(contentView)
            
            // Add all subviews to the content view
            for subview in subviews {
                if subview != backgroundView {
                    contentView.addSubview(subview)
                }
            }
            
            // Animate the appearance
            switch animationType {
                case "none":
                    backgroundView.alpha = isTransparent ? 0 : 1
                case "fade":
                    contentView.alpha = 0
                    UIView.animate(withDuration: 0.3) {
                        self.backgroundView.alpha = self.isTransparent ? 0 : 1
                        contentView.alpha = 1
                    }
                case "slide":
                    contentView.transform = CGAffineTransform(translationX: 0, y: keyWindow.bounds.height)
                    UIView.animate(withDuration: 0.3) {
                        self.backgroundView.alpha = self.isTransparent ? 0 : 1
                        contentView.transform = .identity
                    }
                default:
                    backgroundView.alpha = isTransparent ? 0 : 1
            }
        }
    }
    
    private func hideModal() {
        // Signal that the modal is being dismissed
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onDismiss",
            params: [:]
        )
        
        // If using a view controller, dismiss it
        if let modalVC = modalViewController {
            modalVC.dismiss(animated: animationType != "none", completion: {
                self.modalViewController = nil
            })
            return
        }
        
        // Otherwise, animate the direct presentation away
        if let contentView = contentView {
            let hideCompletion = { (finished: Bool) in
                self.backgroundView.removeFromSuperview()
                contentView.removeFromSuperview()
                self.contentView = nil
            }
            
            switch animationType {
                case "none":
                    hideCompletion(true)
                case "fade":
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backgroundView.alpha = 0
                        contentView.alpha = 0
                    }, completion: hideCompletion)
                case "slide":
                    UIView.animate(withDuration: 0.3, animations: {
                        self.backgroundView.alpha = 0
                        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
                    }, completion: hideCompletion)
                default:
                    hideCompletion(true)
            }
        }
    }
    
    @objc private func handleBackgroundTap() {
        // Check if we should dismiss on background tap
        if let onRequestClose = props["onRequestClose"] as? () -> Void {
            onRequestClose()
        } else {
            // Default behavior - hide the modal
            hideModal()
        }
    }
    
    override func addSubview(_ view: UIView) {
        // If modal is visible, add to the content view
        if isVisible, let contentView = contentView, view != backgroundView {
            contentView.addSubview(view)
        } else if let modalVC = modalViewController, view != backgroundView {
            modalVC.view.addSubview(view)
        } else {
            super.addSubview(view)
        }
    }
    
    deinit {
        // Clean up
        modalViewController?.dismiss(animated: false, completion: nil)
        backgroundView.removeFromSuperview()
        contentView?.removeFromSuperview()
    }
}
