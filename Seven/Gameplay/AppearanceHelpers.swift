//
//  AppearanceHelpers.swift
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
    
    let tileHeight = (superviewHeight - numGaps*spacing) / (numTiles + numTileGapHeight)
    let tileWidth = min((superviewWidth - numGaps*spacing) / (numTiles + numTileGapWidth), tileHeight*0.9)
    
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
            return UIColor.init(red: 183.0/255.0, green: 232.0/255.0, blue: 248.0/255.0, alpha: 1)
        case 2, 5:
            return UIColor.init(red: 246.0/255.0, green: 179.0/255.0, blue: 162.0/255.0, alpha: 1)
        case 3, 4:
            return UIColor.init(red: 183.0/255.0, green: 232.0/255.0, blue: 248.0/255.0, alpha: 1)
        default:
            return UIColor.init(red: 254.0/255.0, green: 241.0/255.0, blue: 235.0/255.0, alpha: 1)
        }
    }
    
    func borderColor(_ value: Int) -> CGColor {
        switch value {
        case 224:
            return UIColor.init(red: 124.0/255.0, green: 131.0/255.0, blue: 141.0/255.0, alpha: 1).cgColor
        case 448:
            return UIColor.init(red: 99.0/255.0, green: 200.0/255.0, blue: 231.0/255.0, alpha: 1).cgColor
        case 896:
            return UIColor.init(red: 21.0/255.0, green: 173.0/255.0, blue: 224.0/255.0, alpha: 1).cgColor
        case 1792:
             return UIColor.init(red: 16.0/255.0, green: 119.0/255.0, blue: 173.0/255.0, alpha: 1).cgColor
        case 3584:
            return UIColor.init(red: 9.0/255.0, green: 85.0/255.0, blue: 134.0/255.0, alpha: 1).cgColor
        default:
            return UIColor.clear.cgColor
        }
    }
    
    func borderInactiveColor(_ value: Int) -> CGColor {
        switch value {
        case 224:
            return UIColor.init(red: 124.0/255.0, green: 131.0/255.0, blue: 141.0/255.0, alpha: 0.7).cgColor
        case 448:
            return UIColor.init(red: 99.0/255.0, green: 200.0/255.0, blue: 231.0/255.0, alpha: 0.7).cgColor
        case 896:
            return UIColor.init(red: 21.0/255.0, green: 173.0/255.0, blue: 224.0/255.0, alpha: 0.7).cgColor
        case 1792:
            return UIColor.init(red: 16.0/255.0, green: 119.0/255.0, blue: 173.0/255.0, alpha: 0.7).cgColor
        case 3584:
            return UIColor.init(red: 9.0/255.0, green: 85.0/255.0, blue: 134.0/255.0, alpha: 0.7).cgColor
        default:
            return UIColor.clear.cgColor
        }
    }
    
    func tileInactiveColor(_ value: Int) -> UIColor{
        switch value {
        case 0: // when empty
            // return UIColor.init(red: 183.0/255.0, green: 232.0/255.0, blue: 248.0/255.0, alpha: 0.85)
            return UIColor.init(red: 235.0/255.0, green: 230/255.0, blue: 231/255.0, alpha: 0.85)
        case 2, 5:
            // return UIColor.init(red: 246.0/255.0, green: 179.0/255.0, blue: 162.0/255.0, alpha: 0.85)
            return UIColor.init(red: 255.0/255.0, green: 204/255.0, blue: 191/255.0, alpha: 0.55)
        case 3, 4:
            // return UIColor.init(red: 183.0/255.0, green: 232.0/255.0, blue: 248.0/255.0, alpha: 0.85)
            return UIColor.init(red: 232.0/255.0, green: 246/255.0, blue: 255/255.0, alpha: 0.8)
        default:
            // return UIColor.init(red: 254.0/255.0, green: 241.0/255.0, blue: 235.0/255.0, alpha: 0.85)
            return UIColor.init(red: 254.0/255.0, green: 241/255.0, blue: 235/255.0, alpha: 0.8)
        }
    }
    
    func font(_ value: Int) -> UIFont {
        return UIFont(name: "TallBasic30-Regular", size: 42)!
    }
    
    func fontSmallTile(_ value: Int) -> UIFont {
        switch value {
        case 10..<100:
            return UIFont(name: "TallBasic30-Regular", size: 28)!
        case 100..<1000:
            return UIFont(name: "TallBasic30-Regular", size: 24)!
        case 1000..<10000:
            return UIFont(name: "TallBasic30-Regular", size: 18)!
        default:
            return UIFont(name: "TallBasic30-Regular", size: 32)!
        }
    }
    
    
}
