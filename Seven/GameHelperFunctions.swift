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

func calculateHighestTileValue(tileValueBoard: Gameboard<Int>) -> Int {
    var highestValue = 0
    for row in 0..<tileValueBoard.dimension {
        for col in 0..<tileValueBoard.dimension {
            highestValue = max(highestValue, tileValueBoard[row,col])
        }
    }
    return highestValue
}

func generateRandTileValue(tileValueBoard: Gameboard<Int>) -> Int {
    // should return value of 5, 10, 20, etc..
    var newTileValue : Int
    var highestTileValue : Int
    highestTileValue = calculateHighestTileValue(tileValueBoard: tileValueBoard)
    
    let freq2 : Double = 0.08
    let freq5 : Double = 0.06
    let freq3 : Double = 0.08
    let freq4 : Double = 0.06
    var freq14 : Double = 0
    var freq28 : Double = 0
    var freq56 : Double = 0
    var freq112 : Double = 0
    var freq224 : Double = 0
    
    // frequencies change depenign on hfar in we are in the game
    switch highestTileValue {
    case let highestTileValue where highestTileValue <= 112:
        () // change nothing if we are early on in the game
    case let highestTileValue where highestTileValue <= 224:
        freq14 = 0.03
        freq28 = 0.02
        freq56 = 0.01
    case let highestTileValue where highestTileValue <= 448:
        freq14 = 0.04
        freq28 = 0.03
        freq56 = 0.02
        freq112 = 0.01
    case let highestTileValue where highestTileValue <= 896:
        freq14 = 0.05
        freq28 = 0.05
        freq56 = 0.03
        freq112 = 0.02
        freq224 = 0.01
    default:
        () // do nothing for now
    }
    
    // user random number generator from 1-100 for 100%
    let randNumber = Double(Int.random(in: 0..<101))/100
    
    // create tile with certain value depending on the frequencies
    switch randNumber {
    case let randNumber where randNumber <= freq2:
        newTileValue = 2
    case let randNumber where randNumber <= freq2+freq5:
        newTileValue = 5
    case let randNumber where randNumber <= freq2+freq5+freq3:
        newTileValue = 3
    case let randNumber where randNumber <= freq2+freq5+freq3+freq4:
        newTileValue = 4
    case let randNumber where randNumber <= freq2+freq5+freq3+freq4+freq14:
        newTileValue = 14
    case let randNumber where randNumber <= freq2+freq5+freq3+freq4+freq14+freq28:
        newTileValue = 28
    case let randNumber where randNumber <= freq2+freq5+freq3+freq4+freq14+freq28+freq56:
        newTileValue = 56
    case let randNumber where randNumber <= freq2+freq5+freq3+freq4+freq14+freq28+freq56+freq112:
        newTileValue = 112
    case let randNumber where randNumber <= freq2+freq5+freq3+freq4+freq14+freq28+freq56+freq112+freq224:
        newTileValue = 224
    default:
        newTileValue = 7 // anything else we generate 7
    }
    
    return newTileValue
}


func getEmptyIndicesFromGameboard(tileValueBoard: Gameboard<Int>) -> [(Int, Int)]{
    var emptyTileIndices = [(Int, Int)]()
    for i in 0..<tileValueBoard.dimension {
        for j in 0..<tileValueBoard.dimension{
            if tileValueBoard[i,j] == 0 { emptyTileIndices += [(i, j)] }
        }
    }
    return emptyTileIndices
}

func pickRandIndex(emptyTileIndices: [(Int, Int)], direction: Direction, lastAxis: Int) -> Int {
    var randIndicesList = [Int]()
    for (i, j) in emptyTileIndices {
        if direction == .down || direction == .up {
            if i == lastAxis {
               randIndicesList += [j]
            }
        } else if direction == .right || direction == .left {
            if j == lastAxis {
                randIndicesList += [i]
            }
        }
    }
    let randNum = Int.random(in: 0..<randIndicesList.count)
    return randIndicesList[randNum]
}

func addTile(direction: Direction, tileValueBoard: Gameboard<Int>) -> (Int, Int){
    
   var lastAxis: Int
   let emptyTileIndices = getEmptyIndicesFromGameboard(tileValueBoard: tileValueBoard)

   guard emptyTileIndices.count != 0 else {
    print("game should end")
    return (0,0)
   }
           
   // If there are still empty tiles we want to figure out where to add one
    var row : Int
    var col : Int
    var randomIndex : Int
    
    switch direction {
    case .down: // look for top row
        lastAxis = 0
        randomIndex = pickRandIndex(emptyTileIndices: emptyTileIndices, direction: direction, lastAxis: lastAxis)
        row = randomIndex
        col = lastAxis
    case .up:
        lastAxis = Int(tileValueBoard.dimension-1)
        randomIndex = pickRandIndex(emptyTileIndices: emptyTileIndices, direction: direction, lastAxis: lastAxis)
        row = randomIndex
        col = lastAxis
    case .right:
        lastAxis = 0
        randomIndex = pickRandIndex(emptyTileIndices: emptyTileIndices, direction: direction, lastAxis: lastAxis)
        row = lastAxis
        col = randomIndex
    case .left:
        lastAxis = Int(tileValueBoard.dimension-1)
        randomIndex = pickRandIndex(emptyTileIndices: emptyTileIndices, direction: direction, lastAxis: lastAxis)
        row = lastAxis
        col = randomIndex
    default:
        fatalError("Swipe direction not properly accounted for")
    }
    
    return (row, col)
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
            
            // print("row: \(row), col: \(col), nextRow: \(nextRow), nextCol: \(nextCol)")
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










