//
//  DCImage.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Image component that matches React Native's Image implementation
class DCImage: DCBaseView {
    private let imageView = UIImageView()
    private var loadingIndicator: UIActivityIndicatorView?
    private var imageURL: URL?
    
    // Image properties
    private var resizeMode: String = "contain" // contain, cover, stretch, center
    private var defaultImage: UIImage?
    private var isLoading = false
    
    override func setupView() {
        super.setupView()
        
        // Set up the image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit // Default is "contain" resize mode
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.clear
        addSubview(imageView)
        
        // Constrain image view to fill the view
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle resize mode (contentMode)
        if let resizeMode = props["resizeMode"] as? String {
            self.resizeMode = resizeMode
            updateContentMode()
        }
        
        // Show loading indicator if enabled
        if let showLoading = props["loadingIndicatorEnabled"] as? Bool, showLoading {
            setupLoadingIndicator()
        }
        
        // Default image
        if let defaultSource = props["defaultSource"] as? [String: Any],
           let uri = defaultSource["uri"] as? String,
           let url = URL(string: uri) {
            loadDefaultImage(from: url)
        }
        
        // Handle image source
        if let source = props["source"] as? [String: Any] {
            loadImage(from: source)
        }
    }
    
    private func updateContentMode() {
        switch resizeMode {
        case "cover":
            imageView.contentMode = .scaleAspectFill
        case "contain":
            imageView.contentMode = .scaleAspectFit
        case "stretch":
            imageView.contentMode = .scaleToFill
        case "center":
            imageView.contentMode = .center
        default:
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    private func setupLoadingIndicator() {
        if loadingIndicator == nil {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(indicator)
            
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            loadingIndicator = indicator
        }
        
        if isLoading {
            loadingIndicator?.startAnimating()
        } else {
            loadingIndicator?.stopAnimating()
        }
    }
    
    private func loadDefaultImage(from url: URL) {
        // For local file URLs
        if url.isFileURL {
            defaultImage = UIImage(contentsOfFile: url.path)
            if defaultImage == nil {
                print("DC MAUI: Failed to load default image from: \(url)")
            } else {
                // Show default image while main image is loading
                if imageView.image == nil {
                    imageView.image = defaultImage
                }
            }
            return
        }
        
        // For remote URLs
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("DC MAUI: Error loading default image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.defaultImage = UIImage(data: data)
                
                // Show default image only if main image is nil
                if self.imageView.image == nil {
                    self.imageView.image = self.defaultImage
                }
            }
        }.resume()
    }
    
    private func loadImage(from source: [String: Any]) {
        guard let uri = source["uri"] as? String else {
            handleImageLoadError("Missing image URI")
            return
        }
        
        // Handle base64 images
        if uri.hasPrefix("data:image") {
            loadBase64Image(uri)
            return
        }
        
        // Handle local images with resource scheme
        if uri.hasPrefix("resource:") {
            let resourceName = uri.replacingOccurrences(of: "resource:", with: "")
            loadLocalImage(named: resourceName)
            return
        }
        
        // Create URL and request
        guard let url = URL(string: uri) else {
            handleImageLoadError("Invalid URL: \(uri)")
            return
        }
        
        // Show loading indicator
        isLoading = true
        loadingIndicator?.startAnimating()
        
        // Check for cache headers
        var headers: [String: String]?
        if let sourceHeaders = source["headers"] as? [String: String] {
            headers = sourceHeaders
        }
        
        // Create request with headers
        var request = URLRequest(url: url)
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Load the image
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.loadingIndicator?.stopAnimating()
                
                if let error = error {
                    self.handleImageLoadError(error.localizedDescription)
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    self.handleImageLoadError("Failed to create image from data")
                    return
                }
                
                // Success - update image view
                self.imageView.image = image
                
                // Send onLoad event
                self.sendOnLoadEvent(image: image)
            }
        }.resume()
    }
    
    private func loadBase64Image(_ dataURI: String) {
        // Extract base64 content
        guard let base64Range = dataURI.range(of: ";base64,") else {
            handleImageLoadError("Invalid base64 image format")
            return
        }
        
        let base64String = String(dataURI[base64Range.upperBound...])
        guard let imageData = Data(base64Encoded: base64String) else {
            handleImageLoadError("Invalid base64 data")
            return
        }
        
        if let image = UIImage(data: imageData) {
            imageView.image = image
            sendOnLoadEvent(image: image)
        } else {
            handleImageLoadError("Failed to create image from base64 data")
        }
    }
    
    private func loadLocalImage(named resourceName: String) {
        if let image = UIImage(named: resourceName) {
            imageView.image = image
            sendOnLoadEvent(image: image)
        } else {
            handleImageLoadError("Local image not found: \(resourceName)")
        }
    }
    
    private func handleImageLoadError(_ message: String) {
        print("DC MAUI: Image load error: \(message)")
        
        // Send onError event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onError",
            params: [
                "error": message
            ]
        )
    }
    
    private func sendOnLoadEvent(image: UIImage) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onLoad",
            params: [
                "source": [
                    "width": image.size.width,
                    "height": image.size.height,
                    "orientation": image.imageOrientation.rawValue
                ]
            ]
        )
        
        // Also send onLoadEnd event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onLoadEnd",
            params: [:]
        )
    }
}
