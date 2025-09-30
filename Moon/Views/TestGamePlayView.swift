import SwiftUI
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
                HStack {
                    Button(action: {
                        gameState.moveCannonLeft()
                    }) {
                        Image("Property 1=normal")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .captureFrame(in: .global) { frame in
                                cannonFrame = frame
                            }
                    }
                    Spacer()
                    ZStack {
                        Image(gameState.selectedSkin.backgroundImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .opacity(isFlying ? 0 : 1)
                        Image("barrell 2")
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
                        Image("Right__bottom_button=normal-2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .captureFrame(in: .global) { frame in
                                cannonFrame = frame
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
                                Text("x\(ballsRemaining)")
                                    .font(AppFonts.title)
                                    .foregroundColor(.white)
                                    .offset(x: 40, y: 15 )
                            }
                        }
                    }
                    .padding(.top, 50)
                }
            }
            Image(gameState.selectedSkin.backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .position(ballPosition)
                .opacity(isFlying ? 1 : 0) 
            VStack(spacing: 30) {
                ForEach(0..<5, id: \.self) { rowIndex in
                    HStack(spacing: 20) {
                        ForEach(0..<plinkoBalls[rowIndex].count, id: \.self) { colIndex in
                            Image("Plinko ball 2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .opacity(plinkoBalls[rowIndex][colIndex] ? 1.0 : 0.0) 
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
            gameState.resetCannonPosition()
            gameState.startGameTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ballPosition = cannonRealPosition
            }
        }
        .onDisappear {
            gameState.stopGameTimer()
        }
        .onChange(of: gameState.cannonPosition) { newPosition in
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            cannonFrame = CGRect(
                x: screenWidth / 2 + newPosition - 35, 
                y: screenHeight - 150 - 35, 
                width: 70,
                height: 70
            )
            cannonRealPosition = CGPoint(x: cannonFrame.midX, y: cannonFrame.midY)
            if !isFlying {
                ballPosition = cannonRealPosition
            }
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
                timer.invalidate()
                flightTimer = nil
                vx = 0
                vy = 0
                ballPosition = cannonRealPosition
                checkLoseCondition()
            }
        }
    }
    func checkPlinkoCollision() {
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
                        score += 2 
                        gameState.totalScore += 2 
                        checkWinCondition()
                    }
                }
            }
        }
    }
    func checkWinCondition() {
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
            gameState.pauseGame()  
            popupState = .win
            showPopup = true
        }
    }
    func checkLoseCondition() {
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
                gameState.pauseGame()  
                popupState = .lose
                showPopup = true
            }
        }
    }
    func resetGame() {
        ballsRemaining = 6
        gameEnded = false
        score = 0
        isFlying = false
        vx = 0
        vy = 0
        gameState.resetCannonPosition()
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
        gameState.stopGameTimer()
        gameState.startGameTimer()
    }
    func resumeGame() {
        showPopup = false
        gameState.resumeGame()  
    }
    func restartGame() {
        showPopup = false
        resetGame()
    }
    func exitToMenu() {
        showPopup = false
        gameState.pauseGame()  
    }
    func navigateToMenu() {
        showPopup = false
        gameState.pauseGame()  
        presentationMode.wrappedValue.dismiss()  
    }
    func checkBarrierCollision() {
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
}
