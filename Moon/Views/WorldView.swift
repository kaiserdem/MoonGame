

import SwiftUI

struct WorldView: View {
    
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Image("26 img")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            
                            Image("Pop-up_Text_Frame")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .center, spacing: -10) {
                                
                                
                                Image(gameState.currentWorld.isUnlocked ? gameState.currentWorld.unlockedImageName : gameState.currentWorld.lockedImageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                                
                                
                                ZStack {
                                    Image("button=inactive") // br price
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity, maxHeight: 80)
                                    
                                    HStack(spacing: 150) {
                                        
                                        Button(action: gameState.goToPreviousWorld) {
                                            Image("Property 1=normal")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                        }
                                        .disabled(gameState.currentWorldIndex == 0)
                                        
                                        
                                        
                                        
                                        Button(action: gameState.goToNextWorld) {
                                            Image("Right__bottom_button=normal-2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                        }
                                        .disabled(gameState.currentWorldIndex == WorldModel.sampleWorlds.count - 1)
                                        
                                    }
                                    
                                    HStack(spacing: 10) {
                                        
                                        if gameState.currentWorld.isUnlocked {
                                            
                                                if gameState.isWorldSelected(gameState.currentWorld.id) {
                                                Image("checkmark top button=Default")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 60, height: 60)
                                                    .offset(x: 40)
                                            } else {
                                                
                                                
                                                NavigationLink(destination: GamePlayView(gameState: gameState)) {
                                                    Image("play bottom button=normal")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 60, height: 60)
                                                        .offset(x: 40)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                               
                                            }
                                            
                                            
                                        } else {
                                            Image("Сurrency - Сoin")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        
                                        if gameState.currentWorld.isUnlocked {
                                            Spacer()
                                                .frame(width: 60, height: 60)
                                        } else {
                                                Text("\(gameState.currentLevelPrice)")
                                                    .font(AppFonts.title2)
                                                    .frame(height: 60)
                                                    .foregroundColor(AppColors.Text.brightGreen)
                                                    .onTapGesture {
                                                        if !gameState.currentWorld.isUnlocked {
                                                            let success = gameState.buyLevel()
                                                            if success {
                                                                print("Світ успішно куплено!")
                                                            } else {
                                                                print("Недостатньо балів для покупки")
                                                            }
                                                        }
                                                    }
                                        }
                                    }
                                    .onTapGesture {
                                        print("onTapGesture")
                                    }
                                }
                                .frame(width: 400)
                            }
                        }
                        
                        
                        ZStack {
                            Image("score_header_frame") // bgr curren user moneu
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                            
                            HStack(spacing: 20) {
                                
                                Spacer()
                                Image("Сurrency - Сoin")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                
                                
                                Spacer()
                                Spacer()
                                
                                
                                Text("\(gameState.totalScore)")
                                    .font(AppFonts.title)
                                    .foregroundColor(AppColors.Text.brightGreen)
                                
                                
                                Spacer()
                            }
                        }
                        
                    }
                    
                    ZStack {
                        Image("Menu_Footer")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            .offset(y: 20)
                        
                        HStack {
                            
                            NavigationLink(destination: GamePlayView(gameState: gameState)) {
                                Image("play bottom button=normal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70, height: 70)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            
                            NavigationLink(destination: InfoView()) {
                                Image("top button=normal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 70)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Image("Component 33")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70, height: 70)
                            }
                            
                            
                           
                            
                        }
                        .padding(.top, 50)
                        
                    }
                    
                    
                }
            }
            .navigationBarHidden(true)
            
        }
        .navigationBarHidden(true)
    }
}
