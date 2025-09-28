
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
    
    // Поточний індекс скіна
    @Published var currentSkinIndex: Int {
        didSet {
            UserDefaults.standard.set(currentSkinIndex, forKey: "currentSkinIndex")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Вибраний скін (замість множини куплених)
    @Published var purchasedSkinId: Int {
        didSet {
            UserDefaults.standard.set(purchasedSkinId, forKey: "purchasedSkinId")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Вибраний скін
    @Published var selectedSkinId: Int {
        didSet {
            UserDefaults.standard.set(selectedSkinId, forKey: "selectedSkinId")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        self.isSoundOn = UserDefaults.standard.object(forKey: "isSoundOn") as? Bool ?? true
        
        // Ініціалізація куплених світів
        let savedPurchasedWorlds = UserDefaults.standard.array(forKey: "purchasedWorlds") as? [Int] ?? []
        self.purchasedWorlds = Set(savedPurchasedWorlds)
        
        // Ініціалізація вибраного світу
        let savedSelected = UserDefaults.standard.integer(forKey: "selectedWorldId")
        self.selectedWorldId = savedSelected == 0 ? 1 : savedSelected
        
        // Ініціалізація індексу світу
        let savedIndex = UserDefaults.standard.integer(forKey: "currentWorldIndex")
        self.currentWorldIndex = savedIndex == 0 ? 0 : savedIndex
        
        // Ініціалізація купленого скіна
        let savedPurchasedSkin = UserDefaults.standard.integer(forKey: "purchasedSkinId")
        self.purchasedSkinId = savedPurchasedSkin == 0 ? 1 : savedPurchasedSkin
        
        // Ініціалізація вибраного скіна
        let savedSelectedSkin = UserDefaults.standard.integer(forKey: "selectedSkinId")
        self.selectedSkinId = savedSelectedSkin == 0 ? 1 : savedSelectedSkin
        
        // Ініціалізація індексу скіна
        let savedSkinIndex = UserDefaults.standard.integer(forKey: "currentSkinIndex")
        self.currentSkinIndex = savedSkinIndex == 0 ? 0 : savedSkinIndex
        
        self.totalScore = UserDefaults.standard.integer(forKey: "totalScore") == 0 ? 5000 : UserDefaults.standard.integer(forKey: "totalScore")
        
        // Завантажуємо збережені світи після ініціалізації всіх властивостей
        loadSavedWorlds()
        loadSavedSkins()
        
        // Оновлюємо вибраний світ після завантаження
        if selectedWorldId == 1 {
            self.selectedWorldId = WorldModel.sampleWorlds.first { $0.isUnlocked }?.id ?? 1
        }
        
        // Оновлюємо індекс світу після завантаження
        if currentWorldIndex == 0 {
            self.currentWorldIndex = WorldModel.sampleWorlds.firstIndex { $0.isUnlocked } ?? 0
        }
        
        // Оновлюємо вибраний скін після завантаження
        if selectedSkinId == 1 {
            self.selectedSkinId = purchasedSkinId
        }
        
        // Оновлюємо індекс скіна після завантаження
        if currentSkinIndex == 0 {
            self.currentSkinIndex = SkinModel.sampleSkins.firstIndex { $0.id == purchasedSkinId } ?? 0
        }
       
        setupAudio()
    }
    
    func pause() {
        
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
    
    // Завантаження збережених скінів
    private func loadSavedSkins() {
        print("Завантаження збереженого скіна: \(purchasedSkinId)")
        
        // Перший скін завжди розблокований
        if purchasedSkinId == 0 {
            purchasedSkinId = 1
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
    
    // Поточний скін
    var currentSkin: SkinModel {
        SkinModel.sampleSkins[currentSkinIndex]
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
    
    // Ціна поточного скіна
    var currentSkinPrice: Int {
        return 300 + (currentSkinIndex * 150)
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
    
    // Функції перемикання скінів
    func goToPreviousSkin() {
        if currentSkinIndex > 0 {
            currentSkinIndex -= 1
        }
    }
    
    func goToNextSkin() {
        if currentSkinIndex < SkinModel.sampleSkins.count - 1 {
            currentSkinIndex += 1
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
    
    // Покупка скіна
    func buySkin() -> Bool {
        if canAfford(currentSkinPrice) {
            totalScore -= currentSkinPrice
            unlockCurrentSkin()
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
    
    // Перевірка чи скін куплений
    func isSkinPurchased(_ skinId: Int) -> Bool {
        return skinId == purchasedSkinId
    }
    
    // Перевірка чи скін вибраний
    func isSkinSelected(_ skinId: Int) -> Bool {
        return selectedSkinId == skinId
    }
    
    // Вибір скіна
    func selectSkin(_ skinId: Int) {
        if isSkinPurchased(skinId) {
            selectedSkinId = skinId
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
    
    // Розблокування поточного скіна
    private func unlockCurrentSkin() {
        let skinId = currentSkin.id
        
        print("Розблоковуємо скін: \(skinId)")
        
        // Замінюємо старий скін на новий
        purchasedSkinId = skinId
        print("Встановлено куплений скін: \(purchasedSkinId)")
        
        // Робимо цей скін вибраним
        selectedSkinId = skinId
        print("Вибрано скін: \(selectedSkinId)")
        
        // Тригеримо оновлення UI
        worldsUpdated.toggle()
    }
}
