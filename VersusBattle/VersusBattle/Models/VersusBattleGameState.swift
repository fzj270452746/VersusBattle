

import Foundation
import SwiftUI

enum VersusBattleGameMode {
    case versus
    case adventure
}

enum VersusBattleGamePhase {
    case menu
    case healthSelection
    case playing
    case gameOver
}

enum VersusBattleCurrentPlayer {
    case player
    case enemy
}

enum VersusBattleGameResult {
    case victory
    case defeat
    case ongoing
}

enum VersusBattleGameEndReason {
    case healthDepleted
    case tooManyCards
    case none
}

class VersusBattleGameState: ObservableObject {
    @Published var versusBattleCurrentMode: VersusBattleGameMode = .versus
    @Published var versusBattleCurrentPhase: VersusBattleGamePhase = .menu
    @Published var versusBattleCurrentPlayer: VersusBattleCurrentPlayer = .player
    
    // Player stats
    @Published var versusBattlePlayerHealth: Int = 1000
    @Published var versusBattlePlayerMaxHealth: Int = 1000
    @Published var versusBattlePlayerHand: [VersusBattleCard] = []
    @Published var versusBattleSelectedCards: Set<VersusBattleCard> = []
    
    // Enemy stats
    @Published var versusBattleEnemyHealth: Int = 1000
    @Published var versusBattleEnemyMaxHealth: Int = 1000
    @Published var versusBattleEnemyHand: [VersusBattleCard] = []
    
    // Game settings
    @Published var versusBattleSelectedHealth: Int = 1000
    @Published var versusBattleCurrentLevel: Int = 1
    @Published var versusBattleHighestLevel: Int = 1
    
    // Game deck
    @Published var versusBattleDeck: [VersusBattleCard] = []
    
    // UI states
    @Published var versusBattleShowInvalidMoveAlert: Bool = false
    @Published var versusBattleShowGameOverDialog: Bool = false
    @Published var versusBattleLastPlayedCombination: VersusBattleCardCombination?
    @Published var versusBattleGameResult: VersusBattleGameResult = .ongoing
    @Published var versusBattleGameEndReason: VersusBattleGameEndReason = .none
    
    // Animation states
    @Published var versusBattleIsAnimatingDamage: Bool = false
    @Published var versusBattleIsAnimatingHeal: Bool = false
    @Published var versusBattleDamageAmount: Int = 0
    @Published var versusBattleHealAmount: Int = 0
    
    init() {
        // 只初始化基本状态，不发牌
        versusBattleInitializeGame()
    }
    
    func versusBattleInitializeGame() {
        // 只初始化牌堆和基本状态，不发牌
        versusBattleDeck = VersusBattleCardFactory.versusBattleCreateDeck()
        versusBattlePlayerHand = []
        versusBattleEnemyHand = []
        versusBattleSelectedCards = []
        versusBattleCurrentPlayer = Bool.random() ? .player : .enemy
        versusBattleGameResult = .ongoing
        versusBattleGameEndReason = .none
        versusBattleLastPlayedCombination = nil
    }
    
    func versusBattleResetGame() {
        // 重新初始化游戏状态
        versusBattleInitializeGame()
        
        // Deal initial cards
        versusBattleDealCards(to: .player, count: 8)
        versusBattleDealCards(to: .enemy, count: 8)
        
        // 给当前玩家发牌（开始第一个回合）
        versusBattleDealCards(to: versusBattleCurrentPlayer, count: 1)
    }
    
    func versusBattleStartVersusMode(health: Int) {
        versusBattleCurrentMode = .versus
        versusBattlePlayerHealth = health
        versusBattlePlayerMaxHealth = health
        versusBattleEnemyHealth = health
        versusBattleEnemyMaxHealth = health
        versusBattleSelectedHealth = health
        versusBattleCurrentPhase = .playing
        versusBattleResetGame()
    }
    
    func versusBattleStartAdventureMode() {
        versusBattleCurrentMode = .adventure
        versusBattleCurrentLevel = 1
        versusBattlePlayerHealth = 1000
        versusBattlePlayerMaxHealth = 1000
        versusBattleEnemyHealth = versusBattleCalculateEnemyHealthForLevel(versusBattleCurrentLevel)
        versusBattleEnemyMaxHealth = versusBattleEnemyHealth
        versusBattleCurrentPhase = .playing
        versusBattleResetGame()
    }
    
    func versusBattleCalculateEnemyHealthForLevel(_ level: Int) -> Int {
        return 500 + (level - 1) * 200 // 每关增加200血量
    }
    
    func versusBattleDealCards(to player: VersusBattleCurrentPlayer, count: Int) {
        // 检查牌组是否足够，如果不够则重新生成牌组
        if versusBattleDeck.count < count {
            print("牌组不足，重新生成新的牌组...")
            versusBattleDeck = VersusBattleCardFactory.versusBattleCreateDeck()
        }
        
        // 如果重新生成后仍然不够（理论上不应该发生，除非要求的牌数超过整副牌）
        guard versusBattleDeck.count >= count else { 
            print("警告：即使重新生成牌组，仍然无法满足发牌需求")
            return 
        }
        
        let dealtCards = Array(versusBattleDeck.prefix(count))
        versusBattleDeck.removeFirst(count)
        
        switch player {
        case .player:
            versusBattlePlayerHand.append(contentsOf: dealtCards)
            versusBattlePlayerHand = versusBattleSortPlayerHand(versusBattlePlayerHand)
        case .enemy:
            versusBattleEnemyHand.append(contentsOf: dealtCards)
        }
        
        // 发牌后检查手牌数量是否超过18张
        versusBattleCheckGameOver()
    }
    
    private func versusBattleSortPlayerHand(_ hand: [VersusBattleCard]) -> [VersusBattleCard] {
        return hand.sorted { card1, card2 in
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
    
    private func versusBattleGetCardTypePriority(_ type: VersusBattleCardType) -> Int {
        switch type {
        case .damage:
            return 0
        case .heal:
            return 1
        case .percentDamage:
            return 2
        }
    }
    
    private func versusBattleGetDamageTypePriority(_ type: VersusBattleDamageCardType) -> Int {
        switch type {
        case .bing:
            return 0  // 筒
        case .tenth:
            return 1  // 万
        case .slip:
            return 2  // 条
        }
    }
    
    private func versusBattleGetHealTypePriority(_ type: VersusBattleHealCardType) -> Int {
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
    
    private func versusBattleGetPercentDamageTypePriority(_ type: VersusBattlePercentDamageCardType) -> Int {
        switch type {
        case .skill1:
            return 0
        case .skill2:
            return 1
        case .skill3:
            return 2
        }
    }
    
    func versusBattleCheckGameOver() {
        if versusBattlePlayerHealth <= 0 {
            versusBattleGameResult = .defeat
            versusBattleGameEndReason = .healthDepleted
            versusBattleShowGameOverDialog = true
        } else if versusBattleEnemyHealth <= 0 {
            if versusBattleCurrentMode == .adventure {
                versusBattleAdvanceToNextLevel()
            } else {
                versusBattleGameResult = .victory
                versusBattleGameEndReason = .healthDepleted
                versusBattleShowGameOverDialog = true
            }
        } else if versusBattlePlayerHand.count > 18 {
            versusBattleGameResult = .defeat
            versusBattleGameEndReason = .tooManyCards
            versusBattleShowGameOverDialog = true
        } else if versusBattleEnemyHand.count > 18 {
            versusBattleGameResult = .victory
            versusBattleGameEndReason = .tooManyCards
            versusBattleShowGameOverDialog = true
        }
    }
    
    func versusBattleAdvanceToNextLevel() {
        versusBattleCurrentLevel += 1
        if versusBattleCurrentLevel > versusBattleHighestLevel {
            versusBattleHighestLevel = versusBattleCurrentLevel
            UserDefaults.standard.set(versusBattleHighestLevel, forKey: "VersusBattleHighestLevel")
        }
        
        versusBattleEnemyHealth = versusBattleCalculateEnemyHealthForLevel(versusBattleCurrentLevel)
        versusBattleEnemyMaxHealth = versusBattleEnemyHealth
        versusBattleResetGame()
    }
    
    func versusBattleLoadHighestLevel() {
        versusBattleHighestLevel = UserDefaults.standard.integer(forKey: "VersusBattleHighestLevel")
        if versusBattleHighestLevel == 0 {
            versusBattleHighestLevel = 1
        }
    }
}
