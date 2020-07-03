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

func adjustTileFreq(lastXTiles: [Int], tileValueBoard: Gameboard<Int>) -> [Int: Double]{
    let startingFreq : [Int: Double] =
    [2: 0.08, 5: 0.06, 3: 0.08, 4: 0.06, 14: 0, 28: 0, 56: 0, 112: 0, 224: 0]
    
    // we only care about non-7 frequencies, so we filter out all the 7s
    let filteredLastXTiles = lastXTiles.filter{$0 != 7}
    
//    guard filteredLastXTiles.count >= 5 else {
//        return startingFreq
//    }
    var adjustedFreq = [Int: Double]()
    var runningCount: [Int: Int] = [2: 0, 5: 0, 3: 0, 4: 0, 14: 0, 28: 0, 56: 0, 112: 0, 224: 0]

    for value in filteredLastXTiles {
        runningCount[value] = runningCount[value]! + 1
    }
    
    var runningFreq = [Int: Double]()
    for (value, count) in runningCount {
        runningFreq[value] = Double(count)/Double(filteredLastXTiles.count)
    }
    
    if filteredLastXTiles.count >= 5 {
        for (value, freq) in runningFreq {
            adjustedFreq[value] = min(max(0, startingFreq[value]! + (startingFreq[value]! - freq)), 0.25)
        }
    } else {
        for (value, _) in runningFreq {
            adjustedFreq[value] = startingFreq[value]!
        }
    }
    
    // find the most common value on the board out of 2, 3, 4, and 5 and give on that has the most a leg up at resolution
    var boardCount: [Int: Int] = [2: 0, 3: 0, 4: 0, 5:0]
    var tileValue: Int
    for i in 0..<tileValueBoard.dimension {
        for j in 0..<tileValueBoard.dimension{
            tileValue = tileValueBoard[i,j]
            if tileValue == 2 || tileValue == 3 || tileValue == 4 || tileValue == 5 {
                boardCount[tileValue] = boardCount[tileValue]! + 1
            }
        }
    }
    
    // find maximum out of boardCount
    let maxValue = boardCount.max {a, b in a.value < b.value}
    
    if maxValue!.value >= 2 {
        switch maxValue!.key {
        case 2:
            adjustedFreq[5]! += 0.1
        case 5:
            adjustedFreq[2]! += 0.1
        case 3:
            adjustedFreq[4]! += 0.08
            adjustedFreq[2]! += 0.04
        case 4:
            adjustedFreq[3]! += 0.1
        default:
            ()
        }
    }
    return adjustedFreq
}

func generateRandTileValue(tileValueBoard: Gameboard<Int>, lastXTiles: [Int]) -> Int {
    // should return value of 5, 10, 20, etc..
    var newTileValue = 7
    var highestTileValue : Int
    highestTileValue = calculateHighestTileValue(tileValueBoard: tileValueBoard)
    var freq : [Int: Double] = [2: 0.08, 5: 0.06, 3: 0.08, 4: 0.06, 14: 0, 28: 0, 56: 0, 112: 0, 224: 0]
    
    // frequencies change depenign on hfar in we are in the game
    switch highestTileValue {
    case let highestTileValue where highestTileValue <= 112:
        () // change nothing if we are early on in the game
    case let highestTileValue where highestTileValue <= 224:
        freq[14] = 0.03
        freq[28] = 0.02
        freq[56] = 0.01
    case let highestTileValue where highestTileValue <= 448:
        freq[14] = 0.04
        freq[28] = 0.03
        freq[56] = 0.02
        freq[112] = 0.01
    case let highestTileValue where highestTileValue <= 896:
        freq[14] = 0.05
        freq[28] = 0.05
        freq[56] = 0.03
        freq[112] = 0.02
        freq[224] = 0.01
    default:
        () // do nothing for now
    }
    

    // now adjust frequency based on what has appeared in the past
    if lastXTiles.count >= 5 {
        freq = adjustTileFreq(lastXTiles: lastXTiles, tileValueBoard: tileValueBoard)
    }
    
    // we want to avoid the sceanior where multiple things of the same value (unless it's 7) comes out in a row
    var validValue = false
    var randNumber : Double
    
    while validValue == false {
        // user random number generator from 1-100 for 100%
        randNumber = Double(Int.random(in: 0..<101))/100
        
        // create tile with certain value depending on the frequencies
        switch randNumber {
        case let randNumber where randNumber <= freq[2]!:
            newTileValue = 2
        case let randNumber where randNumber <= freq[2]!+freq[5]!:
            newTileValue = 5
        case let randNumber where randNumber <= freq[2]!+freq[5]!+freq[3]!:
            newTileValue = 3
        case let randNumber where randNumber <= freq[2]!+freq[5]!+freq[3]!+freq[4]!:
            newTileValue = 4
        case let randNumber where randNumber <= freq[2]!+freq[5]!+freq[3]!+freq[4]!+freq[14]!:
            newTileValue = 14
        case let randNumber where randNumber <= freq[2]!+freq[5]!+freq[3]!+freq[4]!+freq[14]!+freq[28]!:
            newTileValue = 28
        case let randNumber where randNumber <= freq[2]!+freq[5]!+freq[3]!+freq[4]!+freq[14]!+freq[28]!+freq[56]!:
            newTileValue = 56
        case let randNumber where randNumber <= freq[2]!+freq[5]!+freq[3]!+freq[4]!+freq[14]!+freq[28]!+freq[56]!+freq[112]!:
            newTileValue = 112
        case let randNumber where randNumber <= freq[2]!+freq[5]!+freq[3]!+freq[4]!+freq[14]!+freq[28]!+freq[56]!+freq[112]!+freq[224]!:
            newTileValue = 224
        default:
            newTileValue = 7 // anything else we generate 7
        }
        
        if lastXTiles.count < 4 {
            validValue = true
        } else {
            if !(newTileValue == lastXTiles[lastXTiles.count-1] && newTileValue == lastXTiles[lastXTiles.count-2] && newTileValue != 7) {
                    validValue = true
            }
        }
    }
    
    return newTileValue
}


func getEmptyIndicesFromGameboard(tileValueBoard: Gameboard<Int>) -> [(Int, Int)]{
    var emptyTileIndices = [(Int, Int)]()
    for i in 0..<tileValueBoard.dimension {
        for j in 0..<tileValueBoard.dimension{
            if tileValueBoard[j,i] == 0 { emptyTileIndices += [(i, j)] }
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

func canBeCombined2(v1: Int, v2: Int) -> (Bool, String) {
    if (v1 == 2 && v2 == 5) || (v1 == 5 && v2 == 2) { // 5+2 makes 7
        return (true, "case 1")
    } else if (v1 == 3 && v2 == 4) || (v1 == 4 && v2 == 3) { // 3+4 makes 7
        return (true, "case 2")
    } else if v1 == 2 && v2 == 2 { // 2+2 makes 4
        return (true, "case 3")
    } else if (v1 != 5 && v1 != 3 && v1 != 4) && v1==v2 {
        return (true, "case 4")
    }
    return (false, "nocase")
}

func calculateScores(tileValueBoard: Gameboard<Int>) -> Int{
    var value: Int
    var score : Int = 0
    for i in 0..<tileValueBoard.dimension {
        for j in 0..<tileValueBoard.dimension {
            value = tileValueBoard[i,j]
            switch value {
            case 0, 2, 3, 4, 5, 7:
                score += value
            default:
                score += value
                // score += 7 * Int(pow(Double(2.00), Double(value/7)))

            }
        }
    }
    return score

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










