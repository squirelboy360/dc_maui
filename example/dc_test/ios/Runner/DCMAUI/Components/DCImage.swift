import UIKit

class DCImage: DCView {
    private let imageView = UIImageView()
    
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
        if let urlString = newState["source"] as? String,
           let url = URL(string: urlString) {
            loadImage(from: url)
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
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }.resume()
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
