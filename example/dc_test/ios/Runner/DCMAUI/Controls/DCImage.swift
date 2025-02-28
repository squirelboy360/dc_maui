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



import yoga
import YogaKit
import UIKit
/**
 DCImage: Native image view

 Expected Input Properties:
 {
   "imageStyle": {
     "resizeMode": String,       // "cover", "contain", "stretch", "center"
     "tintColor": UInt32        // Tint color for template images
   },
   "layout": {
     // Yoga layout properties
   },
   "source": String            // Image URL
 }

 Event Data Emitted:
 onLoad: {
   "width": CGFloat,           // Natural image width
   "height": CGFloat,          // Natural image height
   "timestamp": TimeInterval
 }
 onError: {
   "error": String,           // Error description
   "timestamp": TimeInterval
 }
*/
class DCImage: DCView {
    private let imageView = UIImageView()
    private weak var methodChannel: FlutterMethodChannel?
    
    // Add this getter method
    func getImage() -> UIImage? {
        return imageView.image
    }
    
    override func setupDefaults() {
        super.setupDefaults()
        
        imageView.yoga.isEnabled = true
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        // Make imageView fill parent
        imageView.yoga.position = .absolute
        imageView.yoga.left = YGValue(value: 0, unit: .point)
        imageView.yoga.top = YGValue(value: 0, unit: .point)
        imageView.yoga.right = YGValue(value: 0, unit: .point)
        imageView.yoga.bottom = YGValue(value: 0, unit: .point)
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        if let urlString = newState["source"] as? String,
           let url = URL(string: urlString) {
            loadImage(from: url)
        }
        
        if let contentMode = newState["resizeMode"] as? String {
            imageView.contentMode = ImageResizeMode(rawValue: contentMode)?.uiContentMode ?? .scaleAspectFit
        }
        
        if let tintColor = newState["tintColor"] as? UInt32 {
            imageView.tintColor = UIColor(rgb: tintColor)
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let imageStyle = style["imageStyle"] as? [String: Any] {
            if let contentMode = imageStyle["resizeMode"] as? String {
                imageView.contentMode = ImageResizeMode(rawValue: contentMode)?.uiContentMode ?? .scaleAspectFit
            }
            if let tintColor = imageStyle["tintColor"] as? UInt32 {
                imageView.tintColor = UIColor(rgb: tintColor)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                self.methodChannel?.invokeMethod("onComponentEvent", arguments: [
                        "viewId": self.viewId,
                        "type": "onError",
                        "data": [
                            "error": error.localizedDescription,
                            "timestamp": Date().timeIntervalSince1970
                        ]
                    ])
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    self.imageView.image = image
                    self.methodChannel?.invokeMethod("onComponentEvent", arguments: [
                        "viewId": self.viewId,
                        "type": "onLoad",
                        "data": [
                            "width": image.size.width,
                            "height": image.size.height,
                            "timestamp": Date().timeIntervalSince1970
                        ]
                    ])
                }
            }
        }.resume()
    }
    
    override func captureCurrentState() -> [String: Any] {
        var state = super.captureCurrentState()
        
        // Capture the image source URL if it exists
        if let image = imageView.image {
            // We can't easily get back the original URL, but we can note if an image exists
            state["hasImage"] = true
            state["imageSize"] = [
                "width": image.size.width,
                "height": image.size.height
            ]
        }
        
        // Map ContentMode back to resizeMode string
        switch imageView.contentMode {
        case .scaleAspectFill:
            state["resizeMode"] = "cover"
        case .scaleAspectFit:
            state["resizeMode"] = "contain"
        case .scaleToFill:
            state["resizeMode"] = "stretch"
        case .center:
            state["resizeMode"] = "center"
        default:
            break
        }
        
        return state
    }
}

private enum ImageResizeMode: String {
    case cover, contain, stretch, center
    
    var uiContentMode: UIView.ContentMode {
        switch self {
        case .cover: return .scaleAspectFill
        case .contain: return .scaleAspectFit
        case .stretch: return .scaleToFill
        case .center: return .center
        }
    }
}
