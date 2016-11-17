import Foundation

let serviceLocator = ServiceLocator()

class ServiceInitializer {
    fileprivate static let BASE_URL = Bundle.main.object(forInfoDictionaryKey: "WEB_SERVICE_URL") as! String

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
            productIdentifiers: IAPProducts.ALL
        )

        let inAppService = InAppService(
            inAppHelper: inAppHelper
        )

        //network
        serviceLocator.add(
            inAppService,
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

        let guiDataService = GuiDataService()

        let cipherService = CipherService()
        let textCategoryService = TextCategoryService(guiDataService: guiDataService)
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
            textGeneratorService: textCategoryService,
            messageCipherService: messageCipherService
        )

        //core based
        serviceLocator.add(
            singleModeCategoryService,
            levelService
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
            AdService(),
            AvatarService(),
            TimeService(),
            AudioService(),
            cipherService,
            textCategoryService,
            guiDataService,
            RatingService(guiDataService: guiDataService),
            DailyHintsService(
                inAppService: inAppService,
                currentUserService: currentUserService
            )
        )
    }
}
