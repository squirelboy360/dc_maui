import UIKit

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        let start = hex.hasPrefix("#") ? hex.index(hex.startIndex, offsetBy: 1) : hex.startIndex
        let hexColor = String(hex[start...])
        
        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000FF) / 255
                
                self.init(red: r, green: g, blue: b, alpha: 1.0)
                return
            }
        }
        return nil
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func handleSetColor(_ colorString: String) -> UIColor {
        // First try hex color (from Flutter's Color objects)
        if let color = UIColor(hex: colorString) {
            return color
        }
        
        // Then try system colors
        switch colorString.lowercased() {
        case "red": return .systemRed
        case "blue": return .systemBlue
        case "green": return .systemGreen
        case "yellow": return .systemYellow
        case "purple": return .systemPurple
        case "orange": return .systemOrange
        case "gray", "grey": return .systemGray
        case "black": return .black
        case "white": return .white
        case "clear": return .clear
        default: return .clear
        }
    }
    
    internal func applyColorToView(_ view: UIView, colorString: String?, colorType: ColorType = .background) {
        guard let colorString = colorString else { return }
        let color = handleSetColor(colorString)
        
        switch colorType {
        case .background:
            view.backgroundColor = color
        case .text:
            if let label = view as? UILabel {
                label.textColor = color
            } else if let button = view as? UIButton {
                button.setTitleColor(color, for: .normal)
            }
        }
    }
}

enum ColorType {
    case background
    case text
}
