//
//  ViewController.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: Unchanged properties
    let dimensions : Int = 4
    let tileSpacing : CGFloat = 15
    var sizeAndPositionsDict = [String:CGFloat]()
    
    //MARK: Modified properties
    var tileValueBoard : Gameboard<Int>
    var tileMovementBoard : Gameboard<Movement>
    var tileViewBoard : Gameboard<TileView?>
    var tileAnimationBoard : Gameboard<UIViewPropertyAnimator>
    var rowIndexPositionBoard : Gameboard<Int>
    var colIndexPositionBoard : Gameboard<Int>
    
    var viewsToBeDeleted = [TileView]()
    
    var nextTileValue : Int = 7
    var direction = Direction.undefined
    
    //MARK: Placeholder swipes
    
    @IBAction func swipeUp(_ sender: Any) {
        print("swipeUp button clicked")
        direction = .up
        
        var newTileViewBoard : Gameboard<TileView?>
        var newTileValueBoard : Gameboard<Int>
        var newRowIndexPositionBoard : Gameboard<Int>
        var newColIndexPositionBoard : Gameboard<Int>
        
        (tileValueBoard, tileViewBoard, viewsToBeDeleted, rowIndexPositionBoard, colIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)
        
        animateTiles()
        deleteOldTiles()
        
    }
    @IBAction func swipeDown(_ sender: Any) {
        print("swipeDown button clicked")
        direction = .down
        
        (tileValueBoard, tileViewBoard, viewsToBeDeleted, rowIndexPositionBoard, colIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)
        
        animateTiles()
        deleteOldTiles()
    }
    @IBAction func swipeLeft(_ sender: Any) {
        print("swipeLeft button clicked")
        direction = .left

        (tileValueBoard, tileViewBoard, viewsToBeDeleted, rowIndexPositionBoard, colIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)
        
        animateTiles()
        deleteOldTiles()
    }
    @IBAction func swipeRight(_ sender: Any) {
        print("swipeRight button clicked")
        direction = .right

        (tileValueBoard, tileViewBoard, viewsToBeDeleted, rowIndexPositionBoard, colIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)
        
        animateTiles()
        deleteOldTiles()
    }
    
    //MARK: Initialization
    init(){
        tileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        tileMovementBoard = Gameboard<Movement>(d: dimensions, initialValue: .stay)
        tileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        tileAnimationBoard = Gameboard<UIViewPropertyAnimator>(d: dimensions, initialValue: UIViewPropertyAnimator())
        rowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        colIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        tileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        tileMovementBoard = Gameboard<Movement>(d: dimensions, initialValue: .stay)
        tileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        tileAnimationBoard = Gameboard<UIViewPropertyAnimator>(d: dimensions, initialValue: UIViewPropertyAnimator())
        rowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        colIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startGame()
    }
    
    //MARK: Game Functions
    
    func drawGameboard(sizeAndPositionsDict:[String:CGFloat]){        
        let gameboardView = GameboardView(dimensions: dimensions, sizeAndPositionsDict: sizeAndPositionsDict)
        self.view.addSubview(gameboardView)
        
        
    }
    func startGame(){
        let superviewWidth = self.view.frame.size.width
        let superviewHeight = self.view.frame.size.height
        sizeAndPositionsDict = calculateViewSizeAndPositions(dimensions: dimensions, superviewWidth: superviewWidth, superviewHeight: superviewHeight, spacing: tileSpacing)
        
        drawGameboard(sizeAndPositionsDict: sizeAndPositionsDict)
        
        (tileValueBoard, tileViewBoard) = addFirstTiles(dimensions: dimensions, sizeAndPositionsDict: sizeAndPositionsDict, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard)
        
        (rowIndexPositionBoard, colIndexPositionBoard) = initialUpdateOfIndexPositionBoards(dimensions: dimensions, tileValueBoard : tileValueBoard, rowIndexPositionBoard : rowIndexPositionBoard, colIndexPositionBoard : colIndexPositionBoard)
                
        var animator : UIViewPropertyAnimator
        var rowInd : Int
        var colInd : Int
        var xShift : CGFloat
        var yShift : CGFloat
        
        for row in 0..<dimensions {
            for col in 0..<dimensions {
                if let subview = tileViewBoard[row,col] { //if subview is not nil
                    
                    
                    rowInd = rowIndexPositionBoard[row, col]
                    colInd = colIndexPositionBoard[row, col]
                    
                    xShift = sizeAndPositionsDict["tileWidth"]! * CGFloat(rowInd) + sizeAndPositionsDict["spacing"]! * CGFloat(rowInd)
                    
                    yShift = sizeAndPositionsDict["tileHeight"]! * CGFloat(colInd) + sizeAndPositionsDict["spacing"]! * CGFloat(colInd)
                    
                    animator = tileAnimationBoard[row,col]
                    animator = UIViewPropertyAnimator(duration: 0.01, curve: .easeInOut, animations: {
                        subview.transform = CGAffineTransform(translationX: xShift, y: yShift)
                    })
                    animator.startAnimation()
                    self.view.addSubview(subview)
                }
            }
        }
    }
    
    func animateTiles(){
        var animator : UIViewPropertyAnimator, rowInd : Int, colInd : Int, xShift : CGFloat, yShift : CGFloat
        
        for row in 0..<dimensions {
            for col in 0..<dimensions {
                if let subview = tileViewBoard[row,col] { //if subview is not nil
                    
                    
                    rowInd = rowIndexPositionBoard[row, col]
                    colInd = colIndexPositionBoard[row, col]
                    
                    xShift = sizeAndPositionsDict["tileWidth"]! * CGFloat(rowInd) + sizeAndPositionsDict["spacing"]! * CGFloat(rowInd)
                    
                    yShift = sizeAndPositionsDict["tileHeight"]! * CGFloat(colInd) + sizeAndPositionsDict["spacing"]! * CGFloat(colInd)
                    
                    animator = tileAnimationBoard[row,col]
                    animator = UIViewPropertyAnimator(duration: 2.0, curve: .easeInOut, animations: {
                        subview.transform = CGAffineTransform(translationX: xShift, y: yShift)
                    })
                    animator.startAnimation()
                    
                }
            }
        }
        
    }
    
    func deleteOldTiles(){
        for i in 0..<Int(viewsToBeDeleted.count){
            viewsToBeDeleted[i].removeFromSuperview()
        }
        viewsToBeDeleted = [TileView]()
    }
    
    func moveNextTileToBoard(){
        
    }
    
    func generateNextTile(){
        
    }


}

