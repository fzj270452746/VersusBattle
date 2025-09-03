
import SwiftUI

struct VersusBattleCardView: View {
    let versusBattleCard: VersusBattleCard
    let versusBattleIsSelected: Bool
    let versusBattleOnTap: () -> Void
    let versusBattleShowBackground: Bool
    
    @State private var versusBattleIsPressed = false
    
    // 便利构造器，默认显示背景
    init(versusBattleCard: VersusBattleCard, versusBattleIsSelected: Bool, versusBattleOnTap: @escaping () -> Void) {
        self.versusBattleCard = versusBattleCard
        self.versusBattleIsSelected = versusBattleIsSelected
        self.versusBattleOnTap = versusBattleOnTap
        self.versusBattleShowBackground = true
    }
    
    // 完整构造器，可控制是否显示背景
    init(versusBattleCard: VersusBattleCard, versusBattleIsSelected: Bool, versusBattleOnTap: @escaping () -> Void, versusBattleShowBackground: Bool) {
        self.versusBattleCard = versusBattleCard
        self.versusBattleIsSelected = versusBattleIsSelected
        self.versusBattleOnTap = versusBattleOnTap
        self.versusBattleShowBackground = versusBattleShowBackground
    }
    
    var body: some View {
        ZStack {
            if versusBattleShowBackground {
                // Card background with gradient
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: versusBattleCardColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: versusBattleIsSelected ? .blue : .black.opacity(0.3), radius: versusBattleIsSelected ? 8 : 4, x: 0, y: 2)
                
                // Card border
                RoundedRectangle(cornerRadius: 12)
                    .stroke(versusBattleIsSelected ? Color.blue : Color.white.opacity(0.3), lineWidth: versusBattleIsSelected ? 3 : 1)
            }
            
            VStack(spacing: 4) {
                // Card image with fallback
                if versusBattleShowBackground {
                    Image(versusBattleCard.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(versusBattleCard.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Rectangle())
                }
            }
            .padding(versusBattleShowBackground ? 8 : 0)
        }
        .scaleEffect(versusBattleIsPressed ? 0.95 : (versusBattleIsSelected ? 1.1 : 1.0))
        .offset(y: versusBattleIsSelected ? -10 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: versusBattleIsSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0), value: versusBattleIsPressed)
        .onTapGesture {
            versusBattleOnTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            versusBattleIsPressed = pressing
        }, perform: {})
    }
    
    private var versusBattleCardColors: [Color] {
        guard let firstCard = [versusBattleCard].first else {
            return [Color.gray, Color.gray.opacity(0.7)]
        }
        
        switch firstCard.type {
        case .damage(let damageType):
            switch damageType {
            case .bing:
                return [Color.blue, Color.blue.opacity(0.7)]
            case .tenth:
                return [Color.red, Color.red.opacity(0.7)]
            case .slip:
                return [Color.green, Color.green.opacity(0.7)]
            }
        case .heal:
            return [Color.pink, Color.pink.opacity(0.7)]
        case .percentDamage:
            return [Color.purple, Color.purple.opacity(0.7)]
        }
    }
    
    private var versusBattleCardTypeText: String {
        switch versusBattleCard.type {
        case .damage(let damageType):
            switch damageType {
            case .bing: return "筒"
            case .tenth: return "万"
            case .slip: return "条"
            }
        case .heal: return "风"
        case .percentDamage: return "技"
        }
    }
    

}

struct VersusBattleHandView: View {
    let versusBattleCards: [VersusBattleCard]
    let versusBattleSelectedCards: Set<VersusBattleCard>
    let versusBattleOnCardTap: (VersusBattleCard) -> Void
    let versusBattleIsPlayerTurn: Bool
    
    // 动态计算列数：8张以下用4列，9-12张用5列，12张以上用6列
    private var versusBattleColumnsPerRow: Int {
        if versusBattleCards.count <= 8 {
            return 4
        } else if versusBattleCards.count <= 12 {
            return 5
        } else {
            return 6
        }
    }
    
    // 动态计算卡片大小
    private var versusBattleCardSize: CGSize {
        if versusBattleCards.count <= 8 {
            return CGSize(width: 70, height: 90)
        } else if versusBattleCards.count <= 12 {
            return CGSize(width: 60, height: 75)
        } else {
            return CGSize(width: 50, height: 65)
        }
    }
    
    var body: some View {
        // 使用固定大小的网格项而不是flexible，避免间距不均匀
        let columns = Array(repeating: GridItem(.fixed(versusBattleCardSize.width), spacing: 4), count: versusBattleColumnsPerRow)
        

        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(versusBattleCards.enumerated()), id: \.element.id) { index, card in
                VersusBattleCardView(
                    versusBattleCard: card,
                    versusBattleIsSelected: versusBattleSelectedCards.contains(card),
                    versusBattleOnTap: {
                        if versusBattleIsPlayerTurn {
                            versusBattleOnCardTap(card)
                        }
                    }
                )
                .frame(width: versusBattleCardSize.width, height: versusBattleCardSize.height)
                .disabled(!versusBattleIsPlayerTurn)
                .opacity(versusBattleIsPlayerTurn ? 1.0 : 0.7)

            }
        }
        .padding(.horizontal, 12)
    }
}
