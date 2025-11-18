//
//  TileInfo.swift
//  FillUp
//
//  Tile information model for mixed mode support
//

import UIKit

// MARK: - Tile Info Structure

/// 麻将牌信息，包含数值和类型
struct TileInfo: Equatable, Hashable {
    let value: Int
    let category: TileCategoryType
    
    // MARK: - Validation
    
    /// 检查数值是否在有效范围内（1-9）
    var isValid: Bool {
        return value >= 1 && value <= 9
    }
    
    // MARK: - Initializers
    
    init(value: Int, category: TileCategoryType) {
        self.value = value
        self.category = category
    }
    
    /// 创建随机麻将牌
    static func random() -> TileInfo {
        let randomValue = Int.random(in: 1...9)
        let randomCategory = TileCategoryType.allCases.randomElement()!
        return TileInfo(value: randomValue, category: randomCategory)
    }
    
    // MARK: - Image
    
    /// 获取对应的图片
    func getImage() -> UIImage? {
        return category.retrieveImage(for: value)
    }
    
    // MARK: - Comparison
    
    /// 判断是否为同一类型
    func isSameCategory(as other: TileInfo) -> Bool {
        return self.category == other.category
    }
    
    /// 判断是否为相邻数值
    func isAdjacent(to other: TileInfo) -> Bool {
        return abs(self.value - other.value) == 1
    }
    
    /// 判断是否为连续牌（同类型且相邻）
    func isContinuous(with other: TileInfo) -> Bool {
        return isSameCategory(as: other) && isAdjacent(to: other)
    }
    
    // MARK: - Description
    
    var description: String {
        return "\(category.displayName)-\(value)"
    }
}

// MARK: - Tile Category Extension

extension TileCategoryType: CaseIterable {
    static var allCases: [TileCategoryType] {
        return [.fillA, .fillB, .fillC]
    }
}

// MARK: - Tile Generator Configuration

/// 混合序列生成配置
struct MixedSequenceConfig {
    /// 类型切换概率（0.0 - 1.0）
    let switchProbability: Double
    
    /// 最小连续相同类型数量
    let minConsecutiveSameType: Int
    
    /// 最大连续相同类型数量
    let maxConsecutiveSameType: Int
    
    static let `default` = MixedSequenceConfig(
        switchProbability: 0.4,
        minConsecutiveSameType: 1,
        maxConsecutiveSameType: 3
    )
    
    static let easy = MixedSequenceConfig(
        switchProbability: 0.2,
        minConsecutiveSameType: 2,
        maxConsecutiveSameType: 4
    )
    
    static let hard = MixedSequenceConfig(
        switchProbability: 0.6,
        minConsecutiveSameType: 1,
        maxConsecutiveSameType: 2
    )
}

// MARK: - Tile Generator

/// 麻将序列生成器
class TileGenerator {
    
    // MARK: - Public Methods
    
    /// 生成单一类型的连续序列
    /// - Parameters:
    ///   - length: 序列长度
    ///   - category: 麻将类型
    /// - Returns: 生成的序列
    static func generateSequence(length: Int, category: TileCategoryType) -> [TileInfo] {
        guard length > 0 && length <= 9 else {
            return []
        }
        
        let startValue = Int.random(in: 1...(10 - length))
        return (startValue...(startValue + length - 1)).map { value in
            TileInfo(value: value, category: category)
        }
    }
    
    /// 生成混合类型的序列
    /// - Parameters:
    ///   - length: 序列长度
    ///   - config: 生成配置
    /// - Returns: 生成的混合序列
    static func generateMixedSequence(length: Int, config: MixedSequenceConfig = .default) -> [TileInfo] {
        guard length > 0 && length <= 9 else {
            return []
        }
        
        var tiles: [TileInfo] = []
        let allCategories = TileCategoryType.allCases
        
        // 随机选择起始类型和数值
        var currentCategory = allCategories.randomElement()!
        let startValue = Int.random(in: 1...(10 - length))
        var consecutiveCount = 0
        
        for i in 0..<length {
            let value = startValue + i
            
            // 决定是否切换类型
            let shouldSwitch = shouldSwitchCategory(
                index: i,
                consecutiveCount: consecutiveCount,
                config: config
            )
            
            if shouldSwitch {
                currentCategory = selectDifferentCategory(from: currentCategory, options: allCategories)
                consecutiveCount = 0
            }
            
            tiles.append(TileInfo(value: value, category: currentCategory))
            consecutiveCount += 1
        }
        
        return tiles
    }
    
    /// 生成混合类型的干扰选项
    /// - Parameters:
    ///   - correctTiles: 正确答案
    ///   - count: 需要生成的数量
    /// - Returns: 干扰选项数组
    static func generateMixedDistractors(correctTiles: [TileInfo], count: Int) -> [TileInfo] {
        guard count > 0 else { return [] }
        
        var distractors = Set<TileInfo>()
        let correctSet = Set(correctTiles)
        let usedCategories = Set(correctTiles.map { $0.category })
        let allCategories = TileCategoryType.allCases
        
        var attempts = 0
        let maxAttempts = count * 10
        
        while distractors.count < count && attempts < maxAttempts {
            attempts += 1
            
            let candidate = generateSmartDistractor(
                correctTiles: correctTiles,
                usedCategories: usedCategories,
                allCategories: allCategories
            )
            
            if !correctSet.contains(candidate) && !distractors.contains(candidate) {
                distractors.insert(candidate)
            }
        }
        
        return Array(distractors)
    }
    
    /// 生成单一类型的干扰选项
    /// - Parameters:
    ///   - correctValues: 正确的数值
    ///   - category: 麻将类型
    ///   - count: 需要生成的数量
    /// - Returns: 干扰选项数组
    static func generateDistractors(correctValues: [Int], category: TileCategoryType, count: Int) -> [TileInfo] {
        guard count > 0 else { return [] }
        
        var distractors: [TileInfo] = []
        var availableValues = Array(1...9).filter { !correctValues.contains($0) }
        availableValues.shuffle()
        
        let actualCount = min(count, availableValues.count)
        for i in 0..<actualCount {
            distractors.append(TileInfo(value: availableValues[i], category: category))
        }
        
        return distractors
    }
    
    // MARK: - Private Helper Methods
    
    /// 判断是否应该切换类型
    private static func shouldSwitchCategory(index: Int, consecutiveCount: Int, config: MixedSequenceConfig) -> Bool {
        // 第一个tile不切换
        guard index > 0 else { return false }
        
        // 如果达到最大连续数，必须切换
        if consecutiveCount >= config.maxConsecutiveSameType {
            return true
        }
        
        // 如果还没达到最小连续数，不切换
        if consecutiveCount < config.minConsecutiveSameType {
            return false
        }
        
        // 根据概率决定
        return Double.random(in: 0...1) < config.switchProbability
    }
    
    /// 选择一个不同的类型
    private static func selectDifferentCategory(from current: TileCategoryType, options: [TileCategoryType]) -> TileCategoryType {
        let others = options.filter { $0 != current }
        return others.randomElement() ?? current
    }
    
    /// 生成智能干扰项
    private static func generateSmartDistractor(
        correctTiles: [TileInfo],
        usedCategories: Set<TileCategoryType>,
        allCategories: [TileCategoryType]
    ) -> TileInfo {
        // 70%的概率使用序列中出现过的类型
        let useExistingCategory = !usedCategories.isEmpty && Double.random(in: 0...1) < 0.7
        
        let category: TileCategoryType
        if useExistingCategory {
            category = usedCategories.randomElement()!
        } else {
            category = allCategories.randomElement()!
        }
        
        // 生成一个相近但不同的数值（增加混淆度）
        let correctValues = correctTiles.filter { $0.category == category }.map { $0.value }
        let value: Int
        
        if !correctValues.isEmpty && Double.random(in: 0...1) < 0.6 {
            // 60%概率选择相邻数值
            let baseValue = correctValues.randomElement()!
            let offset = [-2, -1, 1, 2].randomElement()!
            value = max(1, min(9, baseValue + offset))
        } else {
            value = Int.random(in: 1...9)
        }
        
        return TileInfo(value: value, category: category)
    }
}

