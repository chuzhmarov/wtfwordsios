import Foundation

class BaseModalVC: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundViewWidthConstraint: NSLayoutConstraint!

    private var gradientLayer: CAGradientLayer?

    let transitionManager = FadeTransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.transitioningDelegate = transitionManager

        view.setNeedsLayout()
        view.layoutIfNeeded()

        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.masksToBounds = true

        updateBackgroundGradient()
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        updateBackgroundGradient()
    }

    private func updateBackgroundGradient() {
        gradientLayer?.removeFromSuperlayer()

        let size = CGSize(
                width: backgroundViewWidthConstraint.constant,
                height: backgroundView.frame.size.height
                )

        gradientLayer = backgroundView.addDiagonalGradient(Gradient.Background, size: size)
    }

    @IBAction func closeWindow(sender: AnyObject) {
        windowWillClose()
        presentingViewController?.dismissViewControllerAnimated(true, completion: windowClosed)
    }

    func windowWillClose() {
        //do nothing by default
    }

    func windowClosed() {
        //do nothing by default
    }
}