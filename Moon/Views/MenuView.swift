//
//  DailyView.swift
//  Moon
//
//  Created by Yaroslav Golinskiy on 26/09/2025.
//

import SwiftUI

struct MenuView: View {
    
    @ObservedObject var gameState: GameState
    @State var showPopup = false
    
    var body: some View {
        NavigationView {
            ZStack {
            Image("26 img")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
               
                
                
                VStack {
                    
                    Spacer()
                    
                    Image("Daily draw header frame")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .offset(y: -10)
                    
                    
                    
                    
                    NavigationLink(destination: PlayView(gameState: gameState)) {
                        Image("Play_Button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
        
                    
                    
                    
                    
                    NavigationLink(destination: StoreView(gameState: gameState)) {
                        Image("Store_Button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                }
                
                
                Spacer()
                
                ZStack {
                    Image("Menu_Footer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .offset(y: 20)
                        //.clipped()
                    
                    HStack {
                        NavigationLink(destination: InfoView()) {
                            Image("top button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 80)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        
                        NavigationLink(destination: RulesView()) {
                            Image("question_top_button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 80)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            gameState.toggleSound()
                        }) {
                            Image(gameState.isSoundOn ? "sound button=normal" : "Sound_off=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                        
                        
                    }
                    .padding(.top, 50)
                    
                }
            }
            
            PopupView(isPresented: $showPopup, state: .win) {
               
            }
        }
        }
    }
}
