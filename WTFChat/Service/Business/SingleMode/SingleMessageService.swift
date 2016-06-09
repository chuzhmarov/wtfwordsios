import Foundation

class SingleMessageService: Service {
    private let coreSingleMessageService: CoreSingleMessageService
    private let challengeMessageService: ChallengeMessageService
    private let messageCipherService: MessageCipherService

    init(coreSingleMessageService: CoreSingleMessageService,
         challengeMessageService: ChallengeMessageService,
         messageCipherService: MessageCipherService) {

        self.coreSingleMessageService = coreSingleMessageService
        self.messageCipherService = messageCipherService
        self.challengeMessageService = challengeMessageService
    }

    func generateNewMessageForTalk(singleTalk: SingleTalk) {
        let text = challengeMessageService.getRandomMessage()

        let message = messageCipherService.createMessage(
            text,
            cipherType: singleTalk.cipherType,
            cipherDifficulty: singleTalk.cipherDifficulty
        )

        let singleMessage = SingleMessage(message: message)
        singleMessage.singleTalk = singleTalk

        coreSingleMessageService.createMessage(singleTalk, message: singleMessage)
    }

    func updateMessage(singleMessage: SingleMessage) {
        coreSingleMessageService.updateMessage(singleMessage)
    }
}
