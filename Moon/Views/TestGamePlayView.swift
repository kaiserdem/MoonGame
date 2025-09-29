
import SwiftUI

struct TestGamePlayView: View {
    
    @ObservedObject var gameState: GameState
    
    @State private var ballPosition: CGPoint = CGPoint(x: 200, y: 600) // старт
    @State private var vx: CGFloat = 0
    @State private var vy: CGFloat = 0
    @State private var isFlying = false
    @State private var plinkoBalls: [[Bool]] = [
        Array(repeating: true, count: 6),  // 1-й ряд: 6 кульок
        Array(repeating: true, count: 7),  // 2-й ряд: 7 кульок
        Array(repeating: true, count: 6),  // 3-й ряд: 6 кульок
        Array(repeating: true, count: 7),  // 4-й ряд: 7 кульок
        Array(repeating: true, count: 6)   // 5-й ряд: 6 кульок
    ]
    @State private var score: Int = 0
    
    // Константи
    let gravity: CGFloat = 0.3       // сила тяжіння (зменшено)
    let initialSpeed: CGFloat = 25   // початкова швидкість (зменшено)
    let ballRadius: CGFloat = 15     // радіус кульки
    let topY: CGFloat = 100          // висота верхньої в'юшки
    let damping: CGFloat = 0.5       // коефіцієнт втрати енергії при відскоку (зменшено)
    
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
                // "Пушка"
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 60, height: 20)
                    .position(x: 200, y: 620)
        
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
            
            // Кулька окремо в ZStack
            Image(gameState.selectedSkin.backgroundImageName) // кулька
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .position(ballPosition)
            
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
            
            // Лічильник балів
            VStack {
                Text("Балів: \(score)")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func fire() {
        ballPosition = CGPoint(x: 200, y: 600)
        
        // Рандомний кут 80–100°
        let angleDegrees = Double.random(in: 85...95)
        let angleRadians = angleDegrees * .pi / 180
        
        // Початкові швидкості
        vx = initialSpeed * cos(angleRadians)
        vy = -initialSpeed * sin(angleRadians)
        
        isFlying = true
        
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            vy += gravity
            ballPosition.x += vx
            ballPosition.y += vy
            
            // Перевірка зіткнення з Plinko кульками
            checkPlinkoCollision()
            
            // Стеля (відскок від верхньої в'юшки)
            if ballPosition.y - ballRadius <= topY + 10 {
                ballPosition.y = topY + 10 + ballRadius
                vy = -vy * damping
            }
            
            // Земля
            if ballPosition.y >= 600 {
                ballPosition.y = 600
                isFlying = false
                timer.invalidate()
            }
        }
    }
    
    func checkPlinkoCollision() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let plinkoSpacing: CGFloat = 20
        let plinkoSize: CGFloat = 25
        let ballSize: CGFloat = 30
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
                    
                    // Перевірка зіткнення
                    let distance = sqrt(pow(ballPosition.x - plinkoX, 2) + pow(ballPosition.y - plinkoY, 2))
                    let collisionDistance = (ballSize + plinkoSize) / 2
                    
                    if distance < collisionDistance {
                        // Зіткнення!
                        plinkoBalls[rowIndex][colIndex] = false // Робимо кульку прозорою
                        score += 1 // Додаємо бал
                    }
                }
            }
        }
    }
}
