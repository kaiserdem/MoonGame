//
//  DailyView.swift
//  Moon
//
//  Created by Yaroslav Golinskiy on 26/09/2025.
//

import SwiftUI

struct DailyView: View {
    
    @ObservedObject var gameState: GameState
    @State var showPopup = false
    
    var body: some View {
        ZStack {
            Image("26 img")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image("Daily daily header frame")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 120)
                    .offset(y: -10)
                    //.clipped()
                
                
                VStack {
                    
                    Spacer()
                    
                    Button(action: {
                        showPopup.toggle()
                    }) {
                        Image("Play_Button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                    }
                    
                    
                    
                    Button(action: {
                        
                    }) {
                        Image("Store_Button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                    }
                    
                    Button(action: {
                        
                    }) {
                        Image("Exit_Button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                    }
                    
                    
                    Spacer()
                    
                }
                
                
                Spacer()
                
                ZStack {
                    Image("Menu_Footer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        //.clipped()
                    
                    HStack {
                        Button(action: {
                            gameState.toggleSound()
                        }) {
                            Image("top button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                        
                        
                        Button(action: {
                            gameState.toggleSound()
                        }) {
                            Image("question_top_button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                        
                        
                        Button(action: {
                            gameState.toggleSound()
                        }) {
                            Image(gameState.isSoundOn ? "sound button=normal" : "Sound_off=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                        
                        
                    }
                    .padding(.top, 20)
                    
                }
            }
            
            PopupView(isPresented: $showPopup) {
               
            }
        }
    }
}
