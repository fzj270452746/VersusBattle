

import SwiftUI

struct VersusBattleGameView: View {
    @ObservedObject var versusBattleGameEngine: VersusBattleGameEngine
    
    @State private var versusBattleShowPauseMenu = false
    @State private var versusBattleShowInvalidMoveAlert = false
    
    private var versusBattleIsPlayerTurn: Bool {
        versusBattleGameEngine.versusBattleGameState.versusBattleCurrentPlayer == .player
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (底层)
                Image("versback")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .opacity(0.8) // 更低的透明度，确保游戏元素清晰可见
                    .ignoresSafeArea()
                
                // Background gradient overlay (中层，增强对比度)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.5),
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with health bars and controls (compressed)
                    versusBattleGameHeader
                    
                    // Game area - using minimal space for middle sections
                    VStack(spacing: 4) {
                        // Enemy hand (hidden) - compressed
                        versusBattleEnemyHandSection
                        
                        // Battle status - highly compressed
                        versusBattleBattleStatusSection
                        
                        // Flexible spacer to push player hand to bottom
                        Spacer()
                            .frame(minHeight: 10, maxHeight: 40)
                        
                        // Player hand - flexible space
                        versusBattlePlayerHandSection
                        
                        // Action buttons - compressed
                        versusBattleActionButtons
                    }
                    .padding(.vertical, 4)
                }
                
                // Damage animation overlay
                if versusBattleGameEngine.versusBattleGameState.versusBattleIsAnimatingDamage {
                    versusBattleDamageAnimationOverlay
                }
                
                // Heal animation overlay
                if versusBattleGameEngine.versusBattleGameState.versusBattleIsAnimatingHeal {
                    versusBattleHealAnimationOverlay
                }
            }
        }
        .onReceive(versusBattleGameEngine.versusBattleGameState.$versusBattleCurrentPlayer) { player in
            if player == .enemy {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    versusBattleGameEngine.versusBattleExecuteAITurn()
                }
            }
        }
        .onReceive(versusBattleGameEngine.versusBattleGameState.$versusBattleShowInvalidMoveAlert) { show in
            versusBattleShowInvalidMoveAlert = show
        }
        .overlay(
            // Pause menu
            VersusBattleAlert(
                title: "Game Paused",
                message: "What would you like to do?",
                isPresented: $versusBattleShowPauseMenu,
                primaryButton: VersusBattleAlertButton(title: "Resume", style: .primary) {},
                secondaryButton: VersusBattleAlertButton(title: "Main Menu", style: .secondary) {
                    versusBattleGameEngine.versusBattleGameState.versusBattleCurrentPhase = .menu
                }
            )
        )
        .overlay(
            // Invalid move alert
            VersusBattleAlert(
                title: "Invalid Move",
                message: "Selected cards don't form a valid combination. Please try again!",
                isPresented: $versusBattleShowInvalidMoveAlert,
                primaryButton: VersusBattleAlertButton(title: "OK", style: .primary) {
                    versusBattleGameEngine.versusBattleGameState.versusBattleShowInvalidMoveAlert = false
                }
            )
        )
        .overlay(
            // Game over dialog
            VersusBattleGameOverDialog(versusBattleGameEngine: versusBattleGameEngine)
        )
    }
    
    private var versusBattleGameHeader: some View {
        VStack(spacing: 4) {
            // Top controls - ultra compressed
            HStack {
                VersusBattleIconButton(
                    systemName: "pause.fill",
                    size: 14,
                    color: .gray
                ) {
                    versusBattleShowPauseMenu = true
                }
                
                Spacer()
                
                // Current turn indicator - smaller
                Text(versusBattleIsPlayerTurn ? "Your Turn" : "Enemy Turn")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(versusBattleIsPlayerTurn ? .blue : .red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                    )
                
                Spacer()
                
                // Level indicator (for adventure mode) - smaller
                if versusBattleGameEngine.versusBattleGameState.versusBattleCurrentMode == .adventure {
                    Text("Lv.\(versusBattleGameEngine.versusBattleGameState.versusBattleCurrentLevel)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.purple.opacity(0.6))
                        )
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 16)
            
            // Health bars - ultra compressed
            VStack(spacing: 3) {
                VersusBattleHealthBar(
                    versusBattleCurrentHealth: versusBattleGameEngine.versusBattleGameState.versusBattleEnemyHealth,
                    versusBattleMaxHealth: versusBattleGameEngine.versusBattleGameState.versusBattleEnemyMaxHealth,
                    versusBattleColor: .red,
                    versusBattleLabel: "Enemy"
                )
                
                VersusBattleHealthBar(
                    versusBattleCurrentHealth: versusBattleGameEngine.versusBattleGameState.versusBattlePlayerHealth,
                    versusBattleMaxHealth: versusBattleGameEngine.versusBattleGameState.versusBattlePlayerMaxHealth,
                    versusBattleColor: .blue,
                    versusBattleLabel: "Player"
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.1))
    }
    
    private var versusBattleEnemyHandSection: some View {
        VStack(spacing: 3) {
            HStack {
                Text("Enemy (\(versusBattleGameEngine.versusBattleGameState.versusBattleEnemyHand.count))")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Hidden enemy cards - ultra compact  
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: min(9, versusBattleGameEngine.versusBattleGameState.versusBattleEnemyHand.count)), spacing: 3) {
                ForEach(0..<versusBattleGameEngine.versusBattleGameState.versusBattleEnemyHand.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 36)
                        .overlay(
                            Image(systemName: "questionmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        )
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private var versusBattleBattleStatusSection: some View {
        VStack(spacing: 1) {
            if let lastCombination = versusBattleGameEngine.versusBattleGameState.versusBattleLastPlayedCombination {
                VStack(spacing: 1) {
                    HStack(spacing: 3) {
                        ForEach(lastCombination.cards) { card in
                            VersusBattleCardView(
                                versusBattleCard: card,
                                versusBattleIsSelected: false,
                                versusBattleOnTap: {},
                                versusBattleShowBackground: false
                            )
                            .frame(width: 32, height: 42)
                        }
                    }
                    
                    Text(versusBattleCombinationTypeText(lastCombination.type))
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 12)
            }
        }
        .frame(maxHeight: 55)
    }
    
    private var versusBattlePlayerHandSection: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Your Hand (\(versusBattleGameEngine.versusBattleGameState.versusBattlePlayerHand.count))")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.isEmpty {
                    Text("\(versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.count) sel")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            
            VersusBattleHandView(
                versusBattleCards: versusBattleGameEngine.versusBattleGameState.versusBattlePlayerHand,
                versusBattleSelectedCards: versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards,
                versusBattleOnCardTap: { card in
                    versusBattleToggleCardSelection(card)
                },
                versusBattleIsPlayerTurn: versusBattleIsPlayerTurn
            )
        }
    }
    
    private var versusBattleActionButtons: some View {
        HStack(spacing: 12) {
            // Clear selection button
            VersusBattleButton(
                title: "Clear",
                style: .secondary,
                isEnabled: !versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.isEmpty
            ) {
                versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.removeAll()
            }
            
            // Skip turn button
            VersusBattleButton(
                title: "Skip",
                style: .secondary,
                isEnabled: versusBattleIsPlayerTurn
            ) {
                versusBattleGameEngine.versusBattleSkipTurn()
            }
            
            // Play cards button
            VersusBattleButton(
                title: "Play",
                style: .primary,
                isEnabled: versusBattleIsPlayerTurn && !versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.isEmpty
            ) {
                let selectedCards = Array(versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards)
                if versusBattleGameEngine.versusBattlePlayCards(selectedCards) {
                    versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.removeAll()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private var versusBattleDamageAnimationOverlay: some View {
        ZStack {
            Color.red.opacity(0.3)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: versusBattleGameEngine.versusBattleGameState.versusBattleIsAnimatingDamage)
            
            Text("-\(versusBattleGameEngine.versusBattleGameState.versusBattleDamageAmount)")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.red)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                .scaleEffect(2.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: versusBattleGameEngine.versusBattleGameState.versusBattleIsAnimatingDamage)
        }
    }
    
    private var versusBattleHealAnimationOverlay: some View {
        ZStack {
            Color.green.opacity(0.3)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: versusBattleGameEngine.versusBattleGameState.versusBattleIsAnimatingHeal)
            
            Text("+\(versusBattleGameEngine.versusBattleGameState.versusBattleHealAmount)")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.green)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                .scaleEffect(2.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: versusBattleGameEngine.versusBattleGameState.versusBattleIsAnimatingHeal)
        }
    }
    
    private func versusBattleToggleCardSelection(_ card: VersusBattleCard) {
        if versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.contains(card) {
            versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.remove(card)
        } else {
            versusBattleGameEngine.versusBattleGameState.versusBattleSelectedCards.insert(card)
        }
    }
    
    private func versusBattleCombinationTypeText(_ type: VersusBattleCombinationType) -> String {
        switch type {
        case .single:
            return "Single"
        case .pair:
            return "Pair"
        case .triplet:
            return "Triplet"
        case .quad:
            return "Quad"
        case .sequence:
            return "Sequence"
        }
    }
}

struct VersusBattleGameOverDialog: View {
    @ObservedObject var versusBattleGameEngine: VersusBattleGameEngine
    
    var body: some View {
        VersusBattleAlert(
            title: versusBattleDialogTitle,
            message: versusBattleDialogMessage,
            isPresented: $versusBattleGameEngine.versusBattleGameState.versusBattleShowGameOverDialog,
            primaryButton: VersusBattleAlertButton(
                title: versusBattlePrimaryButtonTitle,
                style: versusBattleGameEngine.versusBattleGameState.versusBattleGameResult == .victory ? .success : .primary
            ) {
                versusBattleHandlePrimaryAction()
            },
            secondaryButton: VersusBattleAlertButton(title: "Main Menu", style: .secondary) {
                versusBattleGameEngine.versusBattleGameState.versusBattleCurrentPhase = .menu
            }
        )
    }
    
    private var versusBattleDialogTitle: String {
        switch versusBattleGameEngine.versusBattleGameState.versusBattleGameResult {
        case .victory:
            return versusBattleGameEngine.versusBattleGameState.versusBattleCurrentMode == .adventure ? "Level Complete!" : "Victory!"
        case .defeat:
            return "Defeat"
        case .ongoing:
            return ""
        }
    }
    
    private var versusBattleDialogMessage: String {
        switch versusBattleGameEngine.versusBattleGameState.versusBattleGameResult {
        case .victory:
            if versusBattleGameEngine.versusBattleGameState.versusBattleCurrentMode == .adventure {
                return "Congratulations! You've completed level \(versusBattleGameEngine.versusBattleGameState.versusBattleCurrentLevel - 1). Ready for the next challenge?"
            } else {
                let reason = versusBattleGameEngine.versusBattleGameState.versusBattleGameEndReason
                if reason == .tooManyCards {
                    return "Victory! Your opponent accumulated too many cards (over 18) and lost!"
                } else {
                    return "Excellent! You've defeated your opponent in battle!"
                }
            }
        case .defeat:
            let reason = versusBattleGameEngine.versusBattleGameState.versusBattleGameEndReason
            if reason == .tooManyCards {
                return "Defeat! You accumulated too many cards (over 18). Try to play cards more frequently to avoid this!"
            } else {
                return "Better luck next time! Keep practicing to improve your strategy."
            }
        case .ongoing:
            return ""
        }
    }
    
    private var versusBattlePrimaryButtonTitle: String {
        switch versusBattleGameEngine.versusBattleGameState.versusBattleGameResult {
        case .victory:
            return versusBattleGameEngine.versusBattleGameState.versusBattleCurrentMode == .adventure ? "Next Level" : "Play Again"
        case .defeat:
            return "Try Again"
        case .ongoing:
            return ""
        }
    }
    
    private func versusBattleHandlePrimaryAction() {
        switch versusBattleGameEngine.versusBattleGameState.versusBattleGameResult {
        case .victory:
            if versusBattleGameEngine.versusBattleGameState.versusBattleCurrentMode == .adventure {
                // Next level is already handled in the game state
            } else {
                versusBattleGameEngine.versusBattleGameState.versusBattleCurrentPhase = .healthSelection
            }
        case .defeat:
            if versusBattleGameEngine.versusBattleGameState.versusBattleCurrentMode == .adventure {
                versusBattleGameEngine.versusBattleGameState.versusBattleStartAdventureMode()
            } else {
                versusBattleGameEngine.versusBattleGameState.versusBattleCurrentPhase = .healthSelection
            }
        case .ongoing:
            break
        }
    }
}
