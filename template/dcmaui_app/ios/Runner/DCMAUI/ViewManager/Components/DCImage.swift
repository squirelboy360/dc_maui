//
//  DCImage.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Image component
class DCImage: DCBaseView {
    private let imageView = UIImageView()
    private var loadingIndicator: UIActivityIndicatorView?
    
    override func setupView() {
        super.setupView()
        
        // Set up the image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
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
        
        // Show loading indicator if enabled
        if let showLoading = props["loadingIndicatorEnabled"] as? Bool, showLoading {
            setupLoadingIndicator()
        }
        
        // Handle image source
        if let source = props["source"] as? [String: Any] {
            loadImage(from: source)
        }
        
        // Apply image-specific style properties
        if let style = props["style"] as? [String: Any] {
            applyImageStyle(style)
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
        
        loadingIndicator?.startAnimating()
    }
    
    private func loadImage(from source: [String: Any]) {
        if let uri = source["uri"] as? String {
            // Load remote image
            loadingIndicator?.startAnimating()
            
            // Create URL and request
            guard let url = URL(string: uri) else {
                handleImageLoadError("Invalid URL: \(uri)")
                return
            }
            
            var request = URLRequest(url: url)
            
            // Add headers if provided
            if let headers = source["headers"] as? [String: String] {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            
            // Load the image
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.loadingIndicator?.stopAnimating()
                    
                    if let error = error {
                        self.handleImageLoadError(error.localizedDescription)
                        return
                    }
                    
                    guard let data = data, let image = UIImage(data: data) else {
                        self.handleImageLoadError("Failed to decode image")
                        return
                    }
                    
                    self.imageView.image = image
                    self.handleImageLoadSuccess()
                }
            }.resume()
            
        } else if let assetName = source["assetName"] as? String {
            // Load local asset
            if let image = UIImage(named: assetName) {
                imageView.image = image
                handleImageLoadSuccess()
            } else {
                handleImageLoadError("Asset not found: \(assetName)")
            }
        }
    }
    
    private func applyImageStyle(_ style: [String: Any]) {
        // Content mode (resize mode)
        if let resizeMode = style["resizeMode"] as? String {
            switch resizeMode {
                case "contain":
                    imageView.contentMode = .scaleAspectFit
                case "cover":
                    imageView.contentMode = .scaleAspectFill
                case "stretch":
                    imageView.contentMode = .scaleToFill
                case "center":
                    imageView.contentMode = .center
                case "repeat":
                    // UIImageView doesn't natively support repeating images
                    // This would require a custom implementation
                    break
                default:
                    imageView.contentMode = .scaleAspectFit
            }
        }
        
        // Handle opacity
        if let opacity = style["opacity"] as? CGFloat {
            imageView.alpha = opacity
        }
    }
    
    private func handleImageLoadSuccess() {
        loadingIndicator?.stopAnimating()
        
        // Send event to Flutter
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onLoad",
            params: [:]
        )
    }
    
    private func handleImageLoadError(_ error: String) {
        loadingIndicator?.stopAnimating()
        
        // Send event to Flutter
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onError",
            params: ["error": error]
        )
    }
}
