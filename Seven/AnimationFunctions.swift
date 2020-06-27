//
//  AnimationFunctions.swift
//  Seven
//
//  Created by apple on 6/14/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

func calculateViewSizeAndPositions(dimensions: Int, superviewWidth: CGFloat, superviewHeight: CGFloat, spacing: CGFloat) -> [String:CGFloat]{
    // setting some parameters
    let numGaps = CGFloat(dimensions + 1)
    let numTiles = CGFloat(dimensions)
    let numTileGapWidth : CGFloat = 1
    let numTileGapHeight : CGFloat = 5
    let verticalShift : CGFloat = 0.6
    
    // find dimensions of a tile
    let tileWidth = (superviewWidth - numGaps*spacing) / (numTiles + numTileGapWidth)
    let tileHeight = (superviewHeight - numGaps*spacing) / (numTiles + numTileGapHeight)
    
    // find dimensions of gameboard
    let gameboardWidth = numTiles*tileWidth + numGaps*spacing
    let gameboardHeight = numTiles*tileHeight + numGaps*spacing
    
    // find (x,y) location of gameboard
    let gameboardX = (superviewWidth - gameboardWidth) / 2
    let gameboardY = (superviewHeight - gameboardHeight) * verticalShift
    
    // find (x,y) location for tile that is hidden at (0,0)
    let tileX = -tileWidth
    let tileY = -tileHeight
    
    let sizeAndPositionsDict = ["tileWidth":tileWidth, "tileHeight":tileHeight, "gameboardWidth":gameboardWidth, "gameboardHeight":gameboardHeight, "gameboardX":gameboardX, "gameboardY":gameboardY, "tileX":tileX, "tileY":tileY, "spacing":spacing]
    
    return sizeAndPositionsDict
}

class Appearance {
    func tileColor(_ value: Int) -> UIColor {
        switch value {
        case 0: // when empty
            return UIColor.init(red: 143.0/255.0, green: 135.0/255.0, blue: 129.0/255.0, alpha: 1)
        case 2, 5:
            return UIColor.init(red: 181.0/255.0, green: 226.0/255.0, blue: 221.0/255.0, alpha: 1)
        case 3, 4:
            return UIColor.init(red: 255.0/255.0, green: 180.0/255.0, blue: 105.0/255.0, alpha: 1)
        default:
            return UIColor.init(red: 255.0/255.0, green: 250.0/255.0, blue: 245.0/255.0, alpha: 1)
        }
    }
    
    func tileInactiveColor(_ value: Int) -> UIColor{
        switch value {
        case 0: // when empty
            return UIColor.init(red: 143.0/255.0, green: 135.0/255.0, blue: 129.0/255.0, alpha: 0.5)
        case 2, 5:
            return UIColor.init(red: 181.0/255.0, green: 226.0/255.0, blue: 221.0/255.0, alpha: 0.5)
        case 3, 4:
            return UIColor.init(red: 255.0/255.0, green: 180.0/255.0, blue: 105.0/255.0, alpha: 0.5)
        default:
            return UIColor.init(red: 255.0/255.0, green: 250.0/255.0, blue: 245.0/255.0, alpha: 0.5)
        }
    }
    
    func font(_ value: Int) -> UIFont {
        switch value {
        case 10..<100:
            return UIFont(name: "Chalkboard SE", size: 30)!
        case 100..<1000:
            return UIFont(name: "Chalkboard SE", size: 24)!
        case 1000..<10000:
            return UIFont(name: "Chalkboard SE", size: 18)!
        default:
            return UIFont(name: "Chalkboard SE", size: 34)!
        }
    }
    
    func fontSmallTile(_ value: Int) -> UIFont {
        switch value {
        case 10..<100:
            return UIFont(name: "Chalkboard SE", size: 24)!
        case 100..<1000:
            return UIFont(name: "Chalkboard SE", size: 18)!
        case 1000..<10000:
            return UIFont(name: "Chalkboard SE", size: 12)!
        default:
            return UIFont(name: "Chalkboard SE", size: 28)!
        }
    }
    
    
}
