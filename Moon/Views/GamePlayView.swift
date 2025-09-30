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

struct GamePlayView: View {
    @ObservedObject var gameState: GameState
    @StateObject private var gameLogic = GameLogic()
    @State var showPopup = false
    @State private var popupState: PopupState = .pause
    @Environment(\.presentationMode) var presentationMode
    @State private var cannonFrame: CGRect = .zero
    @State private var cannonRealPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State private var barrier1Frame: CGRect = .zero
    @State private var barrier2Frame: CGRect = .zero
    @State private var barrier3Frame: CGRect = .zero
    @State private var barrier4Frame: CGRect = .zero
    
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
                            updateBarrierFrames()
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
                            updateBarrierFrames()
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
                            updateBarrierFrames()
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
                            updateBarrierFrames()
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
                            .opacity(gameLogic.isFlying ? 0 : 1)
                        
                        Image("barrell 2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                    }
                    .offset(x: gameState.cannonPosition)
                    .captureFrame(in: .global) { frame in
                        cannonFrame = frame
                        cannonRealPosition = CGPoint(x: frame.midX, y: frame.midY)
                        gameLogic.updateCannonPosition(cannonRealPosition)
                    }
                    .onTapGesture {
                        if !gameLogic.isFlying {
                            gameLogic.fire()
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
                                
                                Text("x\(gameLogic.ballsRemaining)")
                                    .font(AppFonts.title)
                                    .foregroundColor(.white)
                                    .offset(x: 40, y: 15)
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
                .position(gameLogic.ballPosition)
                .opacity(gameLogic.isFlying ? 1 : 0)
            
            VStack(spacing: 30) {
                ForEach(0..<5, id: \.self) { rowIndex in
                    HStack(spacing: 20) {
                        ForEach(0..<gameLogic.plinkoBalls[rowIndex].count, id: \.self) { colIndex in
                            Image("Plinko ball 2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .opacity(gameLogic.plinkoBalls[rowIndex][colIndex] ? 1.0 : 0.0)
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
                gameLogic.updateCannonPosition(cannonRealPosition)
            }
        }
        .onDisappear {
            gameState.stopGameTimer()
            gameLogic.stopGame()
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
            gameLogic.updateCannonPosition(cannonRealPosition)
        }
        .onChange(of: gameLogic.gameEnded) { gameEnded in
            if gameEnded {
                if gameLogic.ballsRemaining <= 0 {
                    popupState = .lose
                } else {
                    popupState = .win
                    gameState.totalScore += gameLogic.score
                }
                showPopup = true
            }
        }
    }
    
    private func updateBarrierFrames() {
        gameLogic.updateBarrierFrames([barrier1Frame, barrier2Frame, barrier3Frame, barrier4Frame])
    }
    
    func resumeGame() {
        showPopup = false
        gameState.resumeGame()
    }
    
    func restartGame() {
        showPopup = false
        gameLogic.resetGame()
        gameState.resetGameTimer()
        gameState.startGameTimer()
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
}
