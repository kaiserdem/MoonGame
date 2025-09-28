
import SwiftUI

struct SkinModel: Identifiable, Codable {
    let id: Int
    let unlockedImageName: String
    let lockedImageName: String
    let backgroundImageName: String
    
    init(id: Int, unlockedImageName: String, storeImageName: String, backgroundImageName: String) {
        self.id = id
        self.unlockedImageName = unlockedImageName
        self.lockedImageName = storeImageName
        self.backgroundImageName = backgroundImageName
    }
}

// Приклад використання:
extension SkinModel {
    static var sampleSkins: [SkinModel] = [
        SkinModel(
            id: 1,
            unlockedImageName: "daily 15unlok",
            storeImageName: "player skin icon 1",
            backgroundImageName: "player_skin_01"
        ),
        SkinModel(
            id: 2,
            unlockedImageName: "daily 14unlok",
            storeImageName: "player skin icon 2",
            backgroundImageName: "player_skin_02"
        ),
        SkinModel(
            id: 3,
            unlockedImageName: "daily 13unlok",
            storeImageName: "player skin icon 3",
            backgroundImageName: "player_skin_03"
        ),
        SkinModel(
            id: 4,
            unlockedImageName: "daily 17unlok",
            storeImageName: "player skin icon 4",
            backgroundImageName: "player_skin_04"
        ),
        SkinModel(
            id: 5,
            unlockedImageName: "daily 16unlok",
            storeImageName: "player skin icon 5",
            backgroundImageName: "player_skin_05"
        )
    ]
}
