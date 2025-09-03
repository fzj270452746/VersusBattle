

import Foundation

enum VersusBattleCardType {
    case damage(VersusBattleDamageCardType)
    case heal(VersusBattleHealCardType)
    case percentDamage(VersusBattlePercentDamageCardType)
}

enum VersusBattleDamageCardType: String, CaseIterable {
    case bing = "bing"
    case tenth = "tenth"
    case slip = "slip"
}

enum VersusBattleHealCardType: String, CaseIterable {
    case feng1 = "feng-1"
    case feng2 = "feng-2"
    case feng3 = "feng-3"
    case feng4 = "feng-4"
}

enum VersusBattlePercentDamageCardType: String, CaseIterable {
    case skill1 = "skill-1"
    case skill2 = "skill-2"
    case skill3 = "skill-3"
}

struct VersusBattleCard: Identifiable, Equatable, Hashable {
    let id = UUID()
    let type: VersusBattleCardType
    let value: Int
    let imageName: String
    
    init(type: VersusBattleCardType, value: Int) {
        self.type = type
        self.value = value
        
        switch type {
        case .damage(let damageType):
            self.imageName = "Versus-\(damageType.rawValue)-\(value)"
        case .heal(let healType):
            self.imageName = "Versus-\(healType.rawValue)"
        case .percentDamage(let skillType):
            self.imageName = "Versus-\(skillType.rawValue)"
        }
    }
    
    static func == (lhs: VersusBattleCard, rhs: VersusBattleCard) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Card Combination Types
enum VersusBattleCombinationType {
    case single // 单张牌 (仅限伤害牌)
    case pair // 对子
    case triplet // 刻子 (3张相同)
    case quad // 杠 (4张相同)
    case sequence // 顺子 (3张连续)
}

struct VersusBattleCardCombination {
    let cards: [VersusBattleCard]
    let type: VersusBattleCombinationType
    
    init(cards: [VersusBattleCard], type: VersusBattleCombinationType) {
        self.cards = Self.versusBattleSortCards(cards)
        self.type = type
    }
    
    var versusBattleDamage: Int {
        switch type {
        case .single:
            return cards.first?.value ?? 0
        case .pair:
            return cards.reduce(0) { $0 + $1.value }
        case .triplet:
            // 带数值的刻子（伤害牌）伤害翻倍
            let baseDamage = cards.reduce(0) { $0 + $1.value }
            if let firstCard = cards.first, case .damage = firstCard.type {
                return baseDamage * 2
            }
            return baseDamage
        case .sequence:
            // 顺子伤害翻倍
            return cards.reduce(0) { $0 + $1.value } * 2
        case .quad:
            return cards.reduce(0) { $0 + $1.value } * 3
        }
    }
    
    var versusBattleHealPercent: Double {
        switch type {
        case .single:
            return 0.0 // 单张牌不能用于回复
        case .pair:
            return 0.02
        case .triplet:
            // 回复牌的刻子回复量翻倍
            if let firstCard = cards.first, case .heal = firstCard.type {
                return 0.03 * 2  // 翻倍效果
            }
            return 0.03
        case .quad:
            return 0.05
        case .sequence:
            return 0.0 // 顺子不能用于回复
        }
    }
    
    var versusBattlePercentDamage: Double {
        switch type {
        case .single:
            return 0.0 // 单张牌不能用于百分比伤害
        case .pair:
            return 0.02
        case .triplet:
            // 固定比例伤害牌的刻子效果翻倍
            if let firstCard = cards.first, case .percentDamage = firstCard.type {
                return 0.03 * 2  // 翻倍效果
            }
            return 0.03
        case .quad:
            return 0.05
        case .sequence:
            return 0.0 // 顺子不能用于百分比伤害
        }
    }
    
    // 卡牌排序方法，使用与游戏状态中相同的排序逻辑
    static func versusBattleSortCards(_ cards: [VersusBattleCard]) -> [VersusBattleCard] {
        return cards.sorted { card1, card2 in
            // 首先按卡片类型排序：伤害牌 < 回复牌 < 固定比例伤害牌
            let type1Priority = versusBattleGetCardTypePriority(card1.type)
            let type2Priority = versusBattleGetCardTypePriority(card2.type)
            
            if type1Priority != type2Priority {
                return type1Priority < type2Priority
            }
            
            // 同类型卡片按子类型和数值排序
            switch (card1.type, card2.type) {
            case (.damage(let type1), .damage(let type2)):
                if type1 != type2 {
                    return versusBattleGetDamageTypePriority(type1) < versusBattleGetDamageTypePriority(type2)
                }
                return card1.value < card2.value
                
            case (.heal(let type1), .heal(let type2)):
                return versusBattleGetHealTypePriority(type1) < versusBattleGetHealTypePriority(type2)
                
            case (.percentDamage(let type1), .percentDamage(let type2)):
                return versusBattleGetPercentDamageTypePriority(type1) < versusBattleGetPercentDamageTypePriority(type2)
                
            default:
                return card1.value < card2.value
            }
        }
    }
    
    private static func versusBattleGetCardTypePriority(_ type: VersusBattleCardType) -> Int {
        switch type {
        case .damage:
            return 0
        case .heal:
            return 1
        case .percentDamage:
            return 2
        }
    }
    
    private static func versusBattleGetDamageTypePriority(_ type: VersusBattleDamageCardType) -> Int {
        switch type {
        case .bing:
            return 0  // 筒
        case .tenth:
            return 1  // 万
        case .slip:
            return 2  // 条
        }
    }
    
    private static func versusBattleGetHealTypePriority(_ type: VersusBattleHealCardType) -> Int {
        switch type {
        case .feng1:
            return 0
        case .feng2:
            return 1
        case .feng3:
            return 2
        case .feng4:
            return 3
        }
    }
    
    private static func versusBattleGetPercentDamageTypePriority(_ type: VersusBattlePercentDamageCardType) -> Int {
        switch type {
        case .skill1:
            return 0
        case .skill2:
            return 1
        case .skill3:
            return 2
        }
    }
}

// MARK: - Card Factory
class VersusBattleCardFactory {
    static func versusBattleCreateAllCards() -> [VersusBattleCard] {
        var cards: [VersusBattleCard] = []
        
        // 伤害牌 (筒、万、条 各1-9)
        for damageType in VersusBattleDamageCardType.allCases {
            for value in 1...9 {
                cards.append(VersusBattleCard(type: .damage(damageType), value: value))
            }
        }
        
        // 回复牌 (4张)
        for (index, healType) in VersusBattleHealCardType.allCases.enumerated() {
            cards.append(VersusBattleCard(type: .heal(healType), value: index + 1))
        }
        
        // 固定比例伤害牌 (3张)
        for (index, skillType) in VersusBattlePercentDamageCardType.allCases.enumerated() {
            cards.append(VersusBattleCard(type: .percentDamage(skillType), value: index + 1))
        }
        
        return cards
    }
    
    static func versusBattleCreateDeck() -> [VersusBattleCard] {
        var deck: [VersusBattleCard] = []
        
        // 每种牌4张 - 每次都创建新的实例确保ID唯一
        for _ in 0..<4 {
            // 伤害牌 (筒、万、条 各1-9)
            for damageType in VersusBattleDamageCardType.allCases {
                for value in 1...9 {
                    deck.append(VersusBattleCard(type: .damage(damageType), value: value))
                }
            }
            
            // 回复牌 (4张)
            for (index, healType) in VersusBattleHealCardType.allCases.enumerated() {
                deck.append(VersusBattleCard(type: .heal(healType), value: index + 1))
            }
            
            // 固定比例伤害牌 (3张)
            for (index, skillType) in VersusBattlePercentDamageCardType.allCases.enumerated() {
                deck.append(VersusBattleCard(type: .percentDamage(skillType), value: index + 1))
            }
        }
        
        return deck.shuffled()
    }
}
