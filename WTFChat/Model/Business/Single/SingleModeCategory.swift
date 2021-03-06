import Foundation

class SingleModeCategory {
    var cipherType: CipherType
    var levels: [Level]

    var hasJustClearedOnEasy = false
    var hasJustClearedOnNormal = false
    var hasJustClearedOnHard = false

    fileprivate var coreSingleModeCategory: CoreSingleModeCategory!

    init(cipherType: CipherType, levels: [Level] = [Level]()) {
        self.cipherType = cipherType
        self.levels = levels
    }

    func appendLevel(_ level: Level) {
        levels.append(level)
        coreSingleModeCategory.addLevelsObject(level.getCoreLevel())
    }

    func setCoreSingleModeCategory(_ coreSingleModeCategory: CoreSingleModeCategory) {
        self.coreSingleModeCategory = coreSingleModeCategory
    }

    func updateCoreSingleModeCategory() {
        self.coreSingleModeCategory.updateFromSingleModeCategoryWithoutLevels(self)
    }

    func getLevelById(_ id: Int) -> Level? {
        if (id < 1 || id > levels.count) {
            return nil
        }

        return levels[id - 1]
    }

    func getLastLevel() -> Level {
        return levels[levels.count - 1]
    }

    func getProgress(_ difficulty: CipherDifficulty) -> Float {
        var completedLevels = 0

        for level in levels {
            if (level.isClearedForDifficulty(difficulty)) {
                completedLevels += 1
            }
        }

        return Float(completedLevels) / Float(levels.count)
    }
}
