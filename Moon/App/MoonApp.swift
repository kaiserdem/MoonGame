//
//  MoonApp.swift
//  Moon
//
//  Created by Yaroslav Golinskiy on 26/09/2025.
//

import SwiftUI

@main
struct MoonApp: App {
    
    @StateObject private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            MenuView(gameState: gameState)
            //TestGamePlayView(gameState: gameState)
        }
    }
}
