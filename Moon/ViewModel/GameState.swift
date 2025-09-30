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
    @Published var currentWorldIndex: Int {
        didSet {
            UserDefaults.standard.set(currentWorldIndex, forKey: "currentWorldIndex")
            UserDefaults.standard.synchronize()
        }
    }
    @Published var totalScore: Int {
        didSet {
            UserDefaults.standard.set(totalScore, forKey: "totalScore")
            UserDefaults.standard.synchronize()
        }
    }
    @Published var worldsUpdated: Bool = false
    @Published var gameTime: Double = 0
    private var gameTimer: Timer?
    @Published var isGamePaused: Bool = false
    @Published var cannonPosition: CGFloat = 0
    private let maxCannonOffset: CGFloat = 120
    @Published var ballPosition: CGPoint = CGPoint(x: 0, y: 0)
    @Published var isBallActive: Bool = false
    @Published var ballVelocity: CGPoint = CGPoint(x: 0, y: 0)
    @Published var purchasedWorlds: Set<Int> {
        didSet {
            UserDefaults.standard.set(Array(purchasedWorlds), forKey: "purchasedWorlds")
            UserDefaults.standard.synchronize()
        }
    }
    @Published var selectedWorldId: Int {
        didSet {
            UserDefaults.standard.set(selectedWorldId, forKey: "selectedWorldId")
            UserDefaults.standard.synchronize()
        }
    }
    @Published var currentSkinIndex: Int {
        didSet {
            UserDefaults.standard.set(currentSkinIndex, forKey: "currentSkinIndex")
            UserDefaults.standard.synchronize()
        }
    }
    @Published var purchasedSkinId: Int {
        didSet {
            UserDefaults.standard.set(purchasedSkinId, forKey: "purchasedSkinId")
            UserDefaults.standard.synchronize()
        }
    }
    @Published var selectedSkinId: Int {
        didSet {
            UserDefaults.standard.set(selectedSkinId, forKey: "selectedSkinId")
            UserDefaults.standard.synchronize()
        }
    }
    init() {
        self.isSoundOn = UserDefaults.standard.object(forKey: "isSoundOn") as? Bool ?? true
        let savedPurchasedWorlds = UserDefaults.standard.array(forKey: "purchasedWorlds") as? [Int] ?? []
        self.purchasedWorlds = Set(savedPurchasedWorlds)
        let savedSelected = UserDefaults.standard.integer(forKey: "selectedWorldId")
        self.selectedWorldId = savedSelected == 0 ? 1 : savedSelected
        let savedIndex = UserDefaults.standard.integer(forKey: "currentWorldIndex")
        self.currentWorldIndex = savedIndex == 0 ? 0 : savedIndex
        let savedPurchasedSkin = UserDefaults.standard.integer(forKey: "purchasedSkinId")
        self.purchasedSkinId = savedPurchasedSkin == 0 ? 1 : savedPurchasedSkin
        let savedSelectedSkin = UserDefaults.standard.integer(forKey: "selectedSkinId")
        self.selectedSkinId = savedSelectedSkin == 0 ? 1 : savedSelectedSkin
        let savedSkinIndex = UserDefaults.standard.integer(forKey: "currentSkinIndex")
        self.currentSkinIndex = savedSkinIndex == 0 ? 0 : savedSkinIndex
        self.totalScore = UserDefaults.standard.integer(forKey: "totalScore") == 0 ? 5000 : UserDefaults.standard.integer(forKey: "totalScore")
        loadSavedWorlds()
        loadSavedSkins()
        if selectedWorldId == 1 {
            self.selectedWorldId = WorldModel.sampleWorlds.first { $0.isUnlocked }?.id ?? 1
        }
        if currentWorldIndex == 0 {
            self.currentWorldIndex = WorldModel.sampleWorlds.firstIndex { $0.isUnlocked } ?? 0
        }
        if selectedSkinId == 1 {
            self.selectedSkinId = purchasedSkinId
        }
        self.currentSkinIndex = SkinModel.sampleSkins.firstIndex { $0.id == selectedSkinId } ?? 0
        setupAudio()
    }
    func pause() {
    }
    private func loadSavedWorlds() {
        for (index, world) in WorldModel.sampleWorlds.enumerated() {
            if purchasedWorlds.contains(world.id) {
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
    private func loadSavedSkins() {
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
    func startGameTimer() {
        gameTime = 0
        isGamePaused = false
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            if !self.isGamePaused {
                self.gameTime += 1.0/60.0
                self.updateBallPosition()
            }
        }
    }
    func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
        isGamePaused = false
    }
    func resetGameTimer() {
        gameTime = 0
        isGamePaused = false
    }
    func pauseGame() {
        isGamePaused = true
    }
    func resumeGame() {
        isGamePaused = false
    }
    func moveCannonLeft() {
        if cannonPosition > -maxCannonOffset {
            cannonPosition -= 20
        }
    }
    func moveCannonRight() {
        if cannonPosition < maxCannonOffset {
            cannonPosition += 20
        }
    }
    func resetCannonPosition() {
        cannonPosition = 0
    }
    func shootBall() {
        if !isBallActive {
            ballPosition = CGPoint(x: cannonPosition, y: 50)
            let angleDegrees = Double.random(in: 80...100)
            let angleRadians = angleDegrees * .pi / 180
            let initialSpeed: Double = 15
            ballVelocity = CGPoint(
                x: initialSpeed * cos(angleRadians),  
                y: -initialSpeed * sin(angleRadians)  
            )
            isBallActive = true
        }
    }
    func updateBallPosition() {
        if isBallActive {
            ballVelocity.y += 0.5
            ballPosition.x += ballVelocity.x
            ballPosition.y += ballVelocity.y
            if ballPosition.x < -120 || ballPosition.x > 120 {
                ballVelocity.x = -ballVelocity.x * 0.8  
                ballPosition.x = ballPosition.x < -120 ? -120 : 120  
            }
            if ballPosition.y > 400 {
                ballVelocity.y = -ballVelocity.y * 0.8  
                ballPosition.y = 400  
            }
            if ballPosition.y < 0 {
                isBallActive = false
            }
        }
    }
    func resetBall() {
        isBallActive = false
        ballPosition = CGPoint(x: 0, y: 0)
        ballVelocity = CGPoint(x: 0, y: 0)
    }
    var formattedGameTime: String {
        let minutes = Int(gameTime) / 60
        let seconds = Int(gameTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    var currentWorld: WorldModel {
        WorldModel.sampleWorlds[currentWorldIndex]
    }
    var selectedWorld: WorldModel {
        WorldModel.sampleWorlds.first { $0.id == selectedWorldId } ?? WorldModel.sampleWorlds[0]
    }
    var currentSkin: SkinModel {
        SkinModel.sampleSkins[currentSkinIndex]
    }
    var selectedSkin: SkinModel {
        SkinModel.sampleSkins.first { $0.id == selectedSkinId } ?? SkinModel.sampleSkins[0]
    }
    var isCurrentIndexSaved: Bool {
        let savedIndex = UserDefaults.standard.integer(forKey: "currentWorldIndex")
        return currentWorldIndex == savedIndex
    }
    var currentLevelPrice: Int {
        return 400 + (currentWorldIndex * 200)
    }
    var currentSkinPrice: Int {
        return 300 + (currentSkinIndex * 150)
    }
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
    func updateCurrentSkinIndex() {
        currentSkinIndex = SkinModel.sampleSkins.firstIndex { $0.id == selectedSkinId } ?? 0
    }
    func saveCurrentWorldIndex() {
        UserDefaults.standard.set(currentWorldIndex, forKey: "currentWorldIndex")
        UserDefaults.standard.synchronize()
    }
    func addScore(_ points: Int) {
        totalScore += points
    }
    func setScore(_ score: Int) {
        totalScore = score
    }
    func canAfford(_ price: Int) -> Bool {
        return totalScore >= price
    }
    func buyLevel() -> Bool {
        if canAfford(currentLevelPrice) {
            totalScore -= currentLevelPrice
            unlockCurrentWorld()
            return true
        }
        return false
    }
    func buySkin() -> Bool {
        if canAfford(currentSkinPrice) {
            totalScore -= currentSkinPrice
            unlockCurrentSkin()
            return true
        }
        return false
    }
    func isWorldPurchased(_ worldId: Int) -> Bool {
        return purchasedWorlds.contains(worldId)
    }
    func isWorldSelected(_ worldId: Int) -> Bool {
        return selectedWorldId == worldId
    }
    func selectWorld(_ worldId: Int) {
        if isWorldPurchased(worldId) {
            selectedWorldId = worldId
        }
    }
    func isSkinPurchased(_ skinId: Int) -> Bool {
        return skinId == purchasedSkinId
    }
    func isSkinSelected(_ skinId: Int) -> Bool {
        return selectedSkinId == skinId
    }
    func selectSkin(_ skinId: Int) {
        if isSkinPurchased(skinId) {
            selectedSkinId = skinId
        }
    }
    private func unlockCurrentWorld() {
        let worldId = currentWorld.id
        purchasedWorlds.insert(worldId)
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
        selectedWorldId = worldId
        worldsUpdated.toggle()
    }
    private func unlockCurrentSkin() {
        let skinId = currentSkin.id
        purchasedSkinId = skinId
        selectedSkinId = skinId
        worldsUpdated.toggle()
    }
}
