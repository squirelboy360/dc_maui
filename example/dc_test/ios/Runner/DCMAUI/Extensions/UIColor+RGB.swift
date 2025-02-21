import UIKit

extension UIColor {
    convenience init(rgb: UInt32) {
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        let alpha = CGFloat((rgb >> 24) & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toARGB32() -> UInt32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = UInt32(red * 255)
        let g = UInt32(green * 255)
        let b = UInt32(blue * 255)
        let a = UInt32(alpha * 255)
        
        return (a << 24) | (r << 16) | (g << 8) | b
    }
}
