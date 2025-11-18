//
//  GameMode.swift
//  FillUp
//
//  Game mode protocol and implementations
//

import UIKit

// MARK: - Game Mode Protocol

/// 游戏模式协议，定义不同游戏模式的行为
protocol GameMode {
    /// 模式唯一标识符
    var id: String { get }
    
    /// 显示名称
    var displayName: String { get }
    
    /// 模式描述
    var description: String { get }
    
    /// 显示图标
    var icon: String { get }
    
    /// 是否使用混合类型麻将
    var usesMixedTiles: Bool { get }
    
    /// 允许的错误次数（0表示一次都不能错）
    var allowedMistakes: Int { get }
    
    /// 是否有时间限制
    var hasTimeLimit: Bool { get }
    
    // MARK: - 难度配置
    
    /// 获取指定回合的序列长度
    func getSequenceLength(forRound round: Int) -> Int
    
    /// 获取指定回合的空缺数量
    func getApertureCount(forRound round: Int) -> Int
    
    /// 获取指定回合的时间限制
    func getTimeLimit(forRound round: Int) -> TimeInterval?
    
    // MARK: - 得分计算
    
    /// 计算得分
    /// - Parameters:
    ///   - apertureCount: 空缺数量
    ///   - round: 当前回合
    ///   - timeUsed: 使用的时间
    /// - Returns: 得分
    func calculateScore(apertureCount: Int, round: Int, timeUsed: TimeInterval) -> Int
    
    // MARK: - 游戏结束判定
    
    /// 判断游戏是否应该结束
    /// - Parameters:
    ///   - mistakes: 当前错误次数
    ///   - round: 当前回合
    /// - Returns: 是否结束游戏
    func shouldEndGame(mistakes: Int, round: Int) -> Bool
}

// MARK: - Base Game Mode

/// 基础游戏模式实现，提供默认行为
class BaseGameMode: GameMode {
    let id: String
    let displayName: String
    let description: String
    let icon: String
    let usesMixedTiles: Bool
    let allowedMistakes: Int
    let hasTimeLimit: Bool
    
    init(
        id: String,
        displayName: String,
        description: String,
        icon: String,
        usesMixedTiles: Bool = false,
        allowedMistakes: Int = 0,
        hasTimeLimit: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.icon = icon
        self.usesMixedTiles = usesMixedTiles
        self.allowedMistakes = allowedMistakes
        self.hasTimeLimit = hasTimeLimit
    }
    
    func getSequenceLength(forRound round: Int) -> Int {
        return min(3 + round, 9)
    }
    
    func getApertureCount(forRound round: Int) -> Int {
        return min(1 + (round / 2), 4)
    }
    
    func getTimeLimit(forRound round: Int) -> TimeInterval? {
        return nil
    }
    
    func calculateScore(apertureCount: Int, round: Int, timeUsed: TimeInterval) -> Int {
        return apertureCount * 10 * round
    }
    
    func shouldEndGame(mistakes: Int, round: Int) -> Bool {
        return mistakes > allowedMistakes
    }
}

// MARK: - Game Mode Types

enum GameModeType: String, CaseIterable {
    case classic = "classic"
    case mixed = "mixed"
    
    var displayName: String {
        switch self {
        case .classic: return "Basic Mode"
        case .mixed: return "Mixed Mode"
        }
    }
    
    var icon: String {
        switch self {
        case .classic: return "🎯"
        case .mixed: return "🎨"
        }
    }
    
    func createMode() -> GameMode {
        switch self {
        case .classic: return ClassicMode()
        case .mixed: return MixedMode()
        }
    }
}

// MARK: - Basic Mode

/// 经典模式：单一类型，逐步递增难度
final class ClassicMode: BaseGameMode {
    init() {
        super.init(
            id: "classic",
            displayName: "Basic Mode",
            description: "Single tile type. Fill the gaps in sequence. Difficulty increases gradually. One mistake ends the game.",
            icon: "🎯",
            usesMixedTiles: false,
            allowedMistakes: 0,
            hasTimeLimit: false
        )
    }
}

// MARK: - Mixed Mode

/// 混合模式：多种类型混合，难度更高
final class MixedMode: BaseGameMode {
    
    // MARK: - Configuration
    
    /// 混合模式配置参数
    struct Config {
        /// 基础分数倍率
        let scoreMultiplier: Int
        
        /// 最大序列长度
        let maxSequenceLength: Int
        
        /// 最大空缺数量
        let maxApertureCount: Int
        
        /// 序列生成配置
        let sequenceConfig: MixedSequenceConfig
        
        static let standard = Config(
            scoreMultiplier: 15,
            maxSequenceLength: 7,
            maxApertureCount: 3,
            sequenceConfig: .default
        )
        
        static let challenging = Config(
            scoreMultiplier: 20,
            maxSequenceLength: 8,
            maxApertureCount: 4,
            sequenceConfig: .hard
        )
    }
    
    // MARK: - Properties
    
    private let config: Config
    
    // MARK: - Initialization
    
    init(config: Config = .standard) {
        self.config = config
        
        super.init(
            id: "mixed",
            displayName: "Mixed Mode",
            description: "Three tile types appear mixed! Identify both type and number. Challenge your observation skills!",
            icon: "🎨",
            usesMixedTiles: true,
            allowedMistakes: 0,
            hasTimeLimit: false
        )
    }
    
    // MARK: - GameMode Implementation
    
    override func getSequenceLength(forRound round: Int) -> Int {
        // 混合模式序列长度增长较慢，因为难度更高
        let baseLength = 3
        let growthRate = max(1, round / 2)
        return min(baseLength + growthRate, config.maxSequenceLength)
    }
    
    override func getApertureCount(forRound round: Int) -> Int {
        // 空缺数量根据回合数递增
        let baseCount = 1
        let increment = round / 3  // 每3回合增加1个空缺
        return min(baseCount + increment, config.maxApertureCount)
    }
    
    override func calculateScore(apertureCount: Int, round: Int, timeUsed: TimeInterval) -> Int {
        // 混合模式得分更高
        let baseScore = apertureCount * config.scoreMultiplier * round
        
        // 如果有多个空缺，额外奖励
        let bonusScore = apertureCount > 1 ? (apertureCount - 1) * round * 5 : 0
        
        return baseScore + bonusScore
    }
    
    // MARK: - Helper Methods
    
    /// 获取当前配置的序列生成器配置
    func getSequenceConfig() -> MixedSequenceConfig {
        return config.sequenceConfig
    }
}

// MARK: - Game Configuration

class GameConfiguration {
    let mode: GameMode
    let primaryTileType: TileCategoryType
    
    init(mode: GameMode, primaryTileType: TileCategoryType) {
        self.mode = mode
        self.primaryTileType = primaryTileType
    }
}

