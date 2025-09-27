
import SwiftUI

struct SkinModel: Identifiable, Codable {
    let id: Int
    let unlockedImageName: String
    let lockedImageName: String
    let backgroundImageName: String
    
    init(id: Int, unlockedImageName: String, lockedImageName: String, backgroundImageName: String) {
        self.id = id
        self.unlockedImageName = unlockedImageName
        self.lockedImageName = lockedImageName
        self.backgroundImageName = backgroundImageName
    }
}

// Приклад використання:
extension WorldModel {
    static var sampleWorlds: [WorldModel] = [
        WorldModel(
            id: 1,
            unlockedImageName: "daily 15unlok",
            lockedImageName: "idaily 15",
            backgroundImageName: "Yplayer_skin_01"
        ),
        WorldModel(
            id: 2,
            unlockedImageName: "daily 14unlok",
            lockedImageName: "daily 14",
            backgroundImageName: "player_skin_02"
        ),
        WorldModel(
            id: 3,
            unlockedImageName: "daily 13unlok",
            lockedImageName: "daily 13",
            backgroundImageName: "player_skin_03"
        ),
        WorldModel(
            id: 4,
            unlockedImageName: "daily 17unlok",
            lockedImageName: "daily 17",
            backgroundImageName: "player_skin_04"
        ),
        WorldModel(
            id: 5,
            unlockedImageName: "daily 16unlok",
            lockedImageName: "daily 16",
            backgroundImageName: "player_skin_05"
        )
    ]
}
