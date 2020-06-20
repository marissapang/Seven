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
    let numTileGapHeight : CGFloat = 4
    let verticalShift : CGFloat = 0.75
    
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
