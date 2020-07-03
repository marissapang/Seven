//
//  GameModel.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit
import os.log

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

struct PropertyKey {
    static let tileCount = "tileCount"
    static let runningStats = "runningStats"

}

class ScoreBoard: NSObject, NSCoding {
    //MARK: Properties
    var tileCount: [Int : Int]
    var runningStats: [String : Int]
        
    
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("highScore")
    
    
    //MARK: Initialization
    required init(coder aDecoder: NSCoder){
        runningStats = aDecoder.decodeObject(forKey: PropertyKey.runningStats) as? [String : Int] ?? ["highScore":0, "totalGamesPlayed":0]
        
        tileCount = aDecoder.decodeObject(forKey: PropertyKey.tileCount) as? [Int:Int] ?? [112: 0, 224: 0, 448: 0, 896: 0, 1792: 0, 3584: 0, 7168: 0, 14336: 0]
    }
    
    override init (){
        self.tileCount = [112: 0, 224: 0, 448: 0, 896: 0, 1792: 0, 3584: 0, 7168: 0, 14336: 0]
        self.runningStats = ["highScore":0, "totalGamesPlayed":0]
    }
    
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(tileCount, forKey: PropertyKey.tileCount)
        aCoder.encode(runningStats, forKey: PropertyKey.runningStats)
    }
    
    
    
}

