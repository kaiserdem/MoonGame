import SwiftUI


struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

enum PopupState {
    case pause, win, lose
}

struct PopupView<Content: View>: View {
    let content: Content
    
    var state: PopupState
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, state: PopupState,  @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
        self.state = state
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .blur(radius: 100)
                
                content
                    .transition(.scale.combined(with: .opacity))
                
                
                ZStack {
                    Image("Pop-up_Frame")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .center, spacing: -10) {
                        
                        
                        switch state {
                        case .pause:
                            ZStack {
                                Image("Frame")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 250)

                                
                                Image("PAUSE")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .offset(y:70)
                            }
                        case .win:
                            ZStack {
                                Image("win check up=3 star")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 100)
                                    .offset(y:-10)
                                
                                Image("YOU WIN!")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .offset(y:70)
                            }
                        case .lose:
                            ZStack {
                                Image("Loose 3 star")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 100)

                                
                                Image("YOU LOSE!")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 50)
                                    .offset(y:70)
                            }
                        }
                     
                    }
                    
                    HStack(spacing: -10) {
                        
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image("Component 33")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 70)
                        }
                        
                        Button(action: {
                            // Repeat
                        }) {
                            Image("Repeat_bottom_button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 70)
                        }
                        
                        Button(action: {
                            // left
                        }) {
                            Image("Right__bottom_button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 70)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 280)
                }
                .padding(20)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

