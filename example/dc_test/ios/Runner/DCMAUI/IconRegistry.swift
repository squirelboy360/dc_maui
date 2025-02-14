import UIKit
import SVGKit 

@available(iOS 13.0, *)
class IconRegistry {
    static let shared = IconRegistry()
    
    private var cache: [String: UIImage] = [:]
    
    func registerSVG(name: String, data: String) {
        if let dataURL = data.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: dataURL),
           let svgImage = SVGKImage(contentsOf: url) {
            svgImage.size = CGSize(width: 24, height: 24) // Default size
            cache[name] = svgImage.uiImage
        }
    }
    
    func getIcon(_ name: String, size: CGSize = CGSize(width: 24, height: 24)) -> UIImage? {
        if let cached = cache[name] {
            return cached
        }
        
        // Check if SVG
        if name.hasSuffix(".svg") {
            if let svgData = loadAsset(named: name),
               let image = SVGKImage(data: svgData) {
                image.size = size
                let uiImage = image.uiImage
                cache[name] = uiImage
                return uiImage
            }
        }
        
        // Try loading as regular image
        if let image = UIImage(named: name) {
            cache[name] = image
            return image
        }
        
        return nil
    }
    
    private func loadAsset(named name: String) -> Data? {
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            return nil
        }
        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    func clearCache() {
        cache.removeAll()
    }
}
