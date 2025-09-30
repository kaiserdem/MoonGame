import SwiftUI
struct WorldModel: Identifiable, Codable {
    let id: Int
    let name: String
    let isUnlocked: Bool
    let unlockedImageName: String
    let lockedImageName: String
    let backgroundImageName: String
    init(id: Int, name: String, isUnlocked: Bool, unlockedImageName: String, lockedImageName: String, backgroundImageName: String) {
        self.id = id
        self.name = name
        self.isUnlocked = isUnlocked
        self.unlockedImageName = unlockedImageName
        self.lockedImageName = lockedImageName
        self.backgroundImageName = backgroundImageName
    }
}
extension WorldModel {
    static var sampleWorlds: [WorldModel] = [
        WorldModel(
            id: 1,
            name: "Льодовий світ",
            isUnlocked: true,
            unlockedImageName: "daily 15unlok",
            lockedImageName: "idaily 15",
            backgroundImageName: "Yellow_world_bg15"
        ),
        WorldModel(
            id: 2,
            name: "Лавовий світ",
            isUnlocked: false,
            unlockedImageName: "daily 14unlok",
            lockedImageName: "daily 14",
            backgroundImageName: "Yellow_world_bg14"
        ),
        WorldModel(
            id: 3,
            name: "Джунглі",
            isUnlocked: false,
            unlockedImageName: "daily 13unlok",
            lockedImageName: "daily 13",
            backgroundImageName: "Yellow_world_bg13"
        ),
        WorldModel(
            id: 4,
            name: "Білий світ",
            isUnlocked: false,
            unlockedImageName: "daily 17unlok",
            lockedImageName: "daily 17",
            backgroundImageName: "Yellow_world_bg17"
        ),
        WorldModel(
            id: 5,
            name: "Жовтий світ",
            isUnlocked: false,
            unlockedImageName: "daily 16unlok",
            lockedImageName: "daily 16",
            backgroundImageName: "Yellow_world_bg16"
        )
    ]
}
