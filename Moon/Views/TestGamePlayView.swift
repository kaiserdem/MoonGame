
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
    
    let gravity: CGFloat = 0.4
    let initialSpeed: CGFloat = 25
    let ballRadius: CGFloat = 15     // радіус кульки
    let topY: CGFloat = 100          // висота верхньої в'юшки
    let damping: CGFloat = 0.7       // коефіцієнт втрати енергії при відскоку (оптимізовано)
    
    var body: some View {
        ZStack {
            // Фон
            Image(gameState.selectedWorld.backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .blur(radius: 2)
            
            // Елементи в VStack
            VStack {
                // Верхнє меню
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
                
                // Верхні бордери
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
                        print("Пушка позиція: x=\(Int(frame.midX)), y=\(Int(frame.midY))")
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
                //.padding(.horizontal, 20)
                //.padding(.bottom, 20)
                
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
            
            // Кулька під час польоту (видима тільки коли летить)
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
                PopupView(isPresented: $showPopup, state: .pause, gameState: gameState) {
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .onAppear {
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
                print("=== СИНХРОНІЗАЦІЯ З ПУШКОЮ ===")
                print("isFlying: \(isFlying)")
                print("cannonRealPosition: x=\(cannonRealPosition.x), y=\(cannonRealPosition.y)")
                print("ballPosition до синхронізації: x=\(ballPosition.x), y=\(ballPosition.y)")
                ballPosition = cannonRealPosition
                print("ballPosition після синхронізації: x=\(ballPosition.x), y=\(ballPosition.y)")
                print("=== КІНЕЦЬ СИНХРОНІЗАЦІЇ ===")
            }
            print("Оновлена позиція пушки: x=\(cannonFrame.midX), y=\(cannonFrame.midY)")
        }
    }
    
    func fire() {
        print("=== ПОЧАТОК ПОСТРІЛУ ===")
        print("isFlying до пострілу: \(isFlying)")
        print("cannonRealPosition: x=\(cannonRealPosition.x), y=\(cannonRealPosition.y)")
        print("ballPosition до пострілу: x=\(ballPosition.x), y=\(ballPosition.y)")
        
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
                print("cannonRealPosition: x=\(cannonRealPosition.x), y=\(cannonRealPosition.y)")
                print("isFlying до скидання: \(isFlying)")
                
                isFlying = false
                timer.invalidate()
                flightTimer = nil
                vx = 0
                vy = 0
                
                // ВІДРАЗУ повертаємо кульку на позицію пушки
                ballPosition = cannonRealPosition
                
                print("isFlying після скидання: \(isFlying)")
                print("vx після скидання: \(vx), vy після скидання: \(vy)")
                print("ballPosition після повернення: x=\(ballPosition.x), y=\(ballPosition.y)")
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
                        score += 1 // Додаємо бал
                        gameState.totalScore += 1 // Додаємо бал до загального рахунку
                    }
                }
            }
        }
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
