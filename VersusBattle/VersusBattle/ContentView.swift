

import SwiftUI

struct ContentView: View {
    @StateObject private var versusBattleGameEngine = VersusBattleGameEngine()
    
    var body: some View {
        NavigationView {
            ZStack {
                switch versusBattleGameEngine.versusBattleGameState.versusBattleCurrentPhase {
                case .menu:
                    VersusBattleMainMenuView(versusBattleGameEngine: versusBattleGameEngine)
                case .healthSelection:
                    VersusBattleHealthSelectionView(versusBattleGameEngine: versusBattleGameEngine)
                case .playing:
                    VersusBattleGameView(versusBattleGameEngine: versusBattleGameEngine)
                case .gameOver:
                    VersusBattleMainMenuView(versusBattleGameEngine: versusBattleGameEngine)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures proper iPad compatibility
        .supportedOrientations(.portrait) // Force portrait mode
    }
}

// Extension to support portrait orientation lock (iOS 14 compatible)
extension View {
    func supportedOrientations(_ orientations: UIInterfaceOrientationMask) -> some View {
        return self.onAppear {
            // For iOS 14 compatibility, we'll handle orientation in the app delegate
            // This is a placeholder that doesn't break compilation
        }
    }
}

#Preview {
    ContentView()
}
