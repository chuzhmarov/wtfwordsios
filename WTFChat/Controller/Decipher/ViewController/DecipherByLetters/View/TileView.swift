import Foundation
import UIKit

protocol TileDragDelegateProtocol {
    func tileView(_ tileView: TileView, didDragToPoint: CGPoint)
}

//class TileView: BorderedButton {
class TileView: UIImageView {
    var letter: Character

    var isMatched: Bool = false
    var isPlaced: Bool = false
    var placedOnTarget: TargetView?
    var isFixed: Bool = false
    var isPartOfWord: Bool = false

    fileprivate var xOffset: CGFloat = 0.0
    fileprivate var yOffset: CGFloat = 0.0

    var dragDelegate: TileDragDelegateProtocol?

    fileprivate var tempTransform: CGAffineTransform = CGAffineTransform.identity

    var originalCenter: CGPoint!

    static private let imageTile = UIImage(named: "tile")!
    static private let imageNormal = UIImage(named: "wood")!
    static private let imageFixed = UIImage(named: "woodSuccess")!
    static private let imageWordPart = UIImage(named: "woodWordPart")!

    required init(coder aDecoder: NSCoder) {
        fatalError("use init(letter:, sideLength:")
    }

    init(letter: Character, sideLength: CGFloat) {
        self.letter = letter

        super.init(image: TileView.imageNormal)
        //super.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))

        self.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)

        let scale = sideLength / TileView.imageTile.size.width

        //add a letter on top
        let letterLabel = UILabel(frame: self.bounds)
        letterLabel.textAlignment = NSTextAlignment.center
        letterLabel.textColor = UIColor.white
        letterLabel.backgroundColor = UIColor.clear
        letterLabel.text = String(letter).uppercased()
        letterLabel.font = UIFont(name: "Verdana-Bold", size: 78.0 * scale)
        self.addSubview(letterLabel)

        self.isUserInteractionEnabled = true

        //create the tile shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
        self.layer.shadowRadius = 15.0
        self.layer.masksToBounds = false

        let path = UIBezierPath(rect: self.bounds)
        self.layer.shadowPath = path.cgPath

        updateBackground()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isFixed) {
            return
        }

        self.layer.shadowOpacity = 0.8
        tempTransform = self.transform
        self.transform = self.transform.scaledBy(x: 1.2, y: 1.2)

        self.superview?.bringSubview(toFront: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isFixed) {
            return
        }

        self.transform = tempTransform

        dragDelegate?.tileView(self, didDragToPoint: self.center)
        self.layer.shadowOpacity = 0.0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent!) {
        if (isFixed) {
            return
        }

        self.transform = tempTransform
        self.layer.shadowOpacity = 0.0
    }

    func updateBackground() {
        if isFixed {
            //self.updateGradient(Gradient.Success)
            self.image = TileView.imageFixed
        } else if isPartOfWord {
            self.image = TileView.imageWordPart
        } else {
            //self.updateGradient(Gradient.Tile)
            self.image = TileView.imageNormal
        }
    }
}
