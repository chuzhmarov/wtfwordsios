import Foundation

class Color {
    //static let BACKGROUND = UIColor(netHex:0xEEEEEE)
    //static let HIGHLIGHT_BACKGROUND = UIColor(netHex:0xFFFFFF)

    //static let Success = UIColor(netHex:0x3EC303)
    //static let Ciphered = UIColor(netHex:0x0092D7)
    //static let Failed = UIColor(netHex:0xF26964)
    //static let Try = UIColor(netHex:0xEE8D09)
    static let Text = UIColor.white
    //static let Ignore = UIColor(hue: 240.0 / 360.0, saturation: 0.02, brightness: 0.92, alpha: 1.0)

    static let EasyDark = UIColor(red: 126/255, green: 73/255, blue: 13/255, alpha: 1.0)
    static let EasyMid = UIColor(red: 191/255, green: 121/255, blue: 36/255, alpha: 1.0)
    static let EasyLight = UIColor(red: 247/255, green: 235/255, blue: 222/255, alpha: 1.0)

    static let NormalDark = UIColor(red: 121/255, green: 136/255, blue: 140/255, alpha: 1.0)
    static let NormalMid = UIColor(red: 177/255, green: 194/255, blue: 198/255, alpha: 1.0)
    static let NormalLight = UIColor(red: 244/255, green: 246/255, blue: 245/255, alpha: 1.0)

    static let HardDark = UIColor(red: 0.6, green: 0.5, blue: 0.15, alpha: 1.0)
    static let HardMid = UIColor(red: 0.86, green: 0.73, blue: 0.3, alpha: 1.0)
    static let HardLight = UIColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 1.0)

    static let CipheredLight = UIColor(red: 18/255, green: 120/255, blue: 207/255, alpha: 1.0)
    static let CipheredDark = UIColor(red: 15/255, green: 105/255, blue: 169/255, alpha: 1.0)

    static let FailedLight = UIColor(red: 207/255, green: 91/255, blue: 75/255, alpha: 1.0)
    static let FailedDark = UIColor(red: 171/255, green: 65/255, blue: 49/255, alpha: 1.0)

    static let SuccessLight = UIColor(red: 27/255, green: 160/255, blue: 102/255, alpha: 1.0)
    static let SuccessDark = UIColor(red: 25/255, green: 127/255, blue: 83/255, alpha: 1.0)

    static let TryLight = UIColor(red: 218/255, green: 129/255, blue: 49/255, alpha: 1.0)
    static let TryDark = UIColor(red: 173/255, green: 99/255, blue: 25/255, alpha: 1.0)

    static let BackgroundLight = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    static let BackgroundMid = UIColor(red: 212/255, green: 229/255, blue: 240/255, alpha: 1.0)
    static let BackgroundDark = UIColor(red: 197/255, green: 227/255, blue: 245/255, alpha: 1.0)

    static let IgnoreLight = UIColor(red: 140/255, green: 144/255, blue: 158/255, alpha: 1.0)
    static let IgnoreDark = UIColor(red: 105/255, green: 107/255, blue: 112/255, alpha: 1.0)

    static let TileLight = UIColor(red: 45/255, green: 41/255, blue: 42/255, alpha: 1.0)
    static let TileDark = UIColor(red: 30/255, green: 27/255, blue: 27/255, alpha: 1.0)

    static func getBorderColorByDifficulty(_ difficulty: CipherDifficulty) -> UIColor {
        switch difficulty {
            case .easy:
                return Color.EasyDark
            case .normal:
                return Color.NormalDark
            case .hard:
                return Color.HardDark
        }
    }
}
