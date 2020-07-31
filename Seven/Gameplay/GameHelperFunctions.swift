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

func generateRandTileValue(tileValueBoard: Gameboard<Int>, nextTileValue: Int, initialFreq: [Int: Double], freqTracking: [Int: Int]) -> Int {
    // first normalize freq tracking so out of 2 and 5 one is 0, and so on
    let normalizedFreqTracking = normalizeFreqTracking(freqTracking: freqTracking)
    let highestTileValue = calculateHighestTileValue(tileValueBoard: tileValueBoard)
    
    // the adjusted frequency will be different depending on the highestTileValue
    var (adjustedFreq, freqSum) = adjustInitialFreq(initialFreq: initialFreq, normalizedFreqTracking: normalizedFreqTracking, highestTileValue: highestTileValue)
        
    // adjustedFreq contains frequencies (as decimal probablities) for 2, 5, 3, 4. We will take the leftover probability and spread it along 7, and higher tiles depending on what the current highest tile is
    let leftoverProb = 1 - freqSum
    
    let highTileFreq = calculateHighTileFreq(leftOverProb: leftoverProb, highestTileValue: highestTileValue)
    
    let freq = adjustedFreq.merging(highTileFreq) { (current, _) in current }
      
    // print("freq is: \(freq)")
    // check that frequencies of everything = 1
    var checkFreq : Double = 0
    for (_, value) in freq {
        checkFreq += value
    }
    
    checkFreq = round(checkFreq)
    
    guard checkFreq == 1 else {
        fatalError("frequencies do not add up to 1 D:")
    }
    
    // user random number generator from 1-100 for 100%
    let randNumber = Double(Int.random(in: 0..<101))/100
    var newTileValue : Int
    
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
    case let randNumber where randNumber <= freq[2]!+freq[5]!+freq[3]!+freq[4]!+freq[14]!+freq[28]!+freq[56]!+freq[112]!+freq[224]!:
        newTileValue = 448
    default:
        newTileValue = 7 // anything else we generate 7
    }
    
    // let newTileValue = 7
    return newTileValue
}

func normalizeFreqTracking(freqTracking: [Int: Int]) -> [Int: Int]{
    var normalizedFreqTracking = freqTracking
    // first compare 3 and 4 and subtract accordingly
    let min34 = min(normalizedFreqTracking[3]!, normalizedFreqTracking[4]!)
    normalizedFreqTracking[3]! -= min34
    normalizedFreqTracking[4]! -= min34
    
    // then compare 2 and 5
    let min25 = min(normalizedFreqTracking[2]!, normalizedFreqTracking[5]!)
    normalizedFreqTracking[2]! -= min25
    normalizedFreqTracking[5]! -= min25
    
    // compare 3 and 2's at a ratio if there is any left over
//    let min23 = min(normalizedFreqTracking[3]!, Int(floor(CGFloat(normalizedFreqTracking[2]!/2))))
//    normalizedFreqTracking[2]! -= min23 * 2
//    normalizedFreqTracking[3]! -= min23
    
    return normalizedFreqTracking
}

func adjustInitialFreq(initialFreq: [Int: Double], normalizedFreqTracking: [Int: Int], highestTileValue: Int) -> ([Int: Double], Double) {
    var adjustedFreq = initialFreq
    
    // in early game, we want game to be super easy
    if highestTileValue <= 224 {
        for (key, value) in adjustedFreq {
            adjustedFreq[key] = value/3
        }
        if normalizedFreqTracking[4]! > 0 {
            adjustedFreq[3] =  0.85
            adjustedFreq[4] = 0
        }
        if normalizedFreqTracking[5]! > 0 {
            adjustedFreq[2] = 0.85
            adjustedFreq[5] = 0
        }
        if normalizedFreqTracking[3]! > 0 {
            adjustedFreq[4] = 0.85
            adjustedFreq[3] = 0
        }
        if normalizedFreqTracking[2]! > 0 {
            adjustedFreq[5] = 0.85
            adjustedFreq[2] = 0
        }
    } else { //if highestTileValue < 896 {
        if normalizedFreqTracking[4]! > 0 {
            adjustedFreq[3] =  min(initialFreq[3]! * Double(2*(2+normalizedFreqTracking[4]!)), 0.9)
            adjustedFreq[4] = initialFreq[4]! / Double(normalizedFreqTracking[4]!*2)
        }
        
        if normalizedFreqTracking[5]! > 0 {
            adjustedFreq[2] = min(initialFreq[2]! * Double(2*(2+normalizedFreqTracking[5]!)), 0.9)
            adjustedFreq[5] = initialFreq[5]! / Double(normalizedFreqTracking[5]!*2)
        }
        
        if normalizedFreqTracking[3]! > 0 {
            adjustedFreq[4] = min(initialFreq[4]! * Double(2*(2+normalizedFreqTracking[3]!)), 0.9)
            adjustedFreq[3] = initialFreq[3]! / Double(normalizedFreqTracking[3]!*2)
        }
        
        if normalizedFreqTracking[2]! > 0 {
            adjustedFreq[5] = min(initialFreq[5]! * Double(2*(2+normalizedFreqTracking[2]!)), 0.9)
            adjustedFreq[2] = initialFreq[2]! / Double(normalizedFreqTracking[2]!*2)
        }
    } /* else if highestTileValue >= 896 {
        // first make the probability for a 2,3,4,5 to appear much smaller
        for (key, value) in adjustedFreq {
            adjustedFreq[key] = value/1.75
        }
        
        // at the same time, if one of 2,3,4,5 does appear, a complement number appears much more quickly
        
        if normalizedFreqTracking[4]! > 0 {
            adjustedFreq[3] =  min(initialFreq[3]! * Double(8*(2+normalizedFreqTracking[4]!)), 0.9)
            adjustedFreq[4] = initialFreq[4]! / Double(normalizedFreqTracking[4]!*2)
        }
        
        if normalizedFreqTracking[5]! > 0 {
            adjustedFreq[2] = min(initialFreq[2]! * Double(8*(2+normalizedFreqTracking[5]!)), 0.9)
            adjustedFreq[5] = initialFreq[5]! / Double(normalizedFreqTracking[5]!*2)
        }
        
        if normalizedFreqTracking[3]! > 0 {
            adjustedFreq[4] = min(initialFreq[4]! * Double(8*(2+normalizedFreqTracking[3]!)), 0.9)
            adjustedFreq[3] = initialFreq[3]! / Double(normalizedFreqTracking[3]!*2)
        }
        
        if normalizedFreqTracking[2]! > 0 {
            adjustedFreq[5] = min(initialFreq[5]! * Double(8*(2+normalizedFreqTracking[2]!)), 0.9)
            adjustedFreq[2] = initialFreq[2]! / Double(normalizedFreqTracking[2]!*2)
        }
    }
 */
    
    // if the sums of the adjusted frequencies are too large (i.e. almost over 1) then lower it down proportionally across the board
    let freqSum = adjustedFreq[2]! + adjustedFreq[5]! + adjustedFreq[3]! + adjustedFreq[4]!
     
    if freqSum > 0.95 {
        let ratio : Double = 0.95/freqSum
        for (key, value) in adjustedFreq {
            adjustedFreq[key] = value * ratio
        }
    }
    let adjustedFreqSum = adjustedFreq[2]! + adjustedFreq[5]! + adjustedFreq[3]! + adjustedFreq[4]!
        
    return (adjustedFreq, adjustedFreqSum)
}

func calculateHighTileFreq(leftOverProb: Double, highestTileValue: Int) -> [Int: Double]{
    
    var highTileFreq : [Int: Double] = [7: 0, 14: 0, 28: 0, 56: 0, 112: 0, 224: 0, 448: 0]
        
    // frequencies change depenign on hfar in we are in the game
    switch highestTileValue {
    case let highestTileValue where highestTileValue <= 112:
        () // change nothing if we are early on in the game
    case let highestTileValue where highestTileValue <= 224:
        ()
//        highTileFreq[14] = 0.03
//        highTileFreq[28] = 0.02
//        highTileFreq[56] = 0.005
    case let highestTileValue where highestTileValue <= 448:
        highTileFreq[14] = 0.035
        highTileFreq[28] = 0.03
        highTileFreq[56] = 0.01
    case let highestTileValue where highestTileValue <= 896:
        highTileFreq[14] = 0.02
        highTileFreq[28] = 0.01
        highTileFreq[56] = 0.01
        highTileFreq[112] = 0.005
        highTileFreq[224] = 0.005
    case let highestTileValue where highestTileValue <= 1792:
        highTileFreq[14] = 0.01
        highTileFreq[28] = 0.015
        highTileFreq[56] = 0.015
        highTileFreq[112] = 0.01
        highTileFreq[224] = 0.005
        highTileFreq[448] = 0.005
    default:
        highTileFreq[14] = 0.01
        highTileFreq[28] = 0.01
        highTileFreq[56] = 0.015
        highTileFreq[112] = 0.015
        highTileFreq[224] = 0.01
        highTileFreq[448] = 0.005
    }
    
    let none7Freq = highTileFreq[14]! + highTileFreq[28]! + highTileFreq[56]! + highTileFreq[112]! + highTileFreq[224]! + highTileFreq[448]!
    
    highTileFreq[7] = 1 - none7Freq
    
    // currently the frequencies of these tiles sum to 1, we need them to be adjusted proportionally so tey sum to the leftover probability
    for (key, value) in highTileFreq {
        highTileFreq[key] = value * leftOverProb
    }
    
   return highTileFreq

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
    // } else if v1 == 2 && v2 == 2 { // 2+2 makes 4
        // return true
    } else if (v1 != 5 && v1 != 3 && v1 != 4 && v1 != 2) && v1==v2 {
        return true
    }
    return false
}


func calculateScores(tileValueBoard: Gameboard<Int>, scoreDict: [Int:Int]) -> Int{
    var score : Int = 0
    for i in 0..<tileValueBoard.dimension {
        for j in 0..<tileValueBoard.dimension {
            score += scoreDict[tileValueBoard[i,j]]!
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










