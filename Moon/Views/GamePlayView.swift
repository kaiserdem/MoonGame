

import SwiftUI

struct GamePlayView: View {
    
    @ObservedObject var gameState: GameState
    @State var showPopup = false
    
    
    var body: some View {
        ZStack {
            Image(gameState.selectedWorld.backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .blur(radius: 2)

            
            
            VStack(spacing: 0) {
               
                Spacer()
                
                ZStack {
                    Image("score_header_frame") // bgr curren user moneu
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 20) {
                        
                        
                        Text(gameState.formattedGameTime)
                            .font(AppFonts.title)
                            .foregroundColor(.white)
                            .offset(x: 20)
                        
                        Spacer()
                        Spacer()
                        
                        HStack {
                            Text("\(gameState.totalScore)")
                                .font(AppFonts.title)
                                .foregroundColor(.white)
                            
                            Image("Сurrency - Сoin")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                        
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 50)
                
                Spacer()
                
                VStack {// border
                    
                    Spacer()
                    Spacer()
                    
                    HStack {
                        
                        Image("Bounce_Barrier_01")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 90)
                            .offset(x: -6)
                        
                        
                        Spacer()
                        Spacer()
                        
                        
                        Image("Bounce_Barrier_02")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 90)
                            .offset(x: 6)
                        
                        
                    }
                    
                    Spacer()
                    Spacer()
                    
                    HStack {
                        
                        Image("Bounce_Barrier_01")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 90)
                            .offset(x: -6)
                        
                        
                        Spacer()
                        Spacer()
                        
                        
                        Image("Bounce_Barrier_02")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 90)
                            .offset(x: 6)
                        
                        
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
                Spacer()
                
                ZStack {
                    HStack {
                        
                        Button(action: {
                            gameState.moveCannonLeft()
                        }) {
                            Image("Property 1=normal") // left arrow
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                        
                        
                        Spacer()
                        Spacer()
                        
                        Button(action: {
                            gameState.moveCannonRight()
                        }) {
                            Image("Right__bottom_button=normal-2") // right arrow
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                    }
                    
                    
                    Image("barrell 2") // PUSHKA
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .padding(.bottom, 10)
                        .offset(x: gameState.cannonPosition)
                        .onTapGesture {
                            
                        }
                    
                }
                .padding(.bottom, -50)
                
                ZStack {
                    Image("Menu_Footer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .offset(y: 20)
                        //.clipped()
                    
                    HStack {
                        Button(action: {
                            gameState.pauseGame()
                            showPopup = true
                        }) {
                            Image("play bottom button=normal")
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
                            Image("top button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                        
                        
                    }
                    .padding(.top, 50)
                    
                }
            }
            
            PopupView(isPresented: $showPopup, state: .pause, gameState: gameState) {
               
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            gameState.startGameTimer()
        }
        .onDisappear {
            gameState.stopGameTimer()
        }
    }
}
