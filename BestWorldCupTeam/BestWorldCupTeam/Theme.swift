import UIKit

extension UIColor {
    /// "#RRGGBB" 또는 "#RRGGBBAA" 16진수 → UIColor
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r, g, b: CGFloat
        var a = alpha
        if s.count == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255
            a = CGFloat(rgb & 0x000000FF) / 255
        } else {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            b = CGFloat(rgb & 0x0000FF) / 255
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

enum Theme {
    static let bg        = UIColor(hex: "#0E0F11")
    static let bgRaised  = UIColor(hex: "#16181B")
    static let card      = UIColor(hex: "#1B1E22")
    static let cardHi    = UIColor(hex: "#23272C")
    static let line      = UIColor(white: 1, alpha: 0.07)
    static let line2     = UIColor(white: 1, alpha: 0.12)
    static let text      = UIColor(hex: "#F4F6F5")
    static let sub       = UIColor(hex: "#ECF0EE", alpha: 0.58)
    static let faint     = UIColor(hex: "#ECF0EE", alpha: 0.34)
    static let accent    = UIColor(hex: "#00E676")   // 에메랄드
    static let accentDim = UIColor(hex: "#00E676", alpha: 0.15)
    static let accentInk = UIColor(hex: "#08130C")
    static let gold      = UIColor(hex: "#F4C753")   // 트로피 골드
    static let goldDim   = UIColor(hex: "#F4C753", alpha: 0.14)

    /// 숫자 강조용 폰트 (FIFA 카드 느낌). SF Pro Rounded로 대체.
    static func numFont(_ size: CGFloat, weight: UIFont.Weight = .bold) -> UIFont {
        if let d = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
            .withDesign(.rounded) {
            return UIFont(descriptor: d, size: size)
        }
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
