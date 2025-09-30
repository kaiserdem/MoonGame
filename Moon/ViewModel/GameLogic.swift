import SwiftUI
import Combine

class GameLogic: ObservableObject {
    @Published var ballPosition: CGPoint = CGPoint(x: 0, y: 0)
    @Published var isFlying = false
    @Published var plinkoBalls: [[Bool]] = [
        Array(repeating: true, count: 6),
        Array(repeating: true, count: 7),
        Array(repeating: true, count: 6),
        Array(repeating: true, count: 7),
        Array(repeating: true, count: 6)
    ]
    @Published var score: Int = 0
    @Published var ballsRemaining: Int = 12
    @Published var gameEnded: Bool = false
    
    private var vx: CGFloat = 0
    private var vy: CGFloat = 0
    private var flightTimer: Timer?
    private var cannonRealPosition: CGPoint = CGPoint(x: 0, y: 0)
    private var barrier1Frame: CGRect = .zero
    private var barrier2Frame: CGRect = .zero
    private var barrier3Frame: CGRect = .zero
    private var barrier4Frame: CGRect = .zero
    
    let gravity: CGFloat = 0.4
    let initialSpeed: CGFloat = 25
    let ballRadius: CGFloat = 10
    let topY: CGFloat = 100
    let damping: CGFloat = 0.7
    
    func updateCannonPosition(_ position: CGPoint) {
        cannonRealPosition = position
        if !isFlying {
            ballPosition = cannonRealPosition
        }
    }
    
    func updateBarrierFrames(_ frames: [CGRect]) {
        if frames.count >= 4 {
            barrier1Frame = frames[0]
            barrier2Frame = frames[1]
            barrier3Frame = frames[2]
            barrier4Frame = frames[3]
        }
    }
    
    func fire() {
        if ballsRemaining <= 0 || gameEnded {
            return
        }
        
        ballsRemaining -= 1
        flightTimer?.invalidate()
        vx = 0
        vy = 0
        ballPosition = cannonRealPosition
        
        let angleDegrees = Double.random(in: 85...95)
        let angleRadians = angleDegrees * .pi / 180
        vx = initialSpeed * cos(angleRadians)
        vy = -initialSpeed * sin(angleRadians)
        isFlying = true
        
        flightTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { timer in
            self.updateBallPhysics()
        }
    }
    
    private func updateBallPhysics() {
        vy += gravity
        ballPosition.x += vx
        ballPosition.y += vy
        
        checkPlinkoCollision()
        checkBarrierCollision()
        
        let topMenuHeight: CGFloat = 120
        if ballPosition.y - ballRadius <= topMenuHeight {
            ballPosition.y = topMenuHeight + ballRadius
            vy = -vy * damping
        }
        
        if ballPosition.y >= UIScreen.main.bounds.height + 100 {
            isFlying = false
            flightTimer?.invalidate()
            flightTimer = nil
            vx = 0
            vy = 0
            ballPosition = cannonRealPosition
            checkLoseCondition()
        }
    }
    
    private func checkPlinkoCollision() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let plinkoSpacing: CGFloat = 20
        let plinkoSize: CGFloat = 25
        let ballSize: CGFloat = 15
        let rowSpacing: CGFloat = 30
        
        let startY = screenHeight / 2 - (4 * rowSpacing + 4 * plinkoSize) / 2
        
        for rowIndex in 0..<5 {
            let plinkoY = startY + CGFloat(rowIndex) * (rowSpacing + plinkoSize)
            let ballsInRow = plinkoBalls[rowIndex].count
            let startX = screenWidth / 2 - (CGFloat(ballsInRow - 1) * plinkoSpacing + CGFloat(ballsInRow) * plinkoSize) / 2
            
            for colIndex in 0..<ballsInRow {
                if plinkoBalls[rowIndex][colIndex] {
                    let plinkoX = startX + CGFloat(colIndex) * (plinkoSpacing + plinkoSize)
                    let distance = sqrt(pow(ballPosition.x - plinkoX, 2) + pow(ballPosition.y - plinkoY, 2))
                    let collisionDistance = (ballSize + plinkoSize) / 2 - 5
                    
                    if distance < collisionDistance {
                        plinkoBalls[rowIndex][colIndex] = false
                        checkWinCondition()
                    }
                }
            }
        }
    }
    
    private func checkWinCondition() {
        var allBallsGone = true
        for row in plinkoBalls {
            for ball in row {
                if ball {
                    allBallsGone = false
                    break
                }
            }
            if !allBallsGone { break }
        }
        
        if allBallsGone && !gameEnded {
            gameEnded = true
            score = 400
            flightTimer?.invalidate()
        }
    }
    
    private func checkLoseCondition() {
        if ballsRemaining <= 0 && !gameEnded {
            var hasRemainingPlinkoBalls = false
            for row in plinkoBalls {
                for ball in row {
                    if ball {
                        hasRemainingPlinkoBalls = true
                        break
                    }
                }
                if hasRemainingPlinkoBalls { break }
            }
            
            if hasRemainingPlinkoBalls {
                gameEnded = true
                flightTimer?.invalidate()
            }
        }
    }
    
    private func checkBarrierCollision() {
        let ballSize: CGFloat = 30
        let barriers = [barrier1Frame, barrier2Frame, barrier3Frame, barrier4Frame]
        
        for barrier in barriers {
            if barrier != .zero {
                if ballPosition.x >= barrier.minX && ballPosition.x <= barrier.maxX &&
                   ballPosition.y >= barrier.minY && ballPosition.y <= barrier.maxY {
                    
                    let leftDistance = abs(ballPosition.x - barrier.minX)
                    let rightDistance = abs(ballPosition.x - barrier.maxX)
                    let topDistance = abs(ballPosition.y - barrier.minY)
                    let bottomDistance = abs(ballPosition.y - barrier.maxY)
                    
                    let minDistance = min(leftDistance, rightDistance, topDistance, bottomDistance)
                    
                    if minDistance == leftDistance {
                        vx = -vx * damping
                        ballPosition.x = barrier.minX - ballSize/2
                    } else if minDistance == rightDistance {
                        vx = -vx * damping
                        ballPosition.x = barrier.maxX + ballSize/2
                    } else if minDistance == topDistance {
                        vy = -vy * damping
                        ballPosition.y = barrier.minY - ballSize/2
                    } else {
                        vy = -vy * damping
                        ballPosition.y = barrier.maxY + ballSize/2
                    }
                }
            }
        }
    }
    
    func resetGame() {
        ballsRemaining = 12
        gameEnded = false
        score = 0
        isFlying = false
        vx = 0
        vy = 0
        ballPosition = cannonRealPosition
        
        plinkoBalls = [
            Array(repeating: true, count: 6),
            Array(repeating: true, count: 7),
            Array(repeating: true, count: 6),
            Array(repeating: true, count: 7),
            Array(repeating: true, count: 6)
        ]
        
        flightTimer?.invalidate()
        flightTimer = nil
    }
    
    func stopGame() {
        flightTimer?.invalidate()
        flightTimer = nil
        isFlying = false
        vx = 0
        vy = 0
    }
    
    deinit {
        flightTimer?.invalidate()
    }
}
