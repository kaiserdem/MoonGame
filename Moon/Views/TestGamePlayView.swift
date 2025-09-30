
import SwiftUI

// Ключ для передачі геометрії
struct ViewPositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    func captureFrame(in coordinateSpace: CoordinateSpace, _ onChange: @escaping (CGRect) -> Void) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ViewPositionKey.self, value: geo.frame(in: coordinateSpace))
            }
        )
        .onPreferenceChange(ViewPositionKey.self, perform: onChange)
    }
}

struct TestGamePlayView: View {
    
    @ObservedObject var gameState: GameState
    @State var showPopup = false
    @State private var popupState: PopupState = .pause
    @Environment(\.presentationMode) var presentationMode
    
    @State private var ballPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State private var vx: CGFloat = 0
    @State private var vy: CGFloat = 0
    @State private var isFlying = false
    @State private var cannonFrame: CGRect = .zero
    @State private var cannonRealPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    @State private var barrier1Frame: CGRect = .zero
    @State private var barrier2Frame: CGRect = .zero
    @State private var barrier3Frame: CGRect = .zero
    @State private var barrier4Frame: CGRect = .zero
    @State private var plinkoBalls: [[Bool]] = [
        Array(repeating: true, count: 6),
        Array(repeating: true, count: 7),
        Array(repeating: true, count: 6),
        Array(repeating: true, count: 7),
        Array(repeating: true, count: 6)
    ]
    @State private var score: Int = 0
    @State private var flightTimer: Timer?
    @State private var ballsRemaining: Int = 12
    @State private var gameEnded: Bool = false
    
    let gravity: CGFloat = 0.4
    let initialSpeed: CGFloat = 25
    let ballRadius: CGFloat = 10
    let topY: CGFloat = 100
    let damping: CGFloat = 0.7
    
    var body: some View {
        ZStack {
            Image(gameState.selectedWorld.backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .blur(radius: 2)
            
            VStack {
                ZStack {
                    Image("score_header_frame")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 20) {
                        Text(gameState.formattedGameTime)
                            .font(AppFonts.title)
                            .foregroundColor(.white)
                            .offset(x: 20)
                        
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
                
                HStack {
                    Image("Bounce_Barrier_01")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 90)
                        .offset(x: -6)
                        .captureFrame(in: .global) { frame in
                            barrier1Frame = frame
                        }
                    Spacer()
                    Spacer()
                    
                    Image("Bounce_Barrier_02")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 90)
                        .offset(x: 6)
                        .captureFrame(in: .global) { frame in
                            barrier2Frame = frame
                        }
                }
                
                Spacer()
                Spacer()
                
                HStack {
                    Image("Bounce_Barrier_01")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 90)
                        .offset(x: -6)
                        .captureFrame(in: .global) { frame in
                            barrier3Frame = frame
                        }
                    
                    Spacer()
                    Spacer()
                    
                    Image("Bounce_Barrier_02")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 90)
                        .offset(x: 6)
                        .captureFrame(in: .global) { frame in
                            barrier4Frame = frame
                        }
                }
                
                Spacer()
                
                // Елементи управління та пушка на одній висоті
                HStack {
                    Button(action: {
                        gameState.moveCannonLeft()
                    }) {
                        Image("Property 1=normal") // left arrow
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .captureFrame(in: .global) { frame in
                                cannonFrame = frame
                            }
                    }
                    
                    Spacer()
                    
                    
                    // Пушка по центру з кулькою під нею
                    ZStack {
                        // Кулька під пушкою (невидима до пострілу)
                        Image(gameState.selectedSkin.backgroundImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .opacity(isFlying ? 0 : 1) // Видима тільки коли не летить
                        
                        // Пушка поверх кульки
                        Image("barrell 2") // PUSHKA
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                    }
                    .offset(x: gameState.cannonPosition)
                    .captureFrame(in: .global) { frame in
                        cannonFrame = frame
                        cannonRealPosition = CGPoint(x: frame.midX, y: frame.midY)
                    }
                    .onTapGesture {
                        if !isFlying {
                            fire()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        gameState.moveCannonRight()
                    }) {
                        Image("Right__bottom_button=normal-2") // right arrow
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .captureFrame(in: .global) { frame in
                                cannonFrame = frame
                            }
                    }
                }
                
                // Нижнє меню
                ZStack {
                    Image("Menu_Footer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .offset(y: 20)
                    
                    HStack {
                        Button(action: {
                            gameState.pauseGame()
                            popupState = .pause
                            showPopup = true
                        }) {
                            Image("Property 1=icon_pause")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                        }
                        
                        NavigationLink(destination: RulesView()) {
                            Image("question_top_button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 70)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        
                        Button(action: {
                            gameState.toggleSound()
                        }) {
                            ZStack {
                                Image(gameState.selectedSkin.backgroundImageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                
                                Text("x\(ballsRemaining)")  // кількість кульок
                                    .font(AppFonts.title)
                                    .foregroundColor(.white)
                                    .offset(x: 40, y: 15 )
                                    
                            }
                        }
                    }
                    .padding(.top, 50)
                }
            }
            
            Image(gameState.selectedSkin.backgroundImageName) // кулька
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .position(ballPosition)
                .opacity(isFlying ? 1 : 0) // Видима тільки коли летить
            
            // 5 рядів кульок "Plinko ball 2"
            VStack(spacing: 30) {
                ForEach(0..<5, id: \.self) { rowIndex in
                    HStack(spacing: 20) {
                        ForEach(0..<plinkoBalls[rowIndex].count, id: \.self) { colIndex in
                            Image("Plinko ball 2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .opacity(plinkoBalls[rowIndex][colIndex] ? 1.0 : 0.0) // прозорість
                        }
                    }
                }
            }
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            
            if showPopup {
                PopupView(
                    isPresented: $showPopup, 
                    state: popupState, 
                    gameState: gameState,
                    onResume: resumeGame,
                    onRestart: restartGame,
                    onExit: exitToMenu,
                    onMenu: navigateToMenu
                ) {
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .onAppear {
            // Скидаємо позицію пушки в центр
            gameState.resetCannonPosition()
            gameState.startGameTimer()
            // Ініціалізуємо позицію кульки на позиції пушки
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ballPosition = cannonRealPosition
            }
        }
        .onDisappear {
            gameState.stopGameTimer()
        }
        .onChange(of: gameState.cannonPosition) { newPosition in
            print("Cannon position змінився на: \(newPosition)")
            // Оновлюємо cannonFrame вручну
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            cannonFrame = CGRect(
                x: screenWidth / 2 + newPosition - 35, // 35 = половина ширини пушки
                y: screenHeight - 150 - 35, // 35 = половина висоти пушки
                width: 70,
                height: 70
            )
            // Оновлюємо реальну позицію пушки
            cannonRealPosition = CGPoint(x: cannonFrame.midX, y: cannonFrame.midY)
            // Синхронізуємо позицію кульки з пушкою, якщо вона не летить
            if !isFlying {
               
                ballPosition = cannonRealPosition
               
            }
            print("Оновлена позиція пушки: x=\(cannonFrame.midX), y=\(cannonFrame.midY)")
        }
    }
    
    func fire() {
        // Перевіряємо чи є кульки та чи не закінчилась гра
        if ballsRemaining <= 0 || gameEnded {
            return
        }
        
        print("=== ПОЧАТОК ПОСТРІЛУ ===")
        print("ballsRemaining: \(ballsRemaining)")
        
        // Зменшуємо кількість кульок
        ballsRemaining -= 1
        
        // Скидаємо попередній таймер та швидкості
        flightTimer?.invalidate()
        vx = 0
        vy = 0
        
        // Початкова позиція кульки (з реальної позиції пушки)
        ballPosition = cannonRealPosition
        print("Кулька стартує з: X=\(cannonRealPosition.x), Y=\(cannonRealPosition.y)")
        
        // Рандомний кут 80–100°
        let angleDegrees = Double.random(in: 85...95)
        let angleRadians = angleDegrees * .pi / 180
        
        // Початкові швидкості
        vx = initialSpeed * cos(angleRadians)
        vy = -initialSpeed * sin(angleRadians)
        
        isFlying = true
        print("isFlying після пострілу: \(isFlying)")
        print("vx: \(vx), vy: \(vy)")
        print("ballsRemaining після пострілу: \(ballsRemaining)")
        print("=== КІНЕЦЬ ПОСТРІЛУ ===")
        
        flightTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { timer in
            vy += gravity
            ballPosition.x += vx
            ballPosition.y += vy
            
            // Перевірка зіткнення з Plinko кульками
            checkPlinkoCollision()
            
            // Відбиття від бордерів
            checkBarrierCollision()
            
            // Відбиття від верхнього меню (score_header_frame)
            let topMenuHeight: CGFloat = 120 // Висота верхнього меню з padding
            if ballPosition.y - ballRadius <= topMenuHeight {
                ballPosition.y = topMenuHeight + ballRadius
                vy = -vy * damping
            }
            
            // Кулька падає за межі екрану
            if ballPosition.y >= UIScreen.main.bounds.height + 100 {
                print("=== КУЛЬКА ПАДАЄ ЗА МЕЖІ ===")
                print("ballPosition при падінні: x=\(ballPosition.x), y=\(ballPosition.y)")
                print("ballsRemaining: \(ballsRemaining)")
                print("gameEnded: \(gameEnded)")
               
                isFlying = false
                timer.invalidate()
                flightTimer = nil
                vx = 0
                vy = 0
                
                // ВІДРАЗУ повертаємо кульку на позицію пушки
                ballPosition = cannonRealPosition
                
                // Перевіряємо чи закінчились кульки
                checkLoseCondition()
                print("=== КІНЕЦЬ ПАДІННЯ ===")
            }
        }
    }
    
    func checkPlinkoCollision() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let plinkoSpacing: CGFloat = 20
        let plinkoSize: CGFloat = 25
        let ballSize: CGFloat = 15  // Зменшено з 30 до 15 (радіус кульки)
        let rowSpacing: CGFloat = 30
        
        // Початкова Y позиція першого ряду
        let startY = screenHeight / 2 - (4 * rowSpacing + 4 * plinkoSize) / 2
        
        for rowIndex in 0..<5 {
            let plinkoY = startY + CGFloat(rowIndex) * (rowSpacing + plinkoSize)
            let ballsInRow = plinkoBalls[rowIndex].count
            
            // Початкова X позиція першої кульки в ряді
            let startX = screenWidth / 2 - (CGFloat(ballsInRow - 1) * plinkoSpacing + CGFloat(ballsInRow) * plinkoSize) / 2
            
            for colIndex in 0..<ballsInRow {
                if plinkoBalls[rowIndex][colIndex] { // Тільки якщо кулька видима
                    let plinkoX = startX + CGFloat(colIndex) * (plinkoSpacing + plinkoSize)
                    
                    // Перевірка зіткнення з більш точним радіусом
                    let distance = sqrt(pow(ballPosition.x - plinkoX, 2) + pow(ballPosition.y - plinkoY, 2))
                    let collisionDistance = (ballSize + plinkoSize) / 2 - 5  // Віднімаємо 5 для більшої точності
                    
                    if distance < collisionDistance {
                        // Зіткнення!
                        print("Зіткнення з Plinko кулькою: ряд \(rowIndex), колонка \(colIndex), відстань: \(distance)")
                        plinkoBalls[rowIndex][colIndex] = false // Робимо кульку прозорою
                        score += 2 // Додаємо бал
                        gameState.totalScore += 2 // Додаємо бал до загального рахунку
                        
                        // Перевіряємо чи всі Plinko кульки зникли
                        checkWinCondition()
                    }
                }
            }
        }
    }
    
    func checkWinCondition() {
        // Перевіряємо чи всі Plinko кульки зникли
        var allBallsGone = true
        for row in plinkoBalls {
            for ball in row {
                if ball {  // Якщо є хоча б одна видима кулька
                    allBallsGone = false
                    break
                }
            }
            if !allBallsGone { break }
        }
        
        if allBallsGone && !gameEnded {
            print("=== ВИГРАШ! ВСІ КУЛЬКИ ЗНИКЛИ ===")
            gameEnded = true
            gameState.pauseGame()  // Зупиняємо таймер
            popupState = .win
            showPopup = true
        }
    }
    
    func checkLoseCondition() {
        // Перевіряємо чи закінчились кульки і чи не всі Plinko кульки зникли
        if ballsRemaining <= 0 && !gameEnded {
            // Перевіряємо чи є ще Plinko кульки
            var hasRemainingPlinkoBalls = false
            for row in plinkoBalls {
                for ball in row {
                    if ball {  // Якщо є хоча б одна видима Plinko кулька
                        hasRemainingPlinkoBalls = true
                        break
                    }
                }
                if hasRemainingPlinkoBalls { break }
            }
            
            if hasRemainingPlinkoBalls {
                print("=== ПРОГРАШ! ЗАКІНЧИЛИСЬ КУЛЬКИ ===")
                gameEnded = true
                gameState.pauseGame()  // Зупиняємо таймер
                popupState = .lose
                showPopup = true
            }
        }
    }
    
    func resetGame() {
        // Скидаємо всі змінні гри
        ballsRemaining = 6
        gameEnded = false
        score = 0
        isFlying = false
        vx = 0
        vy = 0
        
        // Скидаємо позицію пушки в центр
        gameState.resetCannonPosition()
        
        ballPosition = cannonRealPosition
        
        // Скидаємо всі Plinko кульки
        plinkoBalls = [
            Array(repeating: true, count: 6),
            Array(repeating: true, count: 7),
            Array(repeating: true, count: 6),
            Array(repeating: true, count: 7),
            Array(repeating: true, count: 6)
        ]
        
        // Скидаємо таймер
        flightTimer?.invalidate()
        flightTimer = nil
        
        // Зупиняємо ігровий таймер
        gameState.stopGameTimer()
        
        // Перезапускаємо ігровий таймер
        gameState.startGameTimer()
        
        print("=== ГРА СКИНУТА ===")
    }
    
    func resumeGame() {
        // Продовжуємо гру
        showPopup = false
        gameState.resumeGame()  // Відновлюємо таймер
        print("=== ГРА ПРОДОВЖЕНА ===")
    }
    
    func restartGame() {
        // Починаємо гру з нуля
        showPopup = false
        resetGame()
        print("=== ГРА ПЕРЕЗАПУЩЕНА ===")
    }
    
    func exitToMenu() {
        // Виходимо в меню
        showPopup = false
        gameState.pauseGame()  // Зупиняємо таймер
        // Тут можна додати навігацію до MenuView
        print("=== ВИХІД В МЕНЮ ===")
    }
    
    func navigateToMenu() {
        // Навігація до меню
        showPopup = false
        gameState.pauseGame()  // Зупиняємо таймер
        presentationMode.wrappedValue.dismiss()  // Повертаємось до попереднього екрану (меню)
        print("=== НАВІГАЦІЯ ДО МЕНЮ ===")
    }
    
    func checkBarrierCollision() {
        let ballSize: CGFloat = 30
        
        // Масив всіх бордерів для перевірки
        let barriers = [barrier1Frame, barrier2Frame, barrier3Frame, barrier4Frame]
        
        for barrier in barriers {
            // Перевіряємо чи бордер ініціалізований (не .zero)
            if barrier != .zero {
                // Перевірка зіткнення з бордером
                if ballPosition.x >= barrier.minX && ballPosition.x <= barrier.maxX &&
                   ballPosition.y >= barrier.minY && ballPosition.y <= barrier.maxY {
                    
                    // Визначаємо з якої сторони зіткнення
                    let leftDistance = abs(ballPosition.x - barrier.minX)
                    let rightDistance = abs(ballPosition.x - barrier.maxX)
                    let topDistance = abs(ballPosition.y - barrier.minY)
                    let bottomDistance = abs(ballPosition.y - barrier.maxY)
                    
                    let minDistance = min(leftDistance, rightDistance, topDistance, bottomDistance)
                    
                    if minDistance == leftDistance {
                        // Зіткнення зліва
                        vx = -vx * damping
                        ballPosition.x = barrier.minX - ballSize/2
                    } else if minDistance == rightDistance {
                        // Зіткнення справа
                        vx = -vx * damping
                        ballPosition.x = barrier.maxX + ballSize/2
                    } else if minDistance == topDistance {
                        // Зіткнення зверху
                        vy = -vy * damping
                        ballPosition.y = barrier.minY - ballSize/2
                    } else {
                        // Зіткнення знизу
                        vy = -vy * damping
                        ballPosition.y = barrier.maxY + ballSize/2
                    }
                    
                    print("Зіткнення з бордером: x=\(Int(barrier.midX)), y=\(Int(barrier.midY))")
                }
            }
        }
    }
}
