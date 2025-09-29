import SwiftUI

struct GamePlayView: View {
    
    @ObservedObject var gameState: GameState
    @State var showPopup = false
    
    @State private var ballPosition: CGPoint = CGPoint(x: 200, y: 600)
    @State private var vx: CGFloat = 0
    @State private var vy: CGFloat = 0
    @State private var isFlying = false
    
    let gravity: CGFloat = 0.4
    let initialSpeed: CGFloat = 30  // Збільшуємо швидкість
    
    var body: some View {
        ZStack {
            
            Image(gameState.selectedWorld.backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .blur(radius: 2)
            
            
            VStack {
                Spacer()
                
                
                ZStack {
                    Image("score_header_frame") // верхне меню
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
                .padding(.top, 50)  // верхне меню
                
                
                
                VStack {   // border
                    
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
                    
                }   // border
                
                
                
                Image(gameState.selectedSkin.backgroundImageName) // кулька
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .position(ballPosition)
                
              
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
                            if !isFlying {
                                fire()
                            }
                        }
                    
                }
                .padding(.bottom, -50)
                
                
                
                
                
                ZStack {          // нижнье меню
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
            .navigationBarHidden(true)
            .onAppear {
                gameState.startGameTimer()
            }
            .onDisappear {
                gameState.stopGameTimer()
            }
        }
    }
    
    func fire() {
        // Початкова позиція кульки (з позиції гармати)
        ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2 + gameState.cannonPosition, 
                               y: UIScreen.main.bounds.height - 150)
        
        let angleDegrees = Double.random(in: 80...100)
        let angleRadians = angleDegrees * .pi / 180
        
        vx = initialSpeed * cos(angleRadians)
        vy = -initialSpeed * sin(angleRadians)
        
        isFlying = true
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            vy += gravity
            ballPosition.x += vx
            ballPosition.y += vy
            
            // Перевіряємо, чи кулька потрапила за межі екрана
            if ballPosition.y >= UIScreen.main.bounds.height ||
                ballPosition.x < -200 ||
                ballPosition.x > UIScreen.main.bounds.width + 200 {
                
                isFlying = false
                timer.invalidate()
                
                // Чекаємо 2 секунди і повертаємо кульку на стартову позицію
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2 + gameState.cannonPosition, 
                                           y: UIScreen.main.bounds.height - 150)
                }
            }
        }
    }
}
