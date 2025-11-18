//
//  TileImageModel.swift
//  FillUp
//
//  Unified tile image model
//

import UIKit

// MARK: - Tile Image Registry

struct TileImageRegistry {
    static func getImage(category: TileCategoryType, value: Int) -> UIImage? {
        let imageName = "\(category.rawValue) \(value)"
        return UIImage(named: imageName)
    }
    
    static func getAllImages(for category: TileCategoryType) -> [UIImage?] {
        return (1...9).map { getImage(category: category, value: $0) }
    }
}

// Backward compatibility - legacy image references
let fillImageA1 = TileImageRegistry.getImage(category: .fillA, value: 1)
let fillImageA2 = TileImageRegistry.getImage(category: .fillA, value: 2)
let fillImageA3 = TileImageRegistry.getImage(category: .fillA, value: 3)
let fillImageA4 = TileImageRegistry.getImage(category: .fillA, value: 4)
let fillImageA5 = TileImageRegistry.getImage(category: .fillA, value: 5)
let fillImageA6 = TileImageRegistry.getImage(category: .fillA, value: 6)
let fillImageA7 = TileImageRegistry.getImage(category: .fillA, value: 7)
let fillImageA8 = TileImageRegistry.getImage(category: .fillA, value: 8)
let fillImageA9 = TileImageRegistry.getImage(category: .fillA, value: 9)

let fillImageB1 = TileImageRegistry.getImage(category: .fillB, value: 1)
let fillImageB2 = TileImageRegistry.getImage(category: .fillB, value: 2)
let fillImageB3 = TileImageRegistry.getImage(category: .fillB, value: 3)
let fillImageB4 = TileImageRegistry.getImage(category: .fillB, value: 4)
let fillImageB5 = TileImageRegistry.getImage(category: .fillB, value: 5)
let fillImageB6 = TileImageRegistry.getImage(category: .fillB, value: 6)
let fillImageB7 = TileImageRegistry.getImage(category: .fillB, value: 7)
let fillImageB8 = TileImageRegistry.getImage(category: .fillB, value: 8)
let fillImageB9 = TileImageRegistry.getImage(category: .fillB, value: 9)

let fillImageC1 = TileImageRegistry.getImage(category: .fillC, value: 1)
let fillImageC2 = TileImageRegistry.getImage(category: .fillC, value: 2)
let fillImageC3 = TileImageRegistry.getImage(category: .fillC, value: 3)
let fillImageC4 = TileImageRegistry.getImage(category: .fillC, value: 4)
let fillImageC5 = TileImageRegistry.getImage(category: .fillC, value: 5)
let fillImageC6 = TileImageRegistry.getImage(category: .fillC, value: 6)
let fillImageC7 = TileImageRegistry.getImage(category: .fillC, value: 7)
let fillImageC8 = TileImageRegistry.getImage(category: .fillC, value: 8)
let fillImageC9 = TileImageRegistry.getImage(category: .fillC, value: 9)

