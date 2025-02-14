import UIKit
import SVGKit 

@available(iOS 13.0, *)
class IconRegistry {
    static let shared = IconRegistry()
    
    private var svgCache: [String: UIImage] = [:]
    private var systemIconCache: [String: UIImage] = [:]
    
    func registerSVG(name: String, data: String) {
        if let dataURL = data.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: dataURL),
           let svgImage = SVGKImage(contentsOf: url) {
            svgImage.size = CGSize(width: 24, height: 24) // Default size
            svgCache[name] = svgImage.uiImage
        }
    }
    
    func getIcon(_ name: String, size: CGSize = CGSize(width: 24, height: 24)) -> UIImage? {
        // Try system icon first
        if let systemImage = UIImage(systemName: name)?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: size.width)
        ) {
            return systemImage
        }
        
        // Then try SVG cache
        return svgCache[name]
    }
    
    func clearCache() {
        svgCache.removeAll()
        systemIconCache.removeAll()
    }
}
