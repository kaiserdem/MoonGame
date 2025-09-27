
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
        self.selectedWorldId = savedSelected == 0 ? 1 : savedSelected
        
        // Ініціалізація індексу світу
        let savedIndex = UserDefaults.standard.integer(forKey: "currentWorldIndex")
        self.currentWorldIndex = savedIndex == 0 ? 0 : savedIndex
        
        self.totalScore = UserDefaults.standard.integer(forKey: "totalScore") == 0 ? 5000 : UserDefaults.standard.integer(forKey: "totalScore")
        
        // Завантажуємо збережені світи після ініціалізації всіх властивостей
        loadSavedWorlds()
        
        // Оновлюємо вибраний світ після завантаження
        if selectedWorldId == 1 {
            self.selectedWorldId = WorldModel.sampleWorlds.first { $0.isUnlocked }?.id ?? 1
        }
        
        // Оновлюємо індекс світу після завантаження
        if currentWorldIndex == 0 {
            self.currentWorldIndex = WorldModel.sampleWorlds.firstIndex { $0.isUnlocked } ?? 0
        }
       
        setupAudio()
    }
    
    // Завантаження збережених світів
    private func loadSavedWorlds() {
        print("Завантаження збережених світів: \(purchasedWorlds)")
        
        for (index, world) in WorldModel.sampleWorlds.enumerated() {
            if purchasedWorlds.contains(world.id) {
                print("Розблоковуємо світ: \(world.name) (ID: \(world.id))")
                // Оновлюємо світ як розблокований
                WorldModel.sampleWorlds[index] = WorldModel(
                    id: world.id,
                    name: world.name,
                    isUnlocked: true,
                    unlockedImageName: world.unlockedImageName,
                    lockedImageName: world.lockedImageName,
                    backgroundImageName: world.backgroundImageName
                )
            }
        }
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
        
        print("Розблоковуємо світ: \(currentWorld.name) (ID: \(worldId))")
        
        // Додаємо світ до куплених
        purchasedWorlds.insert(worldId)
        print("Додано до куплених: \(purchasedWorlds)")
        
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
            print("Оновлено модель світу: \(WorldModel.sampleWorlds[index].name)")
        }
        
        // Робимо цей світ вибраним (видаляємо попередній вибір)
        selectedWorldId = worldId
        print("Вибрано світ: \(selectedWorldId)")
        
        // Тригеримо оновлення UI
        worldsUpdated.toggle()
    }
}
