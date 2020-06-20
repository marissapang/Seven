//
//  GameHelperFunctions.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

//MARK: Game set-up functions
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

    
func addFirstTiles(dimensions: Int, sizeAndPositionsDict: [String:CGFloat], tileValueBoard: Gameboard<Int>, tileViewBoard: Gameboard<TileView?>) ->
    (Gameboard<Int>, Gameboard<TileView?>){
        
    let firstTwoTilePositions = getFirstTwoTilePositions(dimensions: dimensions)
    let (row1, col1) = firstTwoTilePositions[0]
    let (row2, col2) = firstTwoTilePositions[1]
    
    // add tile to tileValueBoard
    var newTileValueBoard = tileValueBoard
    newTileValueBoard[row1, col1] = 7
    newTileValueBoard[row2, col2] = 7
    
    // add new tileView to tileViewBoard
    var newTileViewBoard = tileViewBoard
        newTileViewBoard[row1, col1] = TileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: 7)
        newTileViewBoard[row2, col2] = TileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: 7)
    
    return (newTileValueBoard, newTileViewBoard)
}

func initialUpdateOfIndexPositionBoards(dimensions: Int, tileValueBoard : Gameboard<Int>, rowIndexPositionBoard : Gameboard<Int>, colIndexPositionBoard : Gameboard<Int>) -> (Gameboard<Int>, Gameboard<Int>){
    
    var newRowIndexPositionBoard = rowIndexPositionBoard
    var newColIndexPositionBoard = colIndexPositionBoard
    
    for row in 0..<dimensions {
        for col in 0..<dimensions {
            if tileValueBoard[row, col] != 0 { // if a tile exists in the position
                newRowIndexPositionBoard[row, col] = row + 1
                newColIndexPositionBoard[row, col] = col + 1
            }
        }
    }
    
    return (newRowIndexPositionBoard, newColIndexPositionBoard)
}

//MARK: Add Tile Logic
func generateTile(){
    
}

//MARK: Update After Swipe
func updateGameAfterSwipe(dimensions: Int, direction: Direction, tileValueBoard: Gameboard<Int>, tileViewBoard: Gameboard<TileView?>, viewsToBeDeleted: [TileView], rowIndexPositionBoard: Gameboard<Int>, colIndexPositionBoard: Gameboard<Int>) -> (Gameboard<Int>, Gameboard<TileView?>, [TileView], Gameboard<Int>, Gameboard<Int>) {
    let (startIndex, endIndex, increment) = getStartStopIndicesForSwipeFunctions(dimensions: dimensions, direction: direction)
    
    var tileMovementBoard = Gameboard(d: tileValueBoard.dimension, initialValue: Movement.stay)
    
    var newTileValueBoard = tileValueBoard
    var newTileViewBoard = tileViewBoard
    var newViewsToBeDeleted = viewsToBeDeleted
    var newRowIndexPositionBoard = rowIndexPositionBoard
    var newColIndexPositionBoard = colIndexPositionBoard
    
    var row : Int, col : Int, nextRow : Int, nextCol : Int
    let rowIndexIncr: Int, colIndexIncr : Int
    
    switch direction {
    case .up:
        colIndexIncr = -1
        rowIndexIncr = 0
    case .down:
        colIndexIncr = 1
        rowIndexIncr = 0
    case .left:
        colIndexIncr = 0
        rowIndexIncr = -1
    case .right:
        colIndexIncr = 0
        rowIndexIncr = 1
    default:
        colIndexIncr = 0
        rowIndexIncr = 0
    }
    
    for i in stride(from: startIndex, through: endIndex, by: increment) {
        for j in 0..<dimensions {
            (row, col, nextRow, nextCol) = processIJs(dimensions: dimensions, direction: direction, increment: increment, i: i, j: j)
            
            print("row: \(row), col: \(col), nextRow: \(nextRow), nextCol: \(nextCol)")
            if newTileValueBoard[row, col] == 0 { // if current tile is empty we do nothing
                () // default is already.stay
            } else if newTileValueBoard[nextRow, nextCol] == 0 { // if next tile is empty (but our current tile isn't), we move
                tileMovementBoard[row, col] = .move
                
                newTileValueBoard[nextRow, nextCol] = newTileValueBoard[row, col]
                newTileValueBoard[row, col] = 0
                
                newRowIndexPositionBoard[nextRow, nextCol] = max(min(newRowIndexPositionBoard[row, col] + rowIndexIncr, dimensions), 1)
                newColIndexPositionBoard[nextRow, nextCol] = max(min(newColIndexPositionBoard[row, col] + colIndexIncr, dimensions), 1)
                newRowIndexPositionBoard[row, col] = 0
                newColIndexPositionBoard[row, col] = 0
            
                newTileViewBoard[nextRow, nextCol] = newTileViewBoard[row, col]
                newTileViewBoard[row, col] = nil
            } else if canBeCombined(v1: tileValueBoard[row, col], v2: tileValueBoard[nextRow, nextCol]){ // if the two tiles can be combined then we move current and delete the next
                tileMovementBoard[row, col] = .move
                tileMovementBoard[nextRow, nextCol] = .delete
                
                newTileValueBoard[nextRow, nextCol] = newTileValueBoard[row, col] + newTileValueBoard[nextRow, nextCol]
                newTileValueBoard[row, col] = 0
                
                newRowIndexPositionBoard[nextRow, nextCol] = max(min(newRowIndexPositionBoard[row, col] + rowIndexIncr, dimensions), 1)
                newColIndexPositionBoard[nextRow, nextCol] = max(min(newColIndexPositionBoard[row, col] + colIndexIncr, dimensions), 1)
                newRowIndexPositionBoard[row, col] = 0
                newColIndexPositionBoard[row, col] = 0
                
                newViewsToBeDeleted += [newTileViewBoard[nextRow, nextCol]!]
                newTileViewBoard[nextRow, nextCol] = newTileViewBoard[row, col]
                newTileViewBoard[row, col] = nil
            } else { // if two tiles can't be combined then stay, and do nothing
                ()
            }
        }
    }
    return (newTileValueBoard, newTileViewBoard, newViewsToBeDeleted, newRowIndexPositionBoard, newColIndexPositionBoard)
}

//MARK: Game logic helpers
func canBeCombined(v1: Int, v2: Int) -> Bool {
    if (v1 == 2 && v2 == 5) || (v1 == 5 && v2 == 2) { // 5+2 makes 7
        return true
    } else if (v1 == 3 && v2 == 4) || (v1 == 4 && v2 == 3) { // 3+4 makes 7
        return true
    } else if v1 == 2 && v2 == 2 { // 2+2 makes 4
        return true
    } else if (v1 != 5 && v1 != 3 && v1 != 4) && v1==v2 {
        return true
    }
    return false
}

//MARK: Counting helpers
func getStartStopIndicesForSwipeFunctions(dimensions: Int, direction: Direction) -> (Int, Int, Int){
    let startIndex: Int
    let endIndex: Int
    let increment: Int
    
    switch direction {
    case .right, .down:
        startIndex = dimensions - 2
        endIndex = 0
        increment = -1
    case .left, .up:
        startIndex = 1
        endIndex = dimensions - 1
        increment = 1
    default:
        fatalError("Direction is wrong for moving and combining tiles.")
    }
    
    return (startIndex, endIndex, increment)
}

func processIJs(dimensions: Int, direction: Direction, increment: Int, i: Int, j: Int) -> (Int, Int, Int, Int){
    let row : Int, col : Int, nextRow : Int, nextCol : Int
    
    switch direction {
    case .left, .right:
        row = i
        col = j
        nextRow = max(min(row - increment, dimensions-1), 0)
        nextCol = col
    case .up, .down:
        row = j
        col = i
        nextRow = row
        nextCol = max(min(col - increment, dimensions-1), 0)
    default:
        fatalError("Error with unlisted or undefined direction")
    }
    
    return (row, col, nextRow, nextCol)
}










