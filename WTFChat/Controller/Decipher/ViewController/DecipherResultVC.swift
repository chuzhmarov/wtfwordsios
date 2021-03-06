import Foundation
import Localize_Swift

class DecipherResultVC: UIViewController, WordTappedComputer {
    let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)
    let audioService: AudioService = serviceLocator.get(AudioService.self)

    private let FAILURE_MESSAGE = "You have failed, but nevermind. You can always try again..... with your new power!!! Check it out.";

    @IBOutlet weak var resultLabel: RoundedLabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var wordsTableView: WordsViewController!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var wordsViewHorizontalConstraint: NSLayoutConstraint!

    fileprivate let SUCCESS_TEXT = "Success"
    fileprivate let FAILED_TEXT = "Failed"
    fileprivate let CONTINUE_TEXT = "Continue"
    fileprivate let RETRY_TEXT = "Retry"
    fileprivate let BACK_TEXT = "Back"

    fileprivate var message: Message!

    var expGainView = ExpGainView()

    var parentVC: DecipherViewController {
        return parent as! DecipherViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        let wordsTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DecipherResultVC.viewTapped))
        wordsTableView.addGestureRecognizer(wordsTap)

        wordsTableView.wordTappedComputer = self
        wordsTableView.delegate = wordsTableView
        wordsTableView.dataSource = wordsTableView
        wordsTableView.backgroundColor = UIColor.clear

        resultLabel.layer.cornerRadius = 12
        resultLabel.textColor = Color.Text

        backButton.setTitleWithoutAnimation(BACK_TEXT.localized())
    }

    deinit {
        NotificationCenter.default.removeObserver(self);
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if (parentVC.resultContainer.isHidden) {
            return
        }

        redrawWordsView(size)

        wordsTableView.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0,
                options: [], animations: {
            self.wordsTableView.alpha = 1
        }, completion: nil)
    }

    func viewTapped() {
        changeCipherStateForViewOnly()
    }

    @IBAction func backTapped(_ sender: AnyObject) {
        parentVC.backTapped()
    }

    @IBAction func continuePressed(_ sender: AnyObject) {
        parentVC.continuePressed()
    }

    func changeCipherStateForViewOnly() {
        parentVC.useCipherText = !parentVC.useCipherText
        wordsTableView.setNewMessage(message, useCipherText: parentVC.useCipherText, selfAuthor: parentVC.selfAuthor)

        wordsTableView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0,
                options: [], animations: {
            self.wordsTableView.alpha = 1
        }, completion: nil)
    }

    fileprivate func redrawWordsView(_ size: CGSize? = nil) {
        let size = size ?? view.frame.size

        wordsTableView.updateMaxWidth(size.width - wordsViewHorizontalConstraint.constant * 2)
        wordsTableView.setNewMessage(message, useCipherText: parentVC.useCipherText, selfAuthor: parentVC.selfAuthor)
    }

    func initView(_ resultMessage: Message) {
        message = resultMessage

        redrawWordsView()
        showResult()

        expGainView.clearView()
        expGainView.initView(levelView)
    }

    func wordTapped(_ word: Word) {
        changeCipherStateForViewOnly()
    }

    func showResult() {
        if (message.getMessageStatus() == .success) {
            resultLabel.text = SUCCESS_TEXT.localized()
            resultLabel.addGradientToLabel(Gradient.Success)
            continueButton.setTitleWithoutAnimation(CONTINUE_TEXT.localized())

            audioService.playSound(.win)
        } else {
            resultLabel.text = FAILED_TEXT.localized()
            resultLabel.addGradientToLabel(Gradient.Failed)
            continueButton.setTitleWithoutAnimation(RETRY_TEXT.localized())

            audioService.playSound(.lose)

            checkForFirstFailure()
        }
    }

    private func checkForFirstFailure() {
        if (guiDataService.getWtfStage() == .beginning) {
            WTFOneButtonAlert.show(FAILURE_MESSAGE.localized(), message: "") { () -> Void in
                self.guiDataService.updateWtfStage(.firstFailure)
            }
        }
    }
}
