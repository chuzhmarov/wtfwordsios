import Foundation
import SwiftyJSON

class JsonWordParser {
    class func fromWord(_ word: Word) -> JSON {
        let json: JSON =  [
                "text": word.text,
                "additional": word.additional,
                "ciphered_text": word.fullCipheredText,
                "word_type": word.type.rawValue
        ]

        return json
    }

    class func fromJson(_ json: JSON) throws -> Word {
        var text: String
        var additional: String
        var fullCipheredText: String
        var wordType: WordType

        if let value = json["text"].string {
            text = value
        } else {
            throw json["text"].error!
        }

        if let value = json["additional"].string {
            additional = value
        } else {
            throw json["additional"].error!
        }

        if let value = json["ciphered_text"].string {
            fullCipheredText = value
        } else {
            throw json["ciphered_text"].error!
        }

        if let value = json["word_type"].int {
            wordType = WordType(rawValue: value)!
        } else {
            throw json["word_type"].error!
        }

        return Word(
            text: text,
            additional: additional,
            type: wordType,
            fullCipheredText: fullCipheredText
        )
    }
}
