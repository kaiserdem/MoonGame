import SwiftUI

struct PopupView<Content: View>: View {
    let content: Content
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                // Заблюрений фон
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .blur(radius: 5)
                    .onTapGesture {
                        isPresented = false
                    }
                
                // Контент попапу
                content
                    .transition(.scale.combined(with: .opacity))
                
                
                ZStack {
                    Image("Pop-up_Frame")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .center, spacing: -10) {
                        
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
                        
                        HStack {
                            Image("Group 89")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 90)
                                .offset(y: -70)
                            
                            Image("Repeat_bottom_button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 90)
                                .offset(y: -70)
                            
                            Image("Right__bottom_button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 90)
                                .offset(y: -70)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

