import UIKit

protocol WordTappedComputer: class {
    func wordTapped(_ word: Word)
}

class WordsViewController: UITableView, UITableViewDataSource, UITableViewDelegate {
    fileprivate let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService.self)
    fileprivate let audioService: AudioService = serviceLocator.get(AudioService.self)

    var message: Message?
    var rows = WordsField()
    var tempRows = WordsField()
    
    //for use in viewOnly
    var useCipherText = false
    var selfAuthor = false

    var fontSize: CGFloat = 17
    var isHidedText = false

    var customRowHeight: CGFloat?

    let MAX_ROWS_ON_SCREEN = 8
    let MAX_ROW_HEIGHT: CGFloat = 70

    weak var wordTappedComputer: WordTappedComputer?
    
    @objc func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.getRowsCount()
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordsRowCell", for: indexPath) as UITableViewCell
        cell.backgroundColor = UIColor.clear

        let row = rows.getRow(indexPath.row)
        
        var first = true
        var previousContainer: WordLabelContainer!
        
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        
        for wordContainer in row {
            cell.contentView.addSubview(wordContainer.label)
            
            if (first) {
                first = false
                
                let horizontalConstraint = wordContainer.getFirstHorizontalConstraint(cell.contentView)
                cell.contentView.addConstraint(horizontalConstraint)
                
                if (wordContainer.getWidth() > getMaxWidth()) {
                    let rightHorizontalConstraint = wordContainer.getFullRowHorizontalConstraint(cell.contentView)
                    cell.contentView.addConstraint(rightHorizontalConstraint)
                }
            } else {
                let horizontalConstraint = wordContainer.getNextHorizontalConstraint(previousContainer)
                cell.contentView.addConstraint(horizontalConstraint)
            }
            
            let verticalConstraint = wordContainer.getVerticalConstraint(cell.contentView)
            cell.contentView.addConstraint(verticalConstraint)

            cell.selectionStyle = .none

            previousContainer = wordContainer
        }
        
        return cell
    }
    
    func setNewMessage(_ message: Message, useCipherText: Bool = false, selfAuthor: Bool = false) {
        self.message = message
        self.useCipherText = useCipherText
        self.selfAuthor = selfAuthor
        createView()
    }

    func updateMessage(_ message: Message, hideError: Bool = false) {
        updateMessage(message, tries: nil, hideError: hideError)
    }
    
    func updateMessage(_ message: Message, tries: [String]?, hideError: Bool = false) {
        if (self.message != nil) {
            self.message = message
            
            if (needUpdate()) {
                updateView()
                audioService.playSound(.success)
                animateWarning(tries)
            } else if (!hideError) {
                animateError(tries)
            }
            return
        } else {
            self.message = message
            createView()
        }
        
        self.reloadData()
    }
    
    func needUpdate() -> Bool {
        var newWords = message!.getWordsOnly()
        var wordContainers = rows.getAllWordContainers()
        
        for i in 0..<wordContainers.count {
            if (newWords[i].type != wordContainers[i].word.type) {
                return true
            }
        }
        
        return false
    }
    
    func animateWarning(_ guesses: [String]?) {
        for wordContainer in rows.getAllWordContainers() {
            if (wordContainer.word.type == WordType.new) {
                if (messageCipherService.wasCloseTry(wordContainer.word, guessWords: guesses)) {
                    wordContainer.animateWarning()
                    wordContainer.word.wasCloseTry = true
                    wordContainer.originalWord.wasCloseTry = true
                }
            }
        }
    }
    
    func animateError(_ guesses: [String]?) {
        var wasWarning = false
        var wasError = false
        
        for wordContainer in rows.getAllWordContainers() {
            if (wordContainer.word.type == WordType.new) {
                if (messageCipherService.wasCloseTry(wordContainer.word, guessWords: guesses)) {
                    wordContainer.animateWarning()
                    wordContainer.word.wasCloseTry = true
                    wordContainer.originalWord.wasCloseTry = true
                    wasWarning = true
                } else {
                    wordContainer.animateError()
                    wasError = true
                }
            }
        }
        
        if (wasWarning) {
            audioService.playSound(.warning)
        } else if (wasError) {
            audioService.playSound(.error)
        }
    }
    
    func createView() {
        calculateRowHeight()

        rows = WordsField()
        updateViewHelper(rows)
        showContainers(false)

        self.reloadData()
    }
    
    func updateView() {
        tempRows = WordsField()
        
        updateViewHelper(tempRows)
        rows.clearFromView()
        rows = tempRows
        tempRows = WordsField()
        showContainers()
        
        self.reloadData()
    }

    fileprivate func showContainers(_ animated: Bool = true) {
        if (animated) {
            alpha = 0

            UIView.animate(withDuration: 0.3, delay: 0,
                    options: [], animations: {
                self.alpha = 1
            }, completion: nil)
        }
    }
    
    fileprivate func updateViewHelper(_ targetRows: WordsField) {
        var isNewRow = false
        
        for word in message!.getWordsWithoutSpaces() {
            if (word.type == WordType.lineBreak) {
                isNewRow = true
            } else {
                addWord(word, targetRows: targetRows, isNewRow: isNewRow)
                isNewRow = false
            }
        }
    }
    
    func addWord(_ word: Word, targetRows: WordsField, isNewRow: Bool = false) {
        let wordContainer = createLabelForWord(word)
        
        if (targetRows.isEmpty() || isNewRow) {
            var row = [WordLabelContainer]()
            row.append(wordContainer)
            targetRows.append(row)
            return
        }
        
        let row = targetRows.getLastRow()
        
        let rowWidth = getRowWidth(row)
        let wordWidth = wordContainer.getWidth()
        
        if (rowWidth + wordWidth <= getMaxWidth()) {
            targetRows.append(wordContainer)
        } else {
            var row = [WordLabelContainer]()
            row.append(wordContainer)
            targetRows.append(row)
        }
    }
    
    func createLabelForWord(_ word: Word) -> WordLabelContainer {
        let wordContainer = WordLabelContainer(word: word, useCipherText: useCipherText, selfAuthor: selfAuthor, isHidedText: isHidedText, fontSize: fontSize)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WordsViewController.wordTapped(_:)))
        wordContainer.label.addGestureRecognizer(tap)
        
        return wordContainer
    }
    
    func wordTapped(_ sender: UITapGestureRecognizer) {
        let label = sender.view as! RoundedLabel
        let wordContainer = label.tagObject as! WordLabelContainer

        self.wordTappedComputer?.wordTapped(wordContainer.originalWord)
    }
    
    func getRowWidth(_ row: [WordLabelContainer]) -> CGFloat {
        var width = CGFloat(0)
        
        for wordContainer in row {
            width += wordContainer.getWidth() + wordContainer.labelHorizontalMargin
        }
        
        return width
    }
    
    var maxWidth = CGFloat(0)
    
    func getMaxWidth() -> CGFloat {
        if (maxWidth == 0) {
            maxWidth = self.bounds.width - CGFloat(16)
        }
        
        return maxWidth
    }
    
    func updateMaxWidth(_ width: CGFloat? = nil) {
        maxWidth = width ?? self.bounds.width
    }

    func highlightWord(_ word: Word) {
        rows.clearHighlight()

        //highlight first word
        for wordContainer in rows.getAllWordContainers() {
            if (wordContainer.originalWord == word || wordContainer.word == word) {
                wordContainer.highlight()
                break
            }
        }
    }

    private func calculateRowHeight() {
        let screenHeight = bounds.height
        let originalRowHeight = self.rowHeight

        if let customRowHeight = customRowHeight {
            self.rowHeight = customRowHeight
        } else {
            let rowsCount = Int(screenHeight / self.rowHeight)

            if (rowsCount > MAX_ROWS_ON_SCREEN) {
                self.rowHeight = min(screenHeight / CGFloat(MAX_ROWS_ON_SCREEN), MAX_ROW_HEIGHT)
            }
        }

        let rowScale = self.rowHeight / originalRowHeight
        self.fontSize *= rowScale
    }
}
