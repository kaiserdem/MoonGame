
import SwiftUI
import Combine
import AVFoundation

class GameState: ObservableObject {
   
    private var audioPlayer: AVAudioPlayer?

    @Published var isSoundOn: Bool {
        didSet {
            UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Поточний індекс світу
    @Published var currentWorldIndex: Int {
        didSet {
            UserDefaults.standard.set(currentWorldIndex, forKey: "currentWorldIndex")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Загальна кількість балів
    @Published var totalScore: Int {
        didSet {
            UserDefaults.standard.set(totalScore, forKey: "totalScore")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Тригер для оновлення UI
    @Published var worldsUpdated: Bool = false
    
    // Список куплених світів
    @Published var purchasedWorlds: Set<Int> {
        didSet {
            UserDefaults.standard.set(Array(purchasedWorlds), forKey: "purchasedWorlds")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Вибраний світ
    @Published var selectedWorldId: Int {
        didSet {
            UserDefaults.standard.set(selectedWorldId, forKey: "selectedWorldId")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        self.isSoundOn = UserDefaults.standard.object(forKey: "isSoundOn") as? Bool ?? true
        
        // Ініціалізація куплених світів
        let savedPurchased = UserDefaults.standard.array(forKey: "purchasedWorlds") as? [Int] ?? []
        self.purchasedWorlds = Set(savedPurchased)
        
        // Ініціалізація вибраного світу
        let savedSelected = UserDefaults.standard.integer(forKey: "selectedWorldId")
        if savedSelected == 0 {
            // Якщо нічого не збережено, вибираємо перший розблокований рівень
            self.selectedWorldId = WorldModel.sampleWorlds.first { $0.isUnlocked }?.id ?? 1
        } else {
            self.selectedWorldId = savedSelected
        }
        
        // Ініціалізація індексу світу
        let savedIndex = UserDefaults.standard.integer(forKey: "currentWorldIndex")
        if savedIndex == 0 {
            // Якщо нічого не збережено, показуємо перший розблокований рівень
            self.currentWorldIndex = WorldModel.sampleWorlds.firstIndex { $0.isUnlocked } ?? 0
        } else {
            self.currentWorldIndex = savedIndex
        }
        
        self.totalScore = UserDefaults.standard.integer(forKey: "totalScore") == 0 ? 5000 : UserDefaults.standard.integer(forKey: "totalScore")
       
        setupAudio()
    }
    
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "cf0fc01247f4fc1", withExtension: "mp3") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0.5
        } catch {
        }
    }
    
    func toggleSound() {
        isSoundOn.toggle()
        
        if isSoundOn {
            audioPlayer?.play()
        } else {
            audioPlayer?.pause()
        }
    }
    
    func startMusic() {
        if isSoundOn {
            audioPlayer?.play()
        }
    }
    
    func stopMusic() {
        audioPlayer?.pause()
    }
    
    // MARK: - World Management
    
    // Поточний світ
    var currentWorld: WorldModel {
        WorldModel.sampleWorlds[currentWorldIndex]
    }
    
    // Перевірка чи поточний індекс збігається з збереженим
    var isCurrentIndexSaved: Bool {
        let savedIndex = UserDefaults.standard.integer(forKey: "currentWorldIndex")
        return currentWorldIndex == savedIndex
    }
    
    // Ціна поточного рівня
    var currentLevelPrice: Int {
        return 400 + (currentWorldIndex * 200)
    }
    
    // Функції перемикання світів
    func goToPreviousWorld() {
        if currentWorldIndex > 0 {
            currentWorldIndex -= 1
        }
    }
    
    func goToNextWorld() {
        if currentWorldIndex < WorldModel.sampleWorlds.count - 1 {
            currentWorldIndex += 1
        }
    }
    
    // Збереження поточного індексу
    func saveCurrentWorldIndex() {
        UserDefaults.standard.set(currentWorldIndex, forKey: "currentWorldIndex")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Score Management
    
    // Додавання балів до загальної суми
    func addScore(_ points: Int) {
        totalScore += points
    }
    
    // Встановлення конкретної суми балів
    func setScore(_ score: Int) {
        totalScore = score
    }
    
    // Перевірка чи достатньо балів для покупки
    func canAfford(_ price: Int) -> Bool {
        return totalScore >= price
    }
    
    // Покупка рівня
    func buyLevel() -> Bool {
        if canAfford(currentLevelPrice) {
            totalScore -= currentLevelPrice
            unlockCurrentWorld()
            return true
        }
        return false
    }
    
    // Перевірка чи світ куплений
    func isWorldPurchased(_ worldId: Int) -> Bool {
        return purchasedWorlds.contains(worldId)
    }
    
    // Перевірка чи світ вибраний
    func isWorldSelected(_ worldId: Int) -> Bool {
        return selectedWorldId == worldId
    }
    
    // Вибір світу
    func selectWorld(_ worldId: Int) {
        if isWorldPurchased(worldId) {
            selectedWorldId = worldId
        }
    }
    
    // Розблокування поточного світу
    private func unlockCurrentWorld() {
        let worldId = currentWorld.id
        
        // Додаємо світ до куплених
        purchasedWorlds.insert(worldId)
        
        // Оновлюємо модель світу
        if let index = WorldModel.sampleWorlds.firstIndex(where: { $0.id == worldId }) {
            WorldModel.sampleWorlds[index] = WorldModel(
                id: worldId,
                name: currentWorld.name,
                isUnlocked: true,
                unlockedImageName: currentWorld.unlockedImageName,
                lockedImageName: currentWorld.lockedImageName,
                backgroundImageName: currentWorld.backgroundImageName
            )
        }
        
        // Робимо цей світ вибраним (видаляємо попередній вибір)
        selectedWorldId = worldId
        
        // Тригеримо оновлення UI
        worldsUpdated.toggle()
    }
}
