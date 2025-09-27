
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
    
    init() {
        self.isSoundOn = UserDefaults.standard.object(forKey: "isSoundOn") as? Bool ?? true
       
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
}
