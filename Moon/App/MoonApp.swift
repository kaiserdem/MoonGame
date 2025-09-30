import SwiftUI
@main
struct MoonApp: App {
    @StateObject private var gameState = GameState()
    var body: some Scene {
        WindowGroup {
            MenuView(gameState: gameState)
        }
    }
}
