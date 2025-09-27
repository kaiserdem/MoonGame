
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
    
    init() {
        self.isSoundOn = UserDefaults.standard.object(forKey: "isSoundOn") as? Bool ?? true
        self.currentWorldIndex = UserDefaults.standard.integer(forKey: "currentWorldIndex") == 0 ? 0 : UserDefaults.standard.integer(forKey: "currentWorldIndex")
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
            return true
        }
        return false
    }
}
