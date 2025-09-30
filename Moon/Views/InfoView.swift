import SwiftUI
struct InfoView: View {
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
                            Text("APP BENEFITS:\n\n• Improves coordination and reaction\n• Trains accuracy and strategic thinking\n• Relaxing and stress-relieving\n• Boosts concentration\n• A fun way to spend time")
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
                    Image("Group 32")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
                        .offset(y: 30)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
