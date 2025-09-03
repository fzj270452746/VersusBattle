

import SwiftUI

struct VersusBattleHealthSelectionView: View {
    @ObservedObject var versusBattleGameEngine: VersusBattleGameEngine
    @State private var versusBattleSelectedHealth: Double = 1000
    
    private let versusBattleMinHealth: Double = 500
    private let versusBattleMaxHealth: Double = 2500
    private let versusBattleHealthStep: Double = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (底层)
                Image("versback")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .opacity(0.3) // 适中的透明度
                    .ignoresSafeArea()
                
                // Background gradient overlay (中层，增强对比度)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.9),
                        Color.purple.opacity(0.8),
                        Color.pink.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        VersusBattleIconButton(
                            systemName: "arrow.left",
                            size: 20,
                            color: .white.opacity(0.8)
                        ) {
                            versusBattleGameEngine.versusBattleGameState.versusBattleCurrentPhase = .menu
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        
                        Text("Select Battle Health")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    // Health display
                    VStack(spacing: 15) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            VStack(spacing: 12) {
                                Text("Battle Health")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("\(Int(versusBattleSelectedHealth))")
                                    .font(.system(size: 48, weight: .black, design: .rounded))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                
                                Text("HP for both players")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(24)
                        }
                        .padding(.horizontal, 32)
                        
                        // Health slider
                        VStack(spacing: 16) {
                            HStack {
                                Text("\(Int(versusBattleMinHealth))")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text("\(Int(versusBattleMaxHealth))")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 32)
                            
                            Slider(
                                value: $versusBattleSelectedHealth,
                                in: versusBattleMinHealth...versusBattleMaxHealth,
                                step: versusBattleHealthStep
                            ) {
                                // Slider customization
                            }
                            .accentColor(.yellow)
                            .padding(.horizontal, 32)
                        }
                        
                        // Health recommendations
                        VStack(spacing: 8) {
                            Text("Recommended Settings")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                VersusBattleQuickHealthButton(versusBattleHealth: 500, versusBattleLabel: "Quick", versusBattleSelectedHealth: $versusBattleSelectedHealth)
                                VersusBattleQuickHealthButton(versusBattleHealth: 1000, versusBattleLabel: "Normal", versusBattleSelectedHealth: $versusBattleSelectedHealth)
                                VersusBattleQuickHealthButton(versusBattleHealth: 1500, versusBattleLabel: "Long", versusBattleSelectedHealth: $versusBattleSelectedHealth)
                                VersusBattleQuickHealthButton(versusBattleHealth: 2500, versusBattleLabel: "Epic", versusBattleSelectedHealth: $versusBattleSelectedHealth)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Start battle button
                    VStack(spacing: 16) {
                        VersusBattleButton(
                            title: "Start Battle",
                            style: .primary
                        ) {
                            versusBattleGameEngine.versusBattleGameState.versusBattleStartVersusMode(health: Int(versusBattleSelectedHealth))
                        }
                        .padding(.horizontal, 32)
                        
                        Text("Both players will start with \(Int(versusBattleSelectedHealth)) HP")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                .padding(.vertical, 24)
            }
        }
        .onAppear {
            versusBattleSelectedHealth = Double(versusBattleGameEngine.versusBattleGameState.versusBattleSelectedHealth)
        }
    }
}

struct VersusBattleQuickHealthButton: View {
    let versusBattleHealth: Double
    let versusBattleLabel: String
    @Binding var versusBattleSelectedHealth: Double
    
    private var versusBattleIsSelected: Bool {
        versusBattleSelectedHealth == versusBattleHealth
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                versusBattleSelectedHealth = versusBattleHealth
            }
        }) {
            VStack(spacing: 4) {
                Text(versusBattleLabel)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(versusBattleIsSelected ? .black : .white)
                
                Text("\(Int(versusBattleHealth))")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(versusBattleIsSelected ? .black : .white.opacity(0.8))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(versusBattleIsSelected ? Color.yellow : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(versusBattleIsSelected ? Color.orange : Color.white.opacity(0.3), lineWidth: versusBattleIsSelected ? 2 : 1)
                    )
            )
        }
        .scaleEffect(versusBattleIsSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: versusBattleIsSelected)
    }
}
