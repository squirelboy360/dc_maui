import UIKit

// SVG rendering support
class SVG {
    let size: CGSize
    private let paths: [CGPath]
    
    init?(_ data: Data) {
        guard let svgString = String(data: data, encoding: .utf8) else { return nil }
        
        // Basic SVG parsing - you may want to enhance this
        var paths: [CGPath] = []
        var viewBox: CGRect = .zero
        
        // Extract viewBox
        if let viewBoxRange = svgString.range(of: #"viewBox="([^"]*)"#, options: .regularExpression) {
            let values = svgString[viewBoxRange].split(separator: " ")
            if values.count == 4,
               let x = Double(values[0]),
               let y = Double(values[1]),
               let width = Double(values[2]),
               let height = Double(values[3]) {
                viewBox = CGRect(x: x, y: y, width: width, height: height)
            }
        }
        
        self.size = viewBox.size
        self.paths = paths
    }
    
    func draw(in context: CGContext) {
        context.saveGState()
        for path in paths {
            context.addPath(path)
            context.drawPath(using: .fill)
        }
        context.restoreGState()
    }
}

@available(iOS 13.0, *)
class IconRegistry {
    static let shared = IconRegistry()
    
    private var cache: [String: UIImage] = [:]
    
    func registerSVG(name: String, data: String) {
        guard let url = URL(string: data.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        getData(from: url) { [weak self] data, response, error in
            guard let data = data,
                  let svg = SVG(data),
                  error == nil else { return }
            
            let renderer = UIGraphicsImageRenderer(size: svg.size)
            let image = renderer.image { context in
                svg.draw(in: context.cgContext)
            }
            
            DispatchQueue.main.async {
                self?.cache[name] = image
            }
        }
    }
    
    func getIcon(_ name: String, size: CGSize = CGSize(width: 24, height: 24)) -> UIImage? {
        if let cached = cache[name] {
            return cached
        }
        
        // Handle SVG files
        if name.hasSuffix(".svg") {
            if let url = Bundle.main.url(forResource: name, withExtension: nil) {
                getData(from: url) { [weak self] data, _, _ in
                    if let data = data,
                       let svg = SVG(data) {
                        let renderer = UIGraphicsImageRenderer(size: size)
                        let image = renderer.image { context in
                            svg.draw(in: context.cgContext)
                        }
                        self?.cache[name] = image
                    }
                }
            }
        }
        
        // Fallback to regular images
        return UIImage(named: name)
    }
    
    func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        getData(from: url) { [weak self] data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    if urlString.hasSuffix(".svg") {
                        if let svg = SVG(data) {
                            let renderer = UIGraphicsImageRenderer(size: imageView.bounds.size)
                            let image = renderer.image { context in
                                svg.draw(in: context.cgContext)
                            }
                            imageView.image = image
                            self?.cache[urlString] = image
                        }
                    } else if let image = UIImage(data: data) {
                        imageView.image = image
                        self?.cache[urlString] = image
                    }
                }
            }
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func clearCache() {
        cache.removeAll()
    }
}
