//
//  DoubleCutterCipher.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 19/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class DoubleCutterEasyCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        if (word.getCharCount() == 2) {
            return "...\(word.getLowerCase()[1])...\(word.additional)"
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        let easyCiphered = DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)

        return "...\(easyCiphered)...\(word.additional)"
    }
}

class DoubleCutterNormalCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        if (word.getCharCount() == 2) {
            return "...\(word.getLowerCase()[1])...\(word.additional)"
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        let ciphered = DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)

        var maxChars: Int
        
        if (word.getCharCount() < 4) {
            maxChars = 1
        } else if (word.getCharCount() < 7) {
            maxChars = 3
        } else {
            maxChars = 4
        }
        
        let cuttedNormalCiphered = DoubleCutterHelper.cutIfTooManyLetters(ciphered, odd: odd, maxChars: maxChars)
        
        return "...\(cuttedNormalCiphered)...\(word.additional)"
    }
}

class DoubleCutterHardCipher: Cipher {
    func getTextForDecipher(word: Word) -> String {
        if (word.getCharCount() == 2) {
            return "...\(word.getLowerCase()[1])...\(word.additional)"
        }
        
        let odd = ((word.getCharCount() % 2) == 1)
        let easyCiphered = DoubleCutterHelper.cutWord(word.getLowerCase(), odd: odd)
        let hardCiphered = DoubleCutterHelper.cutWord(easyCiphered, odd: odd)
        
        let cuttedHardCiphered = DoubleCutterHelper.cutIfTooManyLetters(hardCiphered, odd: odd, maxChars: 2)
        
        return "...\(cuttedHardCiphered)...\(word.additional)"
    }
}

private class DoubleCutterHelper {
    class func cutIfTooManyLetters(word: String, odd: Bool, maxChars: Int) -> String {
        if (word.characters.count <= maxChars) {
            return word
        } else if (word.characters.count - maxChars == 1) {
            let wordLength = word.characters.count - 1
            
            if (odd) {
                //cut last character
                let length = wordLength - 1
                return word[0...length]
            } else {
                //cut first character
                return word[1...wordLength]
            }
        } else {
            let cuttedWord = DoubleCutterHelper.cutWord(word, odd: odd)
            return cutIfTooManyLetters(cuttedWord, odd: odd, maxChars: maxChars)
        }
    }
    
    class func cutWord(word: String, odd: Bool) -> String {
        if (word.characters.count == 1) {
            return word
        } else if (word.characters.count == 2) {
            if (odd) {
                return word[0]
            } else {
                return word
            }
        } else if (word.characters.count == 3) {
            return word[1...2]
        } else {
            //cut last letter from index value
            let length = (word.characters.count - 1) - 1
            
            return word[1...length]
        }
    }
}