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

/**
 DCScrollView: Native scrollable container

 Expected Input Properties:
 {
   "style": {
     "showsIndicators": Bool,     // Show scroll indicators
     "bounces": Bool,            // Enable bounce effect
     "pagingEnabled": Bool      // Enable paging mode
   },
   "layout": {
     // Yoga layout properties for container
   },
   "contentOffset": {           // Programmatic scrolling
     "x": CGFloat,
     "y": CGFloat
   }
 }

 Event Data Emitted:
 onScroll: {
   "offset": {
     "x": CGFloat,             // Horizontal scroll position
     "y": CGFloat              // Vertical scroll position
   },
   "velocity": {
     "x": CGFloat,             // Scroll velocity
     "y": CGFloat
   },
   "contentSize": {
     "width": CGFloat,         // Total content width
     "height": CGFloat         // Total content height
   },
   "timestamp": TimeInterval
 }
 onScrollEnd: {
   "offset": {x, y},
   "timestamp": TimeInterval
 }
*/

class DCScrollView: DCView, UIScrollViewDelegate {
    private let scrollView = UIScrollView()
    private let contentContainer = DCView(viewId: "scroll-content")
    private weak var methodChannel: FlutterMethodChannel?
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        scrollView.delegate = self
    }
    
    override func setupDefaults() {
        super.setupDefaults()
        
        // Configure scrollView
        scrollView.yoga.isEnabled = true
        scrollView.delegate = self
        addSubview(scrollView)
        
        // Configure content container
        contentContainer.yoga.isEnabled = true
        contentContainer.backgroundColor = .clear // Ensure transparent background
        scrollView.addSubview(contentContainer)
        
        // Default layout setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentContainer.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentContainer.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            // Allow content to determine width/height
            contentContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        if let offset = newState["contentOffset"] as? [String: CGFloat] {
            scrollView.contentOffset = CGPoint(
                x: offset["x"] ?? 0,
                y: offset["y"] ?? 0
            )
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        // Direct consumption of scrollStyle properties
        if let scrollStyle = style["scrollStyle"] as? [String: Any] {
            print("Applying scroll style: \(scrollStyle)")
            
            if let showsIndicators = scrollStyle["showsIndicators"] as? Bool {
                scrollView.showsVerticalScrollIndicator = showsIndicators
                scrollView.showsHorizontalScrollIndicator = showsIndicators
            }
            
            if let bounces = scrollStyle["bounces"] as? Bool {
                scrollView.bounces = bounces
            }
            
            if let pagingEnabled = scrollStyle["pagingEnabled"] as? Bool {
                scrollView.isPagingEnabled = pagingEnabled
            }
            
            if let direction = scrollStyle["direction"] as? String {
                switch direction {
                case "horizontal":
                    scrollView.alwaysBounceHorizontal = true
                    scrollView.alwaysBounceVertical = false
                case "vertical":
                    scrollView.alwaysBounceHorizontal = false
                    scrollView.alwaysBounceVertical = true
                case "both":
                    scrollView.alwaysBounceHorizontal = true
                    scrollView.alwaysBounceVertical = true
                default:
                    break
                }
            }
            
            if let scrollEnabled = scrollStyle["scrollEnabled"] as? Bool {
                scrollView.isScrollEnabled = scrollEnabled
            }
            
            if let initialX = scrollStyle["initialScrollX"] as? Double {
                scrollView.contentOffset.x = CGFloat(initialX)
            }
            
            if let initialY = scrollStyle["initialScrollY"] as? Double {
                scrollView.contentOffset.y = CGFloat(initialY)
            }
        }
    }

    override func addSubview(_ view: UIView) {
        if view != scrollView {
            contentContainer.addSubview(view)
            contentContainer.yoga.applyLayout(preservingOrigin: true)
        } else {
            super.addSubview(view)
        }
    }
    
    func setContent(_ view: DCView) {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        contentContainer.addSubview(view)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("Scroll position: \(scrollView.contentOffset)")
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onScroll",
            "data": [
                "offset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "velocity": [
                    "x": scrollView.panGestureRecognizer.velocity(in: scrollView).x,
                    "y": scrollView.panGestureRecognizer.velocity(in: scrollView).y
                ],
                "contentSize": [
                    "width": scrollView.contentSize.width,
                    "height": scrollView.contentSize.height
                ],
                "viewportSize": [
                    "width": scrollView.bounds.width,
                    "height": scrollView.bounds.height
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Scroll ended at: \(scrollView.contentOffset)")
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onScrollEnd",
            "data": [
                "offset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
}
