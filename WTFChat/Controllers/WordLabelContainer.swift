//
//  WordLabelContainer.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 09/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class WordLabelContainer {
    var label = RoundedLabel()
    
    var originalWord: Word
    
    var word: Word {
        didSet {
            updateLabel()
        }
    }
    
    var wasAddedToCell = false
    
    init (word: Word) {
        self.originalWord = word
        self.word = Word(word: word)
        updateLabel()
    }
    
    func updateLabel() {
        label.text = word.getTextForDecipher()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: label.font.fontName, size: 17)
        
        switch word.wordType {
        case .New:
            label.layer.backgroundColor = CIPHERED_COLOR.CGColor
        case .Ignore:
            label.layer.backgroundColor = UIColor.jsq_messageBubbleLightGrayColor().CGColor
            label.textColor = UIColor.blackColor()
        case .Failed:
            label.layer.backgroundColor = FAILED_COLOR.CGColor
        default:
            label.layer.backgroundColor = SUCCESS_COLOR.CGColor
        }
        
        //to make cornerRadius work
        label.layer.masksToBounds = true;
        label.layer.cornerRadius = 8.0;
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 0
        label.hidden = true
        
        //to use taps for suggestions
        label.userInteractionEnabled = true
        
        label.sizeToFit()
        
        label.container = self
    }
    
    func getWidth() -> CGFloat {
        return label.getWidth()
    }
    
    func getWidthWithMargin() -> CGFloat {
        return label.getWidth() + labelHorizontalMargin
    }
    
    func show() {
        label.alpha = 0
        label.hidden = false
        
        UIView.animateWithDuration(0.5, delay: 0,
            options: [], animations: {
                self.label.alpha = 1
            }, completion: nil)
    }
    
    func animateWarning() {
        UIView.animateWithDuration(0.3, delay: 0,
            options: [], animations: {
                self.label.center.y -= 3
                self.label.layer.backgroundColor = TRY_COLOR.CGColor
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.3,
            options: [], animations: {
                self.label.center.y += 3
                self.label.layer.backgroundColor = CIPHERED_COLOR.CGColor
            }, completion: nil)
    }
    
    func animateError() {
        UIView.animateWithDuration(0.3, delay: 0,
            options: [], animations: {
                self.label.center.y -= 3
                self.label.layer.backgroundColor = FAILED_COLOR.CGColor
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.3,
            options: [], animations: {
                self.label.center.y += 3
                self.label.layer.backgroundColor = CIPHERED_COLOR.CGColor
            }, completion: nil)
    }
    
    static func getWordWidth(word: Word) -> CGFloat {
        let wordContainer = WordLabelContainer(word: word)
        return wordContainer.getWidth()
    }
    
    let labelHorizontalMargin = CGFloat(2)
    let labelVerticalMargin = CGFloat(2)
    
    func getNextHorizontalConstraint(wordContainer: WordLabelContainer) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: wordContainer.label, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: labelHorizontalMargin)
    }
    
    func getFirstHorizontalConstraint(parentView: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
    }
    
    func getVerticalConstraint(parentView: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
    }
    
    func getFullRowHorizontalConstraint(parentView: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: parentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
    }
}