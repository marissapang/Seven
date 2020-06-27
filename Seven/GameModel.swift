//
//  GameModel.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

// Gameboard structure to store tile views, values, and movements
struct Gameboard<T> {
    var boardArray : [T]
    var dimension : Int
    
    init(d: Int, initialValue: T){
        boardArray = [T](repeating: initialValue, count: d*d)
        dimension = d
    }
    
    subscript(row: Int, col: Int) -> T {
        get {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            return boardArray[row*dimension + col]
        }
        set {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            boardArray[row*dimension + col] = newValue
        }
    }
    
    // We mark this function as mutating because it modifies its parent struct
    mutating func setAll(to item: T) {
        for i in 0..<dimension {
            for j in 0..<dimension{
                self[i,j] = item
            }
        }
    }
}

enum Movement {
    case stay, move, delete
}

enum Direction {
    case up, down, left, right, undefined
}

struct swipeTracker {
    var directionAtStart: Direction
    var fractionComplete: CGFloat
    
    init(){
        directionAtStart =  .undefined
        fractionComplete = 0.0
    }
}

