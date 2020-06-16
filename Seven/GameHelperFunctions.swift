//
//  GameHelperFunctions.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import Foundation

func getFirstTwoTilePositions(dimensions: Int) -> [(Int, Int)]{
    // Randomly generate two row and column combos to insert initial tiles
    let row1 = Int.random(in: 0..<dimensions)
    let col1 = Int.random(in: 0..<dimensions)
    
    let row2 = Int.random(in: 0..<dimensions)
    var col2 = Int.random(in: 0..<dimensions)
    
    // just in case we picked the same tile, we increment one of them
    if (row1, col1) == (row2, col2) {
        col2 += 1
    }
    
    return [(row1, col1), (row2, col2)]
}

func addFirstTiles(dimensions: Int, tileValueBoard: Gameboard<Int>, tileViewBoard: Gameboard<TileView?>) ->
    (Gameboard<Int>, Gameboard<TileView?>){
        
    let firstTwoTilePositions = getFirstTwoTilePositions(dimensions: dimensions)
    let (row1, col1) = firstTwoTilePositions[0]
    let (row2, col2) = firstTwoTilePositions[1]
    
    // add tile to tileValueBoard
    var newTileValueBoard = tileValueBoard
    newTileValueBoard[row1, col1] = 7
    newTileValueBoard[row2, col2] = 7
    print("newTileValueBoard is: \(newTileValueBoard)")
    
    // add new tileView to tileViewBoard
    var newTileViewBoard = tileViewBoard
    newTileViewBoard[row1, col1] = TileView(x:30, y: 300)
    newTileViewBoard[row2, col2] = TileView(x: 230, y:300)
    print("newTileViewBoard is: \(newTileViewBoard)")
    
    return (newTileValueBoard, newTileViewBoard)
}

//func generateTile() -> (Int, TileView) {
//        let newTile = TileView(x: 0, y: 0)
//    
//    return (7, TileView)
//}


