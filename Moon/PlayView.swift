

import SwiftUI

struct PlayView: View {
    
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
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
                        
                        VStack(alignment: .center, spacing: -10) {
                            
                            
                            ZStack {
                                Image("button=inactive") // br price
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 80)
                                
                                HStack(spacing: 10) {
                                    
                                    Image("Property 1=normal")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                    
                                    
                                    HStack(spacing: 10) {
                                        Image("Сurrency - Сoin")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                            //.offset(x: 40)
                                        
                                        
                                        Text("0.666")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Image("Right__bottom_button=normal-2") // rigth
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                    
                                }
                            }
                            
                        }
                    }
                    
                    
                    ZStack {
                        Image("score_header_frame") // bgr curren user moneu
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 100) {
                            Image("Сurrency - Сoin")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .offset(x: 40)
                                
                            
                            Text("0.666")
                                .font(.title)
                                .foregroundColor(.white)
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
                        
                        
                        Button(action: {
                            gameState.toggleSound()
                        }) {
                            Image("question_top_button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                        
                        
                        Button(action: {
                            gameState.toggleSound()
                        }) {
                            Image("top button=normal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                        }
                        
                        
                    }
                    .padding(.top, 50)
                    
                }
                
                
            }
        }
        .navigationBarHidden(true)

    }
}
