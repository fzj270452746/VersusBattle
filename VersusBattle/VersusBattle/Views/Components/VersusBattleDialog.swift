
import SwiftUI

struct VersusBattleDialog<Content: View>: View {
    let versusBattleContent: Content
    let versusBattleIsPresented: Binding<Bool>
    
    @State private var versusBattleScale: CGFloat = 0.8
    @State private var versusBattleOpacity: Double = 0.0
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.versusBattleIsPresented = isPresented
        self.versusBattleContent = content()
    }
    
    var body: some View {
        ZStack {
            if versusBattleIsPresented.wrappedValue {
                // Background image (subtle)
                Image("versback")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                // Background overlay
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        versusBattleDismiss()
                    }
                
                // Dialog content
                versusBattleContent
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.9)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    )
                    .scaleEffect(versusBattleScale)
                    .opacity(versusBattleOpacity)
                    .onAppear {
                        versusBattleShowDialog()
                    }
                    .onDisappear {
                        versusBattleScale = 0.8
                        versusBattleOpacity = 0.0
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: versusBattleIsPresented.wrappedValue)
    }
    
    private func versusBattleShowDialog() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
            versusBattleScale = 1.0
            versusBattleOpacity = 1.0
        }
    }
    
    private func versusBattleDismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
            versusBattleScale = 0.8
            versusBattleOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            versusBattleIsPresented.wrappedValue = false
        }
    }
}

struct VersusBattleAlert: View {
    let versusBattleTitle: String
    let versusBattleMessage: String
    let versusBattlePrimaryButton: VersusBattleAlertButton?
    let versusBattleSecondaryButton: VersusBattleAlertButton?
    let versusBattleIsPresented: Binding<Bool>
    
    init(
        title: String,
        message: String,
        isPresented: Binding<Bool>,
        primaryButton: VersusBattleAlertButton? = nil,
        secondaryButton: VersusBattleAlertButton? = nil
    ) {
        self.versusBattleTitle = title
        self.versusBattleMessage = message
        self.versusBattleIsPresented = isPresented
        self.versusBattlePrimaryButton = primaryButton
        self.versusBattleSecondaryButton = secondaryButton
    }
    
    var body: some View {
        VersusBattleDialog(isPresented: versusBattleIsPresented) {
            VStack(spacing: 20) {
                // Title
                Text(versusBattleTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                // Message
                Text(versusBattleMessage)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                // Buttons
                VStack(spacing: 12) {
                    if let primaryButton = versusBattlePrimaryButton {
                        VersusBattleButton(
                            title: primaryButton.versusBattleTitle,
                            style: primaryButton.versusBattleStyle,
                            action: {
                                primaryButton.versusBattleAction()
                                versusBattleIsPresented.wrappedValue = false
                            }
                        )
                    }
                    
                    if let secondaryButton = versusBattleSecondaryButton {
                        VersusBattleButton(
                            title: secondaryButton.versusBattleTitle,
                            style: .secondary,
                            action: {
                                secondaryButton.versusBattleAction()
                                versusBattleIsPresented.wrappedValue = false
                            }
                        )
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .frame(maxWidth: 360)
        }
    }
}

struct VersusBattleAlertButton {
    let versusBattleTitle: String
    let versusBattleStyle: VersusBattleButtonStyle
    let versusBattleAction: () -> Void
    
    init(title: String, style: VersusBattleButtonStyle = .primary, action: @escaping () -> Void) {
        self.versusBattleTitle = title
        self.versusBattleStyle = style
        self.versusBattleAction = action
    }
}

struct VersusBattleHealthBar: View {
    let versusBattleCurrentHealth: Int
    let versusBattleMaxHealth: Int
    let versusBattleColor: Color
    let versusBattleLabel: String
    
    private var versusBattleHealthPercentage: Double {
        guard versusBattleMaxHealth > 0 else { return 0 }
        return Double(versusBattleCurrentHealth) / Double(versusBattleMaxHealth)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text(versusBattleLabel)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(versusBattleCurrentHealth)/\(versusBattleMaxHealth)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Health bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [versusBattleColor, versusBattleColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * versusBattleHealthPercentage)
                        .animation(.easeInOut(duration: 0.5), value: versusBattleHealthPercentage)
                    
                    // Shine effect
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: geometry.size.width * versusBattleHealthPercentage)
                }
            }
            .frame(height: 12)
        }
    }
}
