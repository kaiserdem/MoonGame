
import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        ZStack {
            Image("26 img")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer()
                
                    
                    ZStack {
                        Image("Pop-up_Text_Frame")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .center, spacing: -10) {
                            
                            Spacer()
                            
                            Text("GAME RULES:\n\n• Tap the cannon to shoot\n• Use arrows to move the cannon\n• Hit Plinko balls to earn points\n• Avoid letting the ball fall off-screen\n• Collect coins to unlock worlds and skins")
                                .font(AppFonts.title)
                                .foregroundColor(AppColors.Text.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 0)
                                .minimumScaleFactor(0.5)
                                .lineLimit(nil)
                                .frame(maxHeight: 400)
                           
                            
                            Spacer()
                        }

                }
                    
                Button(action: {
                    dismiss()
                }) {
                    Image("Component 33")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                }
                
                
                Spacer()
                
                ZStack {
                    Image("Menu_Footer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .clipped()
                    
                    
                    Image("RULES")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 90)
                        .offset(y: 30)
                    
                    
                    
                }
            }
        }
        .navigationBarHidden(true)
    }
}
