import Foundation

enum WordType: Int {
    case New = 1, Success, Failed, Delimiter, Ignore, LineBreak, CloseTry
}

class Word: NSObject {
    var text: String
    var type = WordType.New
    var additional = ""
    var cipheredText = ""
    var wasCloseTry = false

    init (word: Word) {
        self.text = word.text
        self.additional = word.additional
        self.type = word.type
        self.cipheredText = word.cipheredText
        self.wasCloseTry = word.wasCloseTry
    }

    init(text: String, type: WordType) {
        self.text = text
        self.type = type
    }

    init(text: String, additional: String, type: WordType) {
        self.text = text
        self.additional = additional
        self.type = type
    }

    init(text: String, additional: String, type: WordType, cipheredText: String) {
        self.text = text
        self.additional = additional
        self.type = type
        self.cipheredText = cipheredText
    }

    init(text: String, additional: String, type: WordType, cipheredText: String, wasCloseTry: Bool) {
        self.text = text
        self.additional = additional
        self.type = type
        self.cipheredText = cipheredText
        self.wasCloseTry = wasCloseTry
    }

    func getClearText() -> String {
        return self.text + self.additional
    }

    func getCipheredText() -> String {
        return cipheredText
    }

    func getTextForDecipher() -> String {
        if (self.type == WordType.New) {
            return cipheredText
        } else {
            return text + additional
        }
    }

    func getCharCount() -> Int {
        return text.characters.count
    }

    func getCapitalized() -> String {
        return text.capitalizedString
    }

    func getUpperCase() -> String {
        return text.uppercaseString
    }

    func getLowerCase() -> String {
        return text.lowercaseString
    }

    class func delimiterWord() -> Word {
        return Word(text: " ", type: WordType.Delimiter)
    }

    class func lineBreakWord() -> Word {
        return Word(text: "\n", type: WordType.LineBreak)
    }

    func checkEquals(word: Word) -> Bool {
        if (self.type != word.type ||
                self.cipheredText != word.cipheredText ||
                self.text != word.text ||
                self.additional != word.additional
        )
        {
            return false
        } else {
            return true
        }
    }
}