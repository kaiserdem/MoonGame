import SwiftUI

extension Font {
    static func customFont(_ name: String, size: CGFloat) -> Font {
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size)
        } else {
            return Font.system(size: size)
        }
    }
}

struct AppFonts {
    static let customFontName = "Kadwa-Bold"
    
    static func printAvailableFonts() {
        for family in UIFont.familyNames {
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  - \(name)")
            }
        }
    }
    
    static let title = Font.customFont(customFontName, size: 24)
    static let title2 = Font.customFont(customFontName, size: 20)
    static let headline = Font.customFont(customFontName, size: 18)
    static let body = Font.customFont(customFontName, size: 16)
    static let caption = Font.customFont(customFontName, size: 14)
    static let small = Font.customFont(customFontName, size: 12)
}
