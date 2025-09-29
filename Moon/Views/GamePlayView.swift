import SwiftUI

struct GamePlayView: View {
    
    @ObservedObject var gameState: GameState
    @State var showPopup = false
    
    @State private var ballPosition: CGPoint = CGPoint(x: 200, y: 600)
    @State private var ballOffset: CGPoint = CGPoint(x: 0, y: 0)
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
                    .offset(x: ballOffset.x, y: ballOffset.y)
                
              
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
                            print("Tap detected! isFlying: \(isFlying)")
                            if !isFlying {
                                print("Firing ball!")
                                fire()
                            } else {
                                print("Ball is already flying")
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
        print("Fire function called")
        // Початкова позиція кульки (з позиції гармати)
        ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2 + gameState.cannonPosition, 
                               y: UIScreen.main.bounds.height - 150)
        
        // Початковий offset для відображення
        ballOffset = CGPoint(x: gameState.cannonPosition, y: -100)
        
        let angleDegrees = Double.random(in: 80...100)
        let angleRadians = angleDegrees * .pi / 180
        
        vx = initialSpeed * cos(angleRadians)
        vy = -initialSpeed * sin(angleRadians)
        
        print("Ball position: \(ballPosition), vx: \(vx), vy: \(vy)")
        isFlying = true
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            // Застосовуємо гравітацію до швидкості
            vy += gravity
            
            // Оновлюємо позицію кульки
            ballPosition.x += vx
            ballPosition.y += vy
            
            // Оновлюємо offset для відображення (тільки для UI)
            ballOffset.x = ballPosition.x - UIScreen.main.bounds.width / 2
            ballOffset.y = UIScreen.main.bounds.height - ballPosition.y - 100
            
            // Логування руху кульки (кожні 30 кадрів)
            if Int(ballPosition.x) % 30 == 0 {
                print("Ball moving: x=\(ballPosition.x), y=\(ballPosition.y), vx=\(vx), vy=\(vy)")
                print("Ball offset: x=\(ballOffset.x), y=\(ballOffset.y)")
            }
            
            // Відбиття від бордерів
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            // Відбиття від бокових бордерів (приблизно на 1/4 та 3/4 ширини екрана)
            let leftBarrier = screenWidth * 0.25
            let rightBarrier = screenWidth * 0.75
            
            if ballPosition.x <= leftBarrier + 30 && ballPosition.x >= leftBarrier - 30 {
                vx = -vx * 0.8  // відбиття з втратою енергії
                ballPosition.x = leftBarrier + 30
            }
            
            if ballPosition.x >= rightBarrier - 30 && ballPosition.x <= rightBarrier + 30 {
                vx = -vx * 0.8  // відбиття з втратою енергії
                ballPosition.x = rightBarrier - 30
            }
            
            // Відбиття від верхніх бордерів (приблизно на 1/3 та 2/3 висоти екрана)
            let topBarrier1 = screenHeight * 0.3
            let topBarrier2 = screenHeight * 0.6
            
            if ballPosition.y <= topBarrier1 + 45 && ballPosition.y >= topBarrier1 - 45 {
                vy = -vy * 0.8  // відбиття з втратою енергії
                ballPosition.y = topBarrier1 + 45
            }
            
            if ballPosition.y <= topBarrier2 + 45 && ballPosition.y >= topBarrier2 - 45 {
                vy = -vy * 0.8  // відбиття з втратою енергії
                ballPosition.y = topBarrier2 + 45
            }
            
            // Перевіряємо, чи кулька потрапила за межі екрана
            if ballPosition.y >= UIScreen.main.bounds.height ||
                ballPosition.x < -200 ||
                ballPosition.x > UIScreen.main.bounds.width + 200 {
                
                isFlying = false
                timer.invalidate()
                
                // Чекаємо 2 секунди і повертаємо кульку на стартову позицію
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    print("Resetting ball position")
                    ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2 + gameState.cannonPosition, 
                                           y: UIScreen.main.bounds.height - 150)
                    ballOffset = CGPoint(x: gameState.cannonPosition, y: -100)
                    isFlying = false  // Скидаємо стан польоту
                }
            }
        }
    }
}
