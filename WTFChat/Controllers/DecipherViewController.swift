//
//  DecipherViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 07/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class DecipherViewController: UIViewController, SuggestionComputer, UITextFieldDelegate {
    @IBOutlet weak var topTimerLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var exampleLabel: RoundedLabel!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var wordsTableView: WordsViewController!
    @IBOutlet weak var exampleLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var tryButton: UIButton!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topViewHeightContraint: NSLayoutConstraint!
    
    var message: Message!
    var isStarted = false
    var isOvered = false
    var timer = Timer()
    
    var isSingleMode = false
    var suggestionsForSingleMode = 0
    
    let secondsPerWord = 20
    let suggestionsToWordsForSingleMode = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.translucent = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        /*NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated:", name: UIDeviceOrientationDidChangeNotification, object: nil)*/
        
        //Looks for single or multiple taps.
        let tapDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let tapStart: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "start")
        view.addGestureRecognizer(tapDismiss)
        view.addGestureRecognizer(tapStart)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        setExampleLabel()
        
        if (message.deciphered) {
            setViewOnlyStage()
        } else {
            UIView.animateWithDuration(1, delay: 0,
                options: [.Repeat, .Autoreverse], animations: {
                    self.startLabel.alpha = 0
                }, completion: nil)
        }
        
        if (self.isSingleMode) {
            suggestionsForSingleMode = (message.countNew() - 1) / suggestionsToWordsForSingleMode + 1
        }
        
        self.wordsTableView.delegate = self.wordsTableView
        self.wordsTableView.dataSource = self.wordsTableView
        
        guessTextField.delegate = self
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func giveUpButtonPressed(sender: AnyObject) {
        if (isOvered) {
            return
        }
        
        WTFTwoButtonsAlert.show("Give Up",
            message: "Are you sure you want to give up?",
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                self.gameOver()
        }
    }
    
    //delegate enterPressed for guessField
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        tryButtonPressed(tryButton)
        return true
    }
    
    @IBAction func guessTextChanged(sender: AnyObject) {
        if (guessTextField.text?.characters.count > 0) {
            tryButton.enabled = true
        } else {
            tryButton.enabled = false
        }
    }
    
    @IBAction func tryButtonPressed(sender: AnyObject) {
        messageCipher.decipher(message!, guessText: guessTextField.text!)
        
        let guessWords = guessTextField.text!.characters.split {$0 == " "}.map { String($0) }
        
        wordsTableView.updateMessage(message!, tries: guessWords)
        guessTextField.text = ""
        tryButton.enabled = false
        
        if (message!.deciphered) {
            gameOver()
        }
    }
    
    func suggestionTapped(word: Word) {
        if (word.wordType == WordType.New) {
            if (word.wasCloseTry) {
                showCloseTrySuggestionsConfirm(word)
            } else if (self.getSuggestions() > 0) {
                showSuggestionConfirm(word)
            } else {
                showNoSuggestionsDialog()
            }
        } else {
            //do nothing
        }
    }
    
    func showNoSuggestionsDialog() {
        WTFOneButtonAlert.show("Use Suggestion: 0",
            message: "You have used all suggestions",
            firstButtonTitle: "Ok",
            viewPresenter: self)
    }
    
    func showSuggestionConfirm(word: Word) {
        WTFTwoButtonsAlert.show("Use Suggestion: " + String(self.getSuggestions()),
            message: "Are you sure you want to use a suggestion?",
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                self.useSuggestion(word)
        }
    }
    
    func showCloseTrySuggestionsConfirm(word: Word) {
        WTFTwoButtonsAlert.show("Descipher",
            message: "Are you sure you want to decipher it?",
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                self.useSuggestion(word)
        }
    }
    
    func useSuggestion(word: Word) {
        audioHelper.playSound("success")
        
        messageCipher.decipher(message!, suggestedWord: word)
        wordsTableView.updateMessage(message!)
        
        if (word.wasCloseTry) {
            //do nothing
        } else if (isSingleMode) {
            self.suggestionsForSingleMode--
        } else {
            userService.useSuggestion()
        }
        
        if (message!.deciphered) {
            gameOver()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = keyboardFrame.size.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //var info = notification.userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = 0
        })
    }
    
    /*func rotated() {
    println("asdA")
    }*/
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func start() {
        if (isStarted) {
            return
        }
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        timer.seconds = message!.countNew() * secondsPerWord
        topTimerLabel.text = timer.getTimeString()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
            selector: "tick", userInfo: nil, repeats: false)
        
        //tryButton.hidden = false
        //guessTextField.hidden = false
        bottomView.hidden = false
        topTimerLabel.hidden = false
        wordsTableView.hidden = false
        exampleLabel.hidden = false
        
        startLabel.removeFromSuperview()
        
        wordsTableView.suggestionComputer = self
        wordsTableView.updateMessage(message!)
        
        guessTextField.becomeFirstResponder()

        isStarted = true
    }
    
    func setExampleLabel() {
        exampleLabel.text = CipherFactory.cipherText(
            message.cipherType,
            word: EXAMPLE_CIPHER_WORD
        )
        
        exampleLabel.textColor = UIColor.whiteColor()
        exampleLabel.font = UIFont(name: exampleLabel.font.fontName, size: 12)
        exampleLabel.layer.backgroundColor = CIPHERED_COLOR.CGColor
        
        //to make cornerRadius work
        exampleLabel.layer.masksToBounds = true;
        exampleLabel.layer.cornerRadius = 8.0;
        
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        exampleLabel.userInteractionEnabled = true
        exampleLabel.sizeToFit()
    }
    
    func gameOver() {
        messageCipher.failed(message!)
        
        bottomView.hidden = true
        //guessTextField.hidden = true
        //guessTextField.text = ""
        //tryButton.hidden = true
        self.hideTopLayer()
        
        wordsTableView.updateMessage(message!)
        
        dismissKeyboard()
        
        if (message!.countFailed() == 0) {
            audioHelper.playSound("win")
        } else {
            audioHelper.playSound("lose")
        }
        
        self.navigationItem.setHidesBackButton(false, animated:true)
        
        isOvered = true
        
        if (!isSingleMode) {
            messageService.decipherMessage(message) { (message, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        //TODO - show error to user
                        print(requestError)
                    } else {
                        //OK - do nothing
                    }
                })
            }
            
            userService.sendUsedSugegstions()
        }
    }
    
    func hideTopLayer() {
        timer.seconds = 0
        topTimerLabel.text = ""
        //exampleLabel.hidden = true
        topView.removeConstraint(exampleLeadingConstraint)
        topView.addConstraint(NSLayoutConstraint(
            item: exampleLabel, attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: topView, attribute: NSLayoutAttribute.CenterX,
            multiplier: 1, constant: 0))
        
        //topViewHeightContraint.constant = 0
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func setViewOnlyStage() {
        startLabel.removeFromSuperview()
        wordsTableView.updateMessage(message!)
        wordsTableView.hidden = false
        exampleLabel.hidden = false
        
        self.hideTopLayer()
        
        isStarted = true
        isOvered = true
    }
    
    func tick() {
        if (isOvered) {
            return
        }
        
        timer.tick()
        topTimerLabel.text = timer.getTimeString()
        
        if (timer.isFinished()) {
            dispatch_async(dispatch_get_main_queue(), {
                self.gameOver()
            })
        } else {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                selector: "tick", userInfo: nil, repeats: false)
            
            if (timer.isRunningOfTime()) {
                topTimerLabel.textColor = UIColor.redColor()
                
                UIView.animateWithDuration(0.5, delay: 0,
                    options: [.Autoreverse, .Repeat, .AllowUserInteraction], animations: {
                        self.topTimerLabel.alpha = 0.1
                    }, completion: nil)
            } else if (timer.isLastSecond()) {
                topTimerLabel.layer.removeAllAnimations()
                topTimerLabel.alpha = 1
            }
        }
    }
    
    func getSuggestions() -> Int {
        if (isSingleMode) {
            return suggestionsForSingleMode
        } else {
            return userService.currentUser!.suggestions
        }
    }
    
    /*override func shouldAutorotate() -> Bool {
    return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
    return UIInterfaceOrientation.Portrait.rawValue
    }*/
}
