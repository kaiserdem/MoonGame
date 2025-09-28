
import SwiftUI

struct StoreView: View {
    
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Image("26 img")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            
                            Image("Pop-up_Text_Frame")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                            
                            
                            Image("Icon_Square_Frame=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                            
                            VStack(alignment: .center, spacing: -10) {
                                
                                // Debug print
                                let _ = print("🔍 StoreView Debug:")
                                let _ = print("   Current Skin ID: \(gameState.currentSkin.id)")
                                let _ = print("   Current Skin Index: \(gameState.currentSkinIndex)")
                                let _ = print("   Is Skin Purchased: \(gameState.isSkinPurchased(gameState.currentSkin.id))")
                                let _ = print("   Background Image: \(gameState.currentSkin.backgroundImageName)")
                                let _ = print("   Purchased Skins: \(gameState.purchasedSkins)")
                                
                                Image(gameState.currentSkin.backgroundImageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .offset(y: 20)
                                    .blur(radius: gameState.isSkinPurchased(gameState.currentSkin.id) ? 0 : 0.5)
                                    .brightness(gameState.isSkinPurchased(gameState.currentSkin.id) ? 0 : -0.05)
                                    .saturation(gameState.isSkinPurchased(gameState.currentSkin.id) ? 1 : 0.7)
                                
                                
                                ZStack {
                                    Image("button=inactive") // br price
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity, maxHeight: 80)
                                    
                                    HStack(spacing: 150) {
                                        
                                        Button(action: gameState.goToPreviousSkin) {
                                            Image("Property 1=normal")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                        }
                                        .disabled(gameState.currentSkinIndex == 0)
                                        
                                        
                                        
                                        
                                        Button(action: gameState.goToNextSkin) {
                                            Image("Right__bottom_button=normal-2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                        }
                                        .disabled(gameState.currentSkinIndex == SkinModel.sampleSkins.count - 1)
                                        
                                    }
                                    
                                    HStack(spacing: 10) {
                                        
                                        if gameState.isSkinPurchased(gameState.currentSkin.id) {
                                            
                                                if gameState.isSkinSelected(gameState.currentSkin.id) {
                                                Image("checkmark top button=Default")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 60, height: 60)
                                                    .offset(x: 40)
                                            } else {
                                                
                                                
                                                Button(action: {
                                                    gameState.selectSkin(gameState.currentSkin.id)
                                                }) {
                                                    Image("play bottom button=normal")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 60, height: 60)
                                                        .offset(x: 40)
                                                }
                                                
                                               
                                            }
                                            
                                            
                                        } else {
                                            Image("Сurrency - Сoin")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        
                                        if gameState.isSkinPurchased(gameState.currentSkin.id) {
                                            Spacer()
                                                .frame(width: 60, height: 60)
                                        } else {
                                                Text("\(gameState.currentSkinPrice)")
                                                    .font(AppFonts.title2)
                                                    .foregroundColor(AppColors.Text.brightGreen)
                                                    .frame(height: 60)
                                                    .onTapGesture {
                                                        if !gameState.isSkinPurchased(gameState.currentSkin.id) {
                                                            let success = gameState.buySkin()
                                                            if success {
                                                                print("Скін успішно куплено!")
                                                            } else {
                                                                print("Недостатньо балів для покупки")
                                                            }
                                                        }
                                                    }
                                        }
                                    }
                                    .onTapGesture {
                                        print("onTapGesture")
                                    }
                                }
                                .frame(width: 400)
                            }
                        }
                        
                        
                        ZStack {
                            Image("score_header_frame") // bgr curren user moneu
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                            
                            HStack(spacing: 20) {
                                
                                Spacer()
                                Image("Сurrency - Сoin")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                
                                
                                Spacer()
                                Spacer()
                                
                                
                                Text("\(gameState.totalScore)")
                                    .font(AppFonts.title)
                                    .foregroundColor(AppColors.Text.brightGreen)
                                
                                
                                Spacer()
                            }
                        }
                        
                    }
                    
                    ZStack {
                        Image("Menu_Footer")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            .offset(y: 20)
                        //.clipped()
                        
                        HStack {
                            
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Image("Component 33")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 70, height: 70)
                            }
                            
                            
                            
                            NavigationLink(destination: GamePlayView(gameState: gameState)) { // play
                                Image("play bottom button=normal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 80)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            
                            NavigationLink(destination: InfoView()) { //info
                                Image("top button=normal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 80)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                        .padding(.top, 50)
                        
                    }
                    
                    
                }
            }
            .navigationBarHidden(true)
            
        }
        .navigationBarHidden(true)
    }
}
