//
//  DCView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit


/// Basic View component that serves as a container
class DCView: DCBaseView {
    override func setupView() {
        super.setupView()
        clipsToBounds = true
        
        // Set a minimum size for the view if it's empty
        if frame.size == .zero {
            frame.size = CGSize(width: 100, height: 100)
        }
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle opacity
        if let opacity = props["opacity"] as? CGFloat {
            alpha = opacity
        }
        
        // Handle pointer/touch events
        if let pointerEvents = props["pointerEvents"] as? String {
            isUserInteractionEnabled = pointerEvents != "none"
        }
        
        // Special debug handling for root view
        if viewId == "view_0" {
            print("DC MAUI: Root view updated with props: \(props)")
            
            // Force a clear background to be visible
            if backgroundColor == nil {
                backgroundColor = .white
            }
            
            // Ensure the view has actual size
            if bounds.size.width < 1 || bounds.size.height < 1 {
                if let superview = superview {
                    frame = superview.bounds
                } else {
                    frame = UIScreen.main.bounds
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Log frame for the root view to help with debugging
        if viewId == "view_0" {
            print("DC MAUI: Root view layout with frame: \(frame)")
        }
                
        // For container views, we need to ensure proper layout
        invalidateIntrinsicContentSize()
        
        // Special handling for root view
        if viewId == "view_0" && superview != nil && (bounds.width < 1 || bounds.height < 1) {
            frame = superview!.bounds
            setNeedsLayout()
        }
    }

    // Override adding subviews to ensure proper layout updating
    override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        setNeedsLayout()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // If this is the root view and it just got added to the view hierarchy
        if viewId == "view_0" && superview != nil {
            print("DC MAUI: Root view added to superview with frame: \(frame)")
            
            // Ensure the root view fills its superview
            if frame.size.width < 1 || frame.size.height < 1 {
                frame = superview!.bounds
            }
            
            backgroundColor = .white  // Ensure visibility
            setNeedsLayout()
        }
    }
}
