

import SwiftUI

struct VersusBattleMainMenuView: View {
    @ObservedObject var versusBattleGameEngine: VersusBattleGameEngine
    @State private var versusBattleShowGameRules = false
    @State private var versusBattleShowFeedback = false
    @State private var versusBattleTitleScale: CGFloat = 1.0
    @State private var versusBattleParticleOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (底层)
                Image("versback")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: UIScreen.main.bounds.height)
//                    .clipped()
//                    .opacity(0.7) // 降低透明度，确保UI元素可见
                    .ignoresSafeArea()
                
                // Background gradient overlay (中层，增强对比度)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.4),
                        Color.pink.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating particles
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 4...12))
                        .offset(
                            x: CGFloat.random(in: -geometry.size.width/2...geometry.size.width/2),
                            y: versusBattleParticleOffset + CGFloat.random(in: -100...100)
                        )
                        .animation(
                            .linear(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: false),
                            value: versusBattleParticleOffset
                        )
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Game title
                    VStack(spacing: 16) {
                        Text("Mahjong")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Text("Versus")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                    }
                    .scaleEffect(versusBattleTitleScale)
                    .onAppear {
                        versusBattleStartTitleAnimation()
                    }
                    
                    Spacer()
                    
                    // Menu buttons
                    VStack(spacing: 20) {
                        // Versus mode button
                        VersusBattleButton(
                            title: "Versus Battle",
                            style: .primary
                        ) {
                            DispatchQueue.main.async {
                                versusBattleGameEngine.versusBattleGameState.versusBattleCurrentPhase = .healthSelection
                                versusBattleGameEngine.versusBattleGameState.versusBattleCurrentMode = .versus
                            }
                        }
                        
                        // Adventure mode button
                        VersusBattleButton(
                            title: "Adventure Mode (Level \(versusBattleGameEngine.versusBattleGameState.versusBattleHighestLevel))",
                            style: .success
                        ) {
                            versusBattleGameEngine.versusBattleGameState.versusBattleStartAdventureMode()
                        }
                        
                        // Game rules button
                        VersusBattleButton(
                            title: "Game Rules",
                            style: .secondary
                        ) {
                            versusBattleShowGameRules = true
                        }
                        
                        // Feedback button
                        VersusBattleButton(
                            title: "Feedback",
                            style: .secondary
                        ) {
                            versusBattleShowFeedback = true
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            versusBattleGameEngine.versusBattleGameState.versusBattleLoadHighestLevel()
            versusBattleStartParticleAnimation()
        }
        .overlay(
            // Game rules dialog
            VersusBattleAlert(
                title: "Game Rules",
                message: versusBattleGameRulesText,
                isPresented: $versusBattleShowGameRules,
                primaryButton: VersusBattleAlertButton(title: "Got it!", style: .primary) {}
            )
        )
        .overlay(
            // Feedback view
            Group {
                if versusBattleShowFeedback {
                    VersusBattleFeedbackView(isPresented: $versusBattleShowFeedback)
                }
            }
        )
    }
    
    private func versusBattleStartTitleAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            versusBattleTitleScale = 1.05
        }
    }
    
    private func versusBattleStartParticleAnimation() {
        withAnimation(.linear(duration: 0)) {
            versusBattleParticleOffset = -1000
        }
        
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            versusBattleParticleOffset = 1000
        }
    }
    
    private var versusBattleGameRulesText: String {
        """
        🀄️ FISH MAHJONG VERSUS RULES 🀄️
        
        CARD TYPES:
        • Damage Cards: Bing (筒), Tenth (万), Slip (条) with values 1-9
        • Heal Cards: Feng cards for recovery
        • Skill Cards: Percentage damage cards
        
        COMBINATIONS:
        • Pair (2 same): Basic effect
        • Triplet (3 same): Enhanced effect
        • Quad (4 same): Maximum effect
        • Sequence (3 consecutive same suit): Damage only
        
        EFFECTS:
        • Damage: Deal value as damage (x3 for Quad)
        • Heal: Restore 2%/3%/5% of max health
        • Skill: Deal 2%/3%/5% of enemy max health
        
        WIN CONDITIONS:
        • Reduce enemy health to 0
        • Enemy exceeds 16 cards
        
        LOSE CONDITIONS:
        • Your health reaches 0
        • Your hand exceeds 16 cards
        """
    }
}
