
import Foundation
import SwiftUI
import Combine

class VersusBattleGameEngine: ObservableObject {
    @Published var versusBattleGameState: VersusBattleGameState
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.versusBattleGameState = VersusBattleGameState()
        
        // 转发嵌套 ObservableObject 的变化
        versusBattleGameState.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Card Validation
    func versusBattleValidateCardCombination(_ cards: [VersusBattleCard]) -> VersusBattleCardCombination? {
        // 检查单张牌（只允许伤害牌）
        if cards.count == 1 {
            return versusBattleCheckSingleCard(cards)
        }
        
        // 其他组合需要至少2张牌
        guard cards.count >= 2 else { return nil }
        
        // 检查是否为对子、刻子或杠
        if let sameCombination = versusBattleCheckSameCards(cards) {
            return sameCombination
        }
        
        // 检查是否为顺子 (只对伤害牌有效)
        if cards.count == 3 {
            if let sequenceCombination = versusBattleCheckSequence(cards) {
                return sequenceCombination
            }
        }
        
        return nil
    }
    
    private func versusBattleCheckSingleCard(_ cards: [VersusBattleCard]) -> VersusBattleCardCombination? {
        guard cards.count == 1, let card = cards.first else { return nil }
        
        // 只允许伤害牌单张出牌
        switch card.type {
        case .damage:
            return VersusBattleCardCombination(cards: cards, type: .single)
        case .heal, .percentDamage:
            return nil // 回复牌和固定比例伤害牌不能单张出牌
        }
    }
    
    private func versusBattleCheckSameCards(_ cards: [VersusBattleCard]) -> VersusBattleCardCombination? {
        // 按卡牌类型和值分组
        let groupedCards = Dictionary(grouping: cards) { card in
            switch card.type {
            case .damage(let type):
                return "\(type.rawValue)-\(card.value)"
            case .heal(let type):
                return type.rawValue
            case .percentDamage(let type):
                return type.rawValue
            }
        }
        
        // 检查是否所有卡牌都属于同一组
        guard groupedCards.count == 1,
              let group = groupedCards.first,
              group.value.count == cards.count else {
            return nil
        }
        
        let combinationType: VersusBattleCombinationType
        switch cards.count {
        case 2:
            combinationType = .pair
        case 3:
            combinationType = .triplet
        case 4:
            combinationType = .quad
        default:
            return nil
        }
        
        return VersusBattleCardCombination(cards: cards, type: combinationType)
    }
    
    private func versusBattleCheckSequence(_ cards: [VersusBattleCard]) -> VersusBattleCardCombination? {
        guard cards.count == 3 else { return nil }
        
        // 只有伤害牌可以组成顺子
        let damageCards = cards.compactMap { card -> (VersusBattleDamageCardType, Int)? in
            if case .damage(let type) = card.type {
                return (type, card.value)
            }
            return nil
        }
        
        guard damageCards.count == 3 else { return nil }
        
        // 检查是否同花色
        let cardTypes = Set(damageCards.map { $0.0 })
        guard cardTypes.count == 1 else { return nil }
        
        // 检查是否连续
        let values = damageCards.map { $0.1 }.sorted()
        guard values[1] == values[0] + 1 && values[2] == values[1] + 1 else { return nil }
        
        return VersusBattleCardCombination(cards: cards, type: .sequence)
    }
    
    // MARK: - Game Actions
    func versusBattlePlayCards(_ cards: [VersusBattleCard]) -> Bool {
        guard let combination = versusBattleValidateCardCombination(cards) else {
            versusBattleGameState.versusBattleShowInvalidMoveAlert = true
            return false
        }
        
        // 记录当前玩家（出牌的玩家）
        let currentPlayer = versusBattleGameState.versusBattleCurrentPlayer
        
        // 从手牌中移除选中的卡牌
        if currentPlayer == .player {
            versusBattleGameState.versusBattlePlayerHand.removeAll { card in
                cards.contains(card)
            }
        } else {
            versusBattleGameState.versusBattleEnemyHand.removeAll { card in
                cards.contains(card)
            }
        }
        
        // 应用卡牌效果
        versusBattleApplyCombinationEffect(combination)
        
        // 切换玩家并开始新回合
        versusBattleSwitchPlayerAndStartTurn()
        
        // 检查游戏结束条件
        versusBattleGameState.versusBattleCheckGameOver()
        
        return true
    }
    
    private func versusBattleApplyCombinationEffect(_ combination: VersusBattleCardCombination) {
        versusBattleGameState.versusBattleLastPlayedCombination = combination
        
        let isPlayerTurn = versusBattleGameState.versusBattleCurrentPlayer == .player
        
        // 检查卡牌类型并应用相应效果
        if let firstCard = combination.cards.first {
            switch firstCard.type {
            case .damage:
                let damage = combination.versusBattleDamage
                if isPlayerTurn {
                    versusBattleApplyDamage(to: .enemy, amount: damage)
                } else {
                    versusBattleApplyDamage(to: .player, amount: damage)
                }
                
            case .heal:
                let healPercent = combination.versusBattleHealPercent
                if isPlayerTurn {
                    versusBattleApplyHeal(to: .player, percent: healPercent)
                } else {
                    versusBattleApplyHeal(to: .enemy, percent: healPercent)
                }
                
            case .percentDamage:
                let damagePercent = combination.versusBattlePercentDamage
                if isPlayerTurn {
                    versusBattleApplyPercentDamage(to: .enemy, percent: damagePercent)
                } else {
                    versusBattleApplyPercentDamage(to: .player, percent: damagePercent)
                }
            }
        }
    }
    
    private func versusBattleApplyDamage(to target: VersusBattleCurrentPlayer, amount: Int) {
        versusBattleGameState.versusBattleDamageAmount = amount
        versusBattleGameState.versusBattleIsAnimatingDamage = true
        
        withAnimation(.easeInOut(duration: 0.5)) {
            switch target {
            case .player:
                versusBattleGameState.versusBattlePlayerHealth = max(0, versusBattleGameState.versusBattlePlayerHealth - amount)
            case .enemy:
                versusBattleGameState.versusBattleEnemyHealth = max(0, versusBattleGameState.versusBattleEnemyHealth - amount)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.versusBattleGameState.versusBattleIsAnimatingDamage = false
        }
    }
    
    private func versusBattleApplyHeal(to target: VersusBattleCurrentPlayer, percent: Double) {
        let maxHealth = target == .player ? versusBattleGameState.versusBattlePlayerMaxHealth : versusBattleGameState.versusBattleEnemyMaxHealth
        let healAmount = Int(Double(maxHealth) * percent)
        
        versusBattleGameState.versusBattleHealAmount = healAmount
        versusBattleGameState.versusBattleIsAnimatingHeal = true
        
        withAnimation(.easeInOut(duration: 0.5)) {
            switch target {
            case .player:
                versusBattleGameState.versusBattlePlayerHealth = min(versusBattleGameState.versusBattlePlayerMaxHealth, versusBattleGameState.versusBattlePlayerHealth + healAmount)
            case .enemy:
                versusBattleGameState.versusBattleEnemyHealth = min(versusBattleGameState.versusBattleEnemyMaxHealth, versusBattleGameState.versusBattleEnemyHealth + healAmount)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.versusBattleGameState.versusBattleIsAnimatingHeal = false
        }
    }
    
    private func versusBattleApplyPercentDamage(to target: VersusBattleCurrentPlayer, percent: Double) {
        let maxHealth = target == .player ? versusBattleGameState.versusBattlePlayerMaxHealth : versusBattleGameState.versusBattleEnemyMaxHealth
        let damage = Int(Double(maxHealth) * percent)
        versusBattleApplyDamage(to: target, amount: damage)
    }
    
    private func versusBattleSwitchPlayer() {
        versusBattleGameState.versusBattleCurrentPlayer = versusBattleGameState.versusBattleCurrentPlayer == .player ? .enemy : .player
    }
    
    private func versusBattleSwitchPlayerAndStartTurn() {
        // 切换到下一个玩家
        versusBattleSwitchPlayer()
        
        // 给新的当前玩家发牌（回合开始时发牌）
        versusBattleGameState.versusBattleDealCards(to: versusBattleGameState.versusBattleCurrentPlayer, count: 1)
    }
    
    func versusBattleSkipTurn() {
        // 切换玩家并开始新回合
        versusBattleSwitchPlayerAndStartTurn()
        
        versusBattleGameState.versusBattleCheckGameOver()
    }
    
    // MARK: - AI Logic
    func versusBattleExecuteAITurn() {
        guard versusBattleGameState.versusBattleCurrentPlayer == .enemy else { return }
        
        // 延迟执行AI回合，增加真实感
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let bestCombination = self.versusBattleFindBestAICombination() {
                _ = self.versusBattlePlayCards(bestCombination.cards)
            } else {
                self.versusBattleSkipTurn()
            }
        }
    }
    
    private func versusBattleFindBestAICombination() -> VersusBattleCardCombination? {
        let enemyHand = versusBattleGameState.versusBattleEnemyHand
        var bestCombination: VersusBattleCardCombination?
        var bestScore: Int = -1
        
        // 尝试所有可能的组合
        // 首先尝试单张牌（只对伤害牌有效）
        for i in 0..<enemyHand.count {
            let singleCard = [enemyHand[i]]
            if let singleCombination = versusBattleValidateCardCombination(singleCard) {
                let singleScore = versusBattleEvaluateCombination(singleCombination)
                if singleScore > bestScore {
                    bestScore = singleScore
                    bestCombination = singleCombination
                }
            }
        }
        
        // 然后尝试多张牌的组合
        for i in 0..<enemyHand.count {
            for j in (i+1)..<enemyHand.count {
                let cards = [enemyHand[i], enemyHand[j]]
                if let combination = versusBattleValidateCardCombination(cards) {
                    let score = versusBattleEvaluateCombination(combination)
                    if score > bestScore {
                        bestScore = score
                        bestCombination = combination
                    }
                }
                
                // 尝试3张牌的组合
                for k in (j+1)..<enemyHand.count {
                    let threeCards = [enemyHand[i], enemyHand[j], enemyHand[k]]
                    if let threeCombination = versusBattleValidateCardCombination(threeCards) {
                        let threeScore = versusBattleEvaluateCombination(threeCombination)
                        if threeScore > bestScore {
                            bestScore = threeScore
                            bestCombination = threeCombination
                        }
                    }
                    
                    // 尝试4张牌的组合
                    for l in (k+1)..<enemyHand.count {
                        let fourCards = [enemyHand[i], enemyHand[j], enemyHand[k], enemyHand[l]]
                        if let fourCombination = versusBattleValidateCardCombination(fourCards) {
                            let fourScore = versusBattleEvaluateCombination(fourCombination)
                            if fourScore > bestScore {
                                bestScore = fourScore
                                bestCombination = fourCombination
                            }
                        }
                    }
                }
            }
        }
        
        return bestCombination
    }
    
    private func versusBattleEvaluateCombination(_ combination: VersusBattleCardCombination) -> Int {
        guard let firstCard = combination.cards.first else { return 0 }
        
        switch firstCard.type {
        case .damage:
            return combination.versusBattleDamage
        case .heal:
            let healPercent = combination.versusBattleHealPercent
            let maxHealth = versusBattleGameState.versusBattleEnemyMaxHealth
            let missingHealth = maxHealth - versusBattleGameState.versusBattleEnemyHealth
            return min(Int(Double(maxHealth) * healPercent), missingHealth)
        case .percentDamage:
            let damagePercent = combination.versusBattlePercentDamage
            return Int(Double(versusBattleGameState.versusBattlePlayerMaxHealth) * damagePercent)
        }
    }
}
