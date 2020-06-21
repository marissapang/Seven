//
//  ViewController.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    //MARK: Properties
    
    // Unchanged properties
    let dimensions : Int = 4
    let tileSpacing : CGFloat = 15
    var sizeAndPositionsDict = [String:CGFloat]()
    
    // Properties used to keep track of gameboard
    var tileValueBoard : Gameboard<Int>
    var tileViewBoard : Gameboard<TileView?>
    var tileAnimationBoard : Gameboard<UIViewPropertyAnimator>
    var rowIndexPositionBoard : Gameboard<Int>
    var colIndexPositionBoard : Gameboard<Int>
    
    // Properties used to keep track of everything not on gameboard
    var viewsToBeDeleted = [TileView]()
    var nextTileValue : Int = 7
    var direction = Direction.undefined
    
    
    //MARK: Initialization
    init(){
        tileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        tileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        tileAnimationBoard = Gameboard<UIViewPropertyAnimator>(d: dimensions, initialValue: UIViewPropertyAnimator())
        rowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        colIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        tileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
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
                
        var animator : UIViewPropertyAnimator, rowInd : Int, colInd : Int, xShift : CGFloat, yShift : CGFloat
        
        for row in 0..<dimensions {
            for col in 0..<dimensions {
                if let subview = tileViewBoard[row,col] { //if subview is not nil
                    
                    
                    rowInd = rowIndexPositionBoard[row, col]
                    colInd = colIndexPositionBoard[row, col]
                    
                    xShift = sizeAndPositionsDict["tileWidth"]! * CGFloat(rowInd) + sizeAndPositionsDict["spacing"]! * CGFloat(rowInd)
                    
                    yShift = sizeAndPositionsDict["tileHeight"]! * CGFloat(colInd) + sizeAndPositionsDict["spacing"]! * CGFloat(colInd)
                    
                    animator = tileAnimationBoard[row,col]
                    animator = UIViewPropertyAnimator(duration: 0.01, curve: .linear, animations: {
                        subview.transform = CGAffineTransform(translationX: xShift, y: yShift)
                    })
                    animator.startAnimation()
                    self.view.addSubview(subview)
                }
            }
        }
    }
    
    func animateTiles(direction: Direction){
        var animator : UIViewPropertyAnimator, rowInd : Int, colInd : Int, xShift : CGFloat, yShift : CGFloat
        
        var count : Int = 0
        for row in 0..<dimensions {
            for col in 0..<dimensions {
                if let subview = tileViewBoard[row,col] { //if subview is not nil
                    count += 1
                    
                    rowInd = rowIndexPositionBoard[row, col]
                    colInd = colIndexPositionBoard[row, col]
                    
                    xShift = sizeAndPositionsDict["tileWidth"]! * CGFloat(rowInd) + sizeAndPositionsDict["spacing"]! * CGFloat(rowInd)
                    
                    yShift = sizeAndPositionsDict["tileHeight"]! * CGFloat(colInd) + sizeAndPositionsDict["spacing"]! * CGFloat(colInd)
                    
                    animator = tileAnimationBoard[row,col]
                    animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut, animations: {
                        subview.transform = CGAffineTransform(translationX: xShift, y: yShift)
                    })
                    
                    animator.startAnimation()
                    
                    if count == 1 {
                        animator.addCompletion { _ in
                            print("inside added completion")
                            let nextTileView : TileView = self.addNextTileView()
                            self.addNextTileOntoBoard(direction: direction, nextTileView: nextTileView)
                        }
                    }
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
    
    func addNextTileView() -> TileView {
        // generate a tile view based on the value generate for the next time, this tile is currently hidden at (0,0)
        let nextTileView = TileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: nextTileValue)
        
        // after creating the view generate the next-up tile value
        nextTileValue = generateRandTileValue(tileValueBoard: tileValueBoard)
        
        return nextTileView
    }
    
    func addNextTileOntoBoard(direction: Direction, nextTileView: TileView) {
        // 1. figure out which index the new tile should be added based on the swipe direction
        let (newTileRow, newTileCol) = addTile(direction: direction, tileValueBoard: tileValueBoard)
        
        // 2. animate and move the tile to corresponding side of the board, still not added to subview
                
        // noote: newTileRow and newColRow are on a 0 to d-1 scale as oppose to the 0 to d+1 animation scale we're using
        let prepRow : Int
        let prepCol : Int
        switch direction {
        case .up:
            prepRow = newTileRow + 1
            prepCol = dimensions + 1
        case .down:
            prepRow = newTileRow + 1
            prepCol = 0
        case .left:
            prepRow = dimensions + 1
            prepCol = newTileCol + 1
        case .right:
            prepRow = 0
            prepCol = newTileCol + 1
        default:
            prepRow = 0
            prepCol = 0
        }
       
       let xShift = sizeAndPositionsDict["tileWidth"]! * CGFloat(prepRow) + sizeAndPositionsDict["spacing"]! * CGFloat(prepRow)
       
       let yShift = sizeAndPositionsDict["tileHeight"]! * CGFloat(prepCol) + sizeAndPositionsDict["spacing"]! * CGFloat(prepCol)
        
        let animator = UIViewPropertyAnimator(duration: 3.0, curve: .easeInOut, animations: {
           nextTileView.transform = CGAffineTransform(translationX: xShift, y: yShift)
        })
       animator.startAnimation()
        
        // 3. animate and move the tile to the correct position
        // 4. add tile to view board, value to value board, col/row index to col/row index board, and maybe add the animation to the animation board but probably unneccessary
        let nextXShift: CGFloat
        let nextYShift: CGFloat
        
        switch direction {
        case .up, .down:
            nextXShift = xShift
            nextYShift = sizeAndPositionsDict["tileHeight"]! * CGFloat(newTileCol + 1) + sizeAndPositionsDict["spacing"]! * CGFloat(newTileCol + 1)
            
        case .left, .right:
            nextXShift = sizeAndPositionsDict["tileWidth"]! * CGFloat(newTileRow + 1) + sizeAndPositionsDict["spacing"]! * CGFloat(newTileRow + 1)
            nextYShift = yShift
        default:
            nextXShift = 0
            nextYShift = 0
        }
        
        let animator2 = UIViewPropertyAnimator(duration: 0.1, curve: .linear, animations: {
            nextTileView.transform = CGAffineTransform(translationX: nextXShift, y: nextYShift)})
        
        
        animator2.addCompletion { _ in
            // when animation is completed we want to update tile value for all tiles
            for row in 0..<self.dimensions {
                for col in 0..<self.dimensions {
                    if let view = self.tileViewBoard[row, col] { // if view exists
                        if view.value != self.tileValueBoard[row, col]{ // and if the value has changed
                            view.value = self.tileValueBoard[row, col]
                            self.tileViewBoard[row, col] = view
                        }
                    }
                }
            }
        }
        
        animator.addCompletion { _ in
            self.view.addSubview(nextTileView)
            self.tileViewBoard[newTileRow, newTileCol] = nextTileView
            self.tileValueBoard[newTileRow, newTileCol] = nextTileView.value
            self.rowIndexPositionBoard[newTileRow, newTileCol] = newTileRow + 1
            self.colIndexPositionBoard[newTileRow, newTileCol] = newTileCol + 1
            animator2.startAnimation()
        }
        
    
        
    }
        
    //MARK: Swipe-related functions
    
   
    
    private func directionFromVelocity(_ velocity: CGPoint) -> Direction {
        guard velocity != .zero else { return .undefined }
        let isVertical = abs(velocity.y) > abs(velocity.x)
        var derivedDirection: Direction = .undefined
        if isVertical {
            derivedDirection = velocity.y < 0 ? .up : .down
        } else {
            derivedDirection = velocity.x < 0 ? .left : .right
        }
        return derivedDirection
    }
    
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(handlePan(recognizer:)))
        return recognizer
    }()
    
    //MARK: Placeholder swipes
    
    @IBAction func swipeUp(_ sender: Any) {
        print("swipeUp button clicked")
        direction = .up
        
        (tileValueBoard, tileViewBoard, viewsToBeDeleted, rowIndexPositionBoard, colIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)
        
        
        animateTiles(direction: direction)
        deleteOldTiles()
    }
    
    @IBAction func swipeDown(_ sender: Any) {
        print("swipeDown button clicked")
        direction = .down
        
        (tileValueBoard, tileViewBoard, viewsToBeDeleted, rowIndexPositionBoard, colIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)
        
        animateTiles(direction: direction)
        deleteOldTiles()
    }
        
    @IBAction func swipeLeft(_ sender: Any) {
        print("swipeLeft button clicked")
        direction = .left

        (tileValueBoard, tileViewBoard, viewsToBeDeleted, rowIndexPositionBoard, colIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)
        animateTiles(direction: direction)
        deleteOldTiles()
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        print("swipeRight button clicked")
        direction = .right

        (tileValueBoard, tileViewBoard, viewsToBeDeleted, rowIndexPositionBoard, colIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)
        
        animateTiles(direction: direction)
        deleteOldTiles()
    }


}

