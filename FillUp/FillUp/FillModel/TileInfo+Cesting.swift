//
//  TileInfo+Testing.swift
//  FillUp
//
//  Testing utilities for TileInfo and TileGenerator
//

import Foundation

#if DEBUG

// MARK: - TileInfo Testing Extensions

extension TileInfo {
    /// 创建用于测试的固定序列
    static func ceestSequence(start: Int = 1, length: Int, category: TileCategoryType) -> [TileInfo] {
        return (start..<(start + length)).map { TileInfo(value: $0, category: category) }
    }
    
    /// 创建随机测试数据
    static func randomTestData(count: Int) -> [TileInfo] {
        return (0..<count).map { _ in TileInfo.random() }
    }
}

// MARK: - TileGenerator Testing Extensions

extension TileGenerator {
    /// 验证生成的序列是否有效
    static func validateSequence(_ sequence: [TileInfo]) -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        // 检查是否为空
        if sequence.isEmpty {
            errors.append("序列为空")
            return (false, errors)
        }
        
        // 检查数值范围
        for (index, tile) in sequence.enumerated() {
            if !tile.isValid {
                errors.append("位置 \(index) 的值 \(tile.value) 超出范围")
            }
        }
        
        // 检查数值连续性
        for i in 0..<(sequence.count - 1) {
            if abs(sequence[i].value - sequence[i + 1].value) != 1 {
                errors.append("位置 \(i) 和 \(i + 1) 的数值不连续")
            }
        }
        
        return (errors.isEmpty, errors)
    }
    
    /// 分析混合序列的类型分布
    static func analyzeSequence(_ sequence: [TileInfo]) -> SequenceAnalysis {
        let categoryCounts = Dictionary(grouping: sequence, by: { $0.category })
            .mapValues { $0.count }
        
        var switchCount = 0
        for i in 1..<sequence.count {
            if sequence[i].category != sequence[i - 1].category {
                switchCount += 1
            }
        }
        
        let uniqueCategories = Set(sequence.map { $0.category }).count
        
        return SequenceAnalysis(
            totalLength: sequence.count,
            categoryCounts: categoryCounts,
            switchCount: switchCount,
            uniqueCategories: uniqueCategories
        )
    }
}

// MARK: - Sequence Analysis

struct SequenceAnalysis: CustomStringConvertible {
    let totalLength: Int
    let categoryCounts: [TileCategoryType: Int]
    let switchCount: Int
    let uniqueCategories: Int
    
    var description: String {
        var result = "序列分析:\n"
        result += "  总长度: \(totalLength)\n"
        result += "  类型数量: \(uniqueCategories)\n"
        result += "  切换次数: \(switchCount)\n"
        result += "  类型分布:\n"
        for (category, count) in categoryCounts.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let percentage = Double(count) / Double(totalLength) * 100
            result += "    \(category.displayName): \(count) (\(String(format: "%.1f", percentage))%)\n"
        }
        return result
    }
}

// MARK: - MixedSequenceConfig Testing

extension MixedSequenceConfig {
    /// 创建测试配置
    static func test(switchProbability: Double) -> MixedSequenceConfig {
        return MixedSequenceConfig(
            switchProbability: switchProbability,
            minConsecutiveSameType: 1,
            maxConsecutiveSameType: 10
        )
    }
    
    /// 验证配置是否有效
    func validate() -> (isValid: Bool, errors: [String]) {
        var errors: [String] = []
        
        if switchProbability < 0 || switchProbability > 1 {
            errors.append("切换概率必须在 0.0 到 1.0 之间")
        }
        
        if minConsecutiveSameType < 1 {
            errors.append("最小连续数必须大于等于 1")
        }
        
        if maxConsecutiveSameType < minConsecutiveSameType {
            errors.append("最大连续数必须大于等于最小连续数")
        }
        
        return (errors.isEmpty, errors)
    }
}

// MARK: - Performance Testing

/// 性能测试工具
struct TileGeneratorPerformance {
    /// 测试生成混合序列的性能
    static func measureMixedSequenceGeneration(
        length: Int,
        iterations: Int = 1000,
        config: MixedSequenceConfig = .default
    ) -> TimeInterval {
        let start = Date()
        
        for _ in 0..<iterations {
            _ = TileGenerator.generateMixedSequence(length: length, config: config)
        }
        
        let end = Date()
        return end.timeIntervalSince(start)
    }
    
    /// 测试生成干扰项的性能
    static func measureDistractorGeneration(
        correctTiles: [TileInfo],
        count: Int,
        iterations: Int = 1000
    ) -> TimeInterval {
        let start = Date()
        
        for _ in 0..<iterations {
            _ = TileGenerator.generateMixedDistractors(correctTiles: correctTiles, count: count)
        }
        
        let end = Date()
        return end.timeIntervalSince(start)
    }
}

#endif

