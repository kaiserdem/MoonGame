

import SwiftUI

struct PlayView: View {
    
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    
    // Поточний індекс світу (збереження в UserDefaults)
    @State private var currentWorldIndex: Int = UserDefaults.standard.integer(forKey: "currentWorldIndex") == 0 ? 0 : UserDefaults.standard.integer(forKey: "currentWorldIndex")
    
    // Поточний світ
    private var currentWorld: WorldModel {
        WorldModel.sampleWorlds[currentWorldIndex]
    }
    
    // Перевірка чи поточний індекс збігається з збереженим
    private var isCurrentIndexSaved: Bool {
        let savedIndex = UserDefaults.standard.integer(forKey: "currentWorldIndex")
        return currentWorldIndex == savedIndex
    }
    
    // Загальна кількість балів (за замовчуванням 0)
    private var totalScore: Int {
        let savedScore = UserDefaults.standard.integer(forKey: "totalScore")
        return savedScore == 0 ? 0 : savedScore
    }
    
    // Ціна поточного рівня
    private var currentLevelPrice: Int {
        return 400 + (currentWorldIndex * 200)
    }
    
    // Функції перемикання
    private func goToPreviousWorld() {
        if currentWorldIndex > 0 {
            currentWorldIndex -= 1
            saveCurrentWorldIndex()
        }
    }
    
    private func goToNextWorld() {
        if currentWorldIndex < WorldModel.sampleWorlds.count - 1 {
            currentWorldIndex += 1
            saveCurrentWorldIndex()
        }
    }
    
    // Збереження індексу в UserDefaults
    private func saveCurrentWorldIndex() {
        UserDefaults.standard.set(currentWorldIndex, forKey: "currentWorldIndex")
    }
    
    // Збереження балів в UserDefaults
    private func saveTotalScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: "totalScore")
    }
    
    // Додавання балів до загальної суми
    private func addScore(_ points: Int) {
        let newTotal = totalScore + points
        saveTotalScore(newTotal)
    }

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
                            
                            
                            Image(currentWorld.isUnlocked ? currentWorld.unlockedImageName : currentWorld.lockedImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                            
                            
                            ZStack {
                                Image("button=inactive") // br price
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: 80)
                                
                                HStack(spacing: 10) {
                                    
                                    Button(action: goToPreviousWorld) {
                                        Image("Property 1=normal")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                    }
                                    .disabled(currentWorldIndex == 0)
                                    
                                    
                                        HStack(spacing: 10) {
                                            
                                            if currentWorld.isUnlocked {
                                                
                                                if isCurrentIndexSaved {
                                                    Image("checkmark top button=Default")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 60, height: 60)
                                                        .offset(x: 40)
                                                } else {
                                                Text("Play")
                                                    .font(AppFonts.title2)
                                                    .foregroundColor(AppColors.Text.brightGreen)
                                                    .offset(x: 40)
                                               }
                                                
                                                
                                            } else {
                                                Image("Сurrency - Сoin")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                            }
                                            
                                            
                                            if currentWorld.isUnlocked {
                                                Spacer()
                                                    .frame(width: 60, height: 60)
                                            } else {
                                                Text("0.666")
                                                    .font(AppFonts.title2)
                                                    .foregroundColor(AppColors.Text.brightGreen)
                                            }
                                        }
                                    
                                    Button(action: goToNextWorld) {
                                        Image("Right__bottom_button=normal-2")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                    }
                                    .disabled(currentWorldIndex == WorldModel.sampleWorlds.count - 1)
                                    
                                }
                            }
                            
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
                                
                            
                            Text("\(totalScore)")
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
