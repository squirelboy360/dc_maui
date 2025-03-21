import UIKit

/// Converts a hex string to UIColor
func UIColorFromHex(_ hexString: String) -> UIColor {
    var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if colorString.hasPrefix("#") {
        colorString.remove(at: colorString.startIndex)
    }
    
    if colorString.count != 6 {
        return .black
    }
    
    var rgbValue: UInt64 = 0
    Scanner(string: colorString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: 1.0
    )
}
