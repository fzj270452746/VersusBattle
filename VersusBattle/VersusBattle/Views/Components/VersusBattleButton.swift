
import SwiftUI

struct VersusBattleButton: View {
    let versusBattleTitle: String
    let versusBattleAction: () -> Void
    let versusBattleStyle: VersusBattleButtonStyle
    let versusBattleIsEnabled: Bool
    
    @State private var versusBattleIsPressed = false
    
    init(
        title: String,
        style: VersusBattleButtonStyle = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.versusBattleTitle = title
        self.versusBattleAction = action
        self.versusBattleStyle = style
        self.versusBattleIsEnabled = isEnabled
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(versusBattleTitle)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(versusBattleTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(versusBattleBackgroundGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(versusBattleBorderColor, lineWidth: 2)
        )
        .shadow(color: versusBattleShadowColor, radius: versusBattleIsPressed ? 2 : 6, x: 0, y: versusBattleIsPressed ? 1 : 3)
        .opacity(versusBattleIsEnabled ? 1.0 : 0.6)
        .onTapGesture {
            if versusBattleIsEnabled {
                versusBattleAction()
            }
        }
    }
    
    private var versusBattleBackgroundGradient: LinearGradient {
        switch versusBattleStyle {
        case .primary:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .destructive:
            return LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .success:
            return LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var versusBattleTextColor: Color {
        return .white
    }
    
    private var versusBattleBorderColor: Color {
        return Color.white.opacity(0.3)
    }
    
    private var versusBattleShadowColor: Color {
        switch versusBattleStyle {
        case .primary:
            return Color.blue.opacity(0.4)
        case .secondary:
            return Color.gray.opacity(0.4)
        case .destructive:
            return Color.red.opacity(0.4)
        case .success:
            return Color.green.opacity(0.4)
        }
    }
}

enum VersusBattleButtonStyle {
    case primary
    case secondary
    case destructive
    case success
}

struct VersusBattleIconButton: View {
    let versusBattleSystemName: String
    let versusBattleAction: () -> Void
    let versusBattleSize: CGFloat
    let versusBattleColor: Color
    
    @State private var versusBattleIsPressed = false
    
    init(
        systemName: String,
        size: CGFloat = 24,
        color: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.versusBattleSystemName = systemName
        self.versusBattleAction = action
        self.versusBattleSize = size
        self.versusBattleColor = color
    }
    
    var body: some View {
        Button {
            versusBattleAction()
        } label: {
            Image(systemName: versusBattleSystemName)
                .font(.system(size: versusBattleSize, weight: .bold))
                .foregroundColor(.white)
                .frame(width: versusBattleSize + 16, height: versusBattleSize + 16)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [versusBattleColor, versusBattleColor.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: versusBattleColor.opacity(0.4), radius: versusBattleIsPressed ? 2 : 4, x: 0, y: versusBattleIsPressed ? 1 : 2)
        }
        .scaleEffect(versusBattleIsPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0), value: versusBattleIsPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            versusBattleIsPressed = pressing
        }, perform: {})
    }
}
