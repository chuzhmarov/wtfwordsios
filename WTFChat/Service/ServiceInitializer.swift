//
// Created by Artem Chuzhmarov on 30/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let serviceLocator = ServiceLocator()

class ServiceInitializer {
    //private static let BASE_URL = "https://127.0.0.1:5000/"
    private static let BASE_URL = "https://dev.wtfchat.wtf:42043/"

    static func initServices() {
        //network
        let networkService = NetworkService(baseUrl: BASE_URL)
        let authNetworkService = AuthNetworkService(networkService: networkService)
        let messageNetworkService = MessageNetworkService(networkService: networkService)
        let userNetworkService = UserNetworkService(networkService: networkService)
        let talkNetworkService = TalkNetworkService(networkService: networkService)
        let inAppNetworkService = InAppNetworkService(networkService: networkService)
        let iosNetworkService = IosNetworkService(networkService: networkService)

        let iosService = IosService(iosNetworkService: iosNetworkService)
        let expService = ExpService()

        let currentUserService = CurrentUserService(iosService: iosService, expService: expService)

        //core
        let coreDataService = CoreDataService()
        let coreMessageService = CoreMessageService(coreDataService: coreDataService)
        let coreSingleModeCategoryService = CoreSingleModeCategoryService(coreDataService: coreDataService)
        //let coreSingleMessageService = CoreSingleMessageService(coreDataService: coreDataService)
        let coreLevelService = CoreLevelService(coreDataService: coreDataService)

        //TODO - AWFUL DEPENDENCY
        let talkService = TalkService(
            talkNetworkService: talkNetworkService,
            iosService: iosService,
            currentUserService: currentUserService,
            coreMessageService: coreMessageService
        )
        let messageService = MessageService(
            messageNetworkService: messageNetworkService,
            talkService: talkService,
            coreMessageService: coreMessageService
        )
        talkService.messageService = messageService

        let windowService = WindowService(
            talkService: talkService,
            currentUserService: currentUserService
        )

        let userService = UserService(
            userNetworkService: userNetworkService,
            iosService: iosService,
            talkService: talkService,
            currentUserService: currentUserService,
            windowService: windowService
        )

        let inAppHelper = InAppHelper(
            inAppNetworkService: inAppNetworkService,
            currentUserService: currentUserService,
            userService: userService,
            productIdentifiers: IAPProducts.ALL
        )

        //network
        serviceLocator.add(
            InAppService(
                inAppHelper: inAppHelper,
                currentUserService: currentUserService
            ),
            iosService,
            userService,
            messageService,
            talkService,
            AuthService(
                authNetworkService: authNetworkService,
                iosService: iosService,
                userService: userService
            )
        )

        //core data
        serviceLocator.add(
            coreDataService,
            coreMessageService,
            coreSingleModeCategoryService,
            coreLevelService
        )

        let cipherService = CipherService()
        let textGeneratorService = TextGeneratorService()
        let messageCipherService = MessageCipherService(
            currentUserService: currentUserService,
            cipherService: cipherService
        )

        let singleModeCategoryService = SingleModeCategoryService(
            coreSingleModeCategoryService: coreSingleModeCategoryService,
            coreLevelService: coreLevelService
        )

        let levelService = LevelService(
            coreLevelService: coreLevelService
        )

        let singleMessageService = SingleMessageService(
            textGeneratorService: textGeneratorService,
            messageCipherService: messageCipherService
        )

        //core based
        serviceLocator.add(
            singleModeCategoryService
        )

        serviceLocator.add(
            SingleModeService(
                singleModeCategoryService: singleModeCategoryService,
                expService: expService,
                currentUserService: currentUserService,
                levelService: levelService
            ),
            singleMessageService
        )

        //other
        serviceLocator.add(
            expService,
            messageCipherService,
            windowService,
            NotificationService(
                windowService: windowService,
                messageService: messageService,
                talkService: talkService
            ),
            currentUserService,
            AdColonyService(),
            AvatarService(),
            TimeService(),
            AudioService(),
            cipherService,
                    textGeneratorService
        )
    }
}
