
import SwiftUI

struct TestGamePlayView: View {
    
    @ObservedObject var gameState: GameState
    
    @State private var ballPosition: CGPoint = CGPoint(x: 200, y: 600) // старт
    @State private var vx: CGFloat = 0
    @State private var vy: CGFloat = 0
    @State private var isFlying = false
    @State private var plinkoBalls: [Bool] = Array(repeating: true, count: 6) // true = видима, false = прозора
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
            
            // 6 кульок "Plinko ball 2" по горизонталі посередині
            HStack(spacing: 20) {
                ForEach(0..<6, id: \.self) { index in
                    Image("Plinko ball 2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .opacity(plinkoBalls[index] ? 1.0 : 0.0) // прозорість
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
        let plinkoY = screenHeight / 2 // Y позиція Plinko кульок
        let plinkoSpacing: CGFloat = 20
        let plinkoSize: CGFloat = 25
        let ballSize: CGFloat = 30
        
        // Початкова X позиція першої кульки
        let startX = screenWidth / 2 - (5 * plinkoSpacing + 5 * plinkoSize) / 2
        
        for i in 0..<6 {
            if plinkoBalls[i] { // Тільки якщо кулька видима
                let plinkoX = startX + CGFloat(i) * (plinkoSpacing + plinkoSize)
                
                // Перевірка зіткнення
                let distance = sqrt(pow(ballPosition.x - plinkoX, 2) + pow(ballPosition.y - plinkoY, 2))
                let collisionDistance = (ballSize + plinkoSize) / 2
                
                if distance < collisionDistance {
                    // Зіткнення!
                    plinkoBalls[i] = false // Робимо кульку прозорою
                    score += 1 // Додаємо бал
                }
            }
        }
    }
}
