//
//  ViewController.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController {
    //MARK: Properties
    
    // Unchanged properties
    let dimensions : Int = 4
    let tileSpacing : CGFloat = 15
    let smallTileScale : CGFloat = 0.75
    var sizeAndPositionsDict = [String:CGFloat]()
    
    // Properties used to keep track of gameboard
    var tileValueBoard : Gameboard<Int>
    var tileViewBoard : Gameboard<TileView?>
    var tileAnimationBoard : Gameboard<UIViewPropertyAnimator>
    var rowIndexPositionBoard : Gameboard<Int>
    var colIndexPositionBoard : Gameboard<Int>
    
    var lastXTiles = [Int]()
    
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    // Properties used to keep track of gameboard hint
    var tileTrackingList = [SmallTileView?]()
    var nextTileValue : Int = 7
    var nextNextTileValue : Int = 7
    var endGamePopupView = EndGamePopupView(superviewWidth: 10, superviewHeight: 10, newHighScore: false)
    var score : Int = 0
    var scoreView = ScoreView(sizeAndPositionsDict: ["tileWidth":10, "tileHeight":10, "gameboardWidth":100, "gameboardHeight":100, "gameboardX":50, "gameboardY":50, "tileX":50, "tileY":50, "spacing":15])
    // var restartAtEndButton = RestartButton(superviewWidth: 100, superviewHeight: 100)
    var closeEndGameButton = CloseEndGameButton(superviewWidth: 100, superviewHeight: 100)
    
    var scoreBoard = ScoreBoard()
    
    // Properties used to keep track of everything not on gameboard
    var viewsToBeDeleted = [TileView]()
    var direction = Direction.undefined
    
    // Swipe properties
    var fractionComplete : CGFloat = 0.0
    var isReversed : Bool = false
    var directionForEndState : Direction = .undefined
    
    var newTileValueBoard : Gameboard<Int>
    var newTileViewBoard : Gameboard<TileView?>
    var newViewsToBeDeleted = [TileView]()
    var newRowIndexPositionBoard : Gameboard<Int>, newColIndexPositionBoard : Gameboard<Int>
    
    //MARK: Initialization
    init(){
        tileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        tileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        tileAnimationBoard = Gameboard<UIViewPropertyAnimator>(d: dimensions, initialValue: UIViewPropertyAnimator())
        rowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        colIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        newTileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        newTileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        newRowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        newColIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        tileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        tileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        tileAnimationBoard = Gameboard<UIViewPropertyAnimator>(d: dimensions, initialValue: UIViewPropertyAnimator())
        rowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        colIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        newTileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        newTileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        newRowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        newColIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startGame()
    }
    
    
    //MARK: Start-game Functions
    
    func drawGameboard(sizeAndPositionsDict:[String:CGFloat]){        
        let gameboardView = GameboardView(dimensions: dimensions, sizeAndPositionsDict: sizeAndPositionsDict)
        scoreView = ScoreView(sizeAndPositionsDict: sizeAndPositionsDict)
        
        let restartButton = navButton(sizeAndPositionsDict: sizeAndPositionsDict, x: self.view.frame.size.width * 0.02, labelText: "RESTART")
        restartButton.addTarget(self, action:#selector(restartButtonClicked), for: .touchUpInside)
        
        let menuButton = navButton(sizeAndPositionsDict: sizeAndPositionsDict, x: self.view.frame.size.width * 0.98 - sizeAndPositionsDict["gameboardWidth"]!*0.25, labelText: "STATS")
        menuButton.addTarget(self, action:#selector(menuButtonClicked), for: .touchUpInside)
        
        let helpButton = HelpButton(sizeAndPositionsDict: sizeAndPositionsDict)
        
        helpButton.addTarget(self, action: #selector(helpButtonClicked), for: .touchUpInside)

        
        let tileTrackingStrip = TileTrackingStrip(sizeAndPositionsDict: sizeAndPositionsDict, superviewWidth: self.view.frame.width, smallTileScale: smallTileScale)
        
        
        self.view.addSubview(gameboardView)
        self.view.addSubview(scoreView)
        self.view.addSubview(restartButton)
        self.view.addSubview(menuButton)
        self.view.addSubview(helpButton)
        self.view.addSubview(tileTrackingStrip)
        
    }
    
    func startGame(){
        let superviewWidth = self.view.frame.size.width
        let superviewHeight = self.view.frame.size.height
        sizeAndPositionsDict = calculateViewSizeAndPositions(dimensions: dimensions, superviewWidth: superviewWidth, superviewHeight: superviewHeight, spacing: tileSpacing)
        
        drawGameboard(sizeAndPositionsDict: sizeAndPositionsDict)
        
        addSmallTile()
        
        let smallTileHighlight = SmallTileHighlight(sizeAndPositionsDict: sizeAndPositionsDict, smallTileScale: smallTileScale)
        
        self.view.addSubview(smallTileHighlight)
        
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
        
        scoreView.score = calculateScores(tileValueBoard: tileValueBoard)
    }
    
    //MARK: In-game functions
    func animateTiles(direction: Direction, tileViewBoard: Gameboard<TileView?>, rowIndexPositionBoard: Gameboard<Int>, colIndexPositionBoard: Gameboard<Int>) {
                
        var animator : UIViewPropertyAnimator , rowInd : Int, colInd : Int, xShift : CGFloat, yShift : CGFloat
        
        var count : Int = 0
        for row in 0..<dimensions {
            for col in 0..<dimensions {
                if let subview = tileViewBoard[row,col] { //if subview is not nil
                    count += 1
                    
                    rowInd = rowIndexPositionBoard[row, col]
                    colInd = colIndexPositionBoard[row, col]
                    
                    xShift = sizeAndPositionsDict["tileWidth"]! * CGFloat(rowInd) + sizeAndPositionsDict["spacing"]! * CGFloat(rowInd)
                    
                    yShift = sizeAndPositionsDict["tileHeight"]! * CGFloat(colInd) + sizeAndPositionsDict["spacing"]! * CGFloat(colInd)
                    
                    animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear, animations: {
                        subview.transform = CGAffineTransform(translationX: xShift, y: yShift)
                    })
                    
                    
                    tileAnimationBoard[row, col] = animator
                    
                    animator.startAnimation()
                    animator.pauseAnimation()
                    
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
        nextTileValue = nextNextTileValue
        nextNextTileValue = generateRandTileValue(tileValueBoard: tileValueBoard, lastXTiles: lastXTiles)
        
        lastXTiles += [nextNextTileValue]
        if lastXTiles.count > 15 {
            lastXTiles.removeFirst(1)
        }
        
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
        
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut, animations: {
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
            let delay: TimeInterval = 0.01
            self.tileViewBoard[newTileRow, newTileCol] = nextTileView
            self.tileValueBoard[newTileRow, newTileCol] = nextTileView.value
            self.rowIndexPositionBoard[newTileRow, newTileCol] = newTileRow + 1
            self.colIndexPositionBoard[newTileRow, newTileCol] = newTileCol + 1
            self.scoreView.score = calculateScores(tileValueBoard: self.tileValueBoard)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                animator2.startAnimation()
                self.view.addSubview(nextTileView)
                self.addSmallTile()
                // check here if game should end
                if self.gameShouldEnd() == true {
                    self.endGame()
                }
            }
            
        }
        
    
    }
    
    
    //MARK: End-game functions
    func gameShouldEnd() -> Bool {
        // game should end only if both of the following conditions are met
        // 1. there are no empty space on the board AND
        // 2. there are no movements that are possible from any direction
        var emptyCount : Int = 0
        var combinableCount : Int = 0
       
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                if tileValueBoard[i,j] == 0 {
                    emptyCount += 1
                }
            }
        }
        
        var test1: Bool
        var test2: Bool
        
        for i in 0..<dimensions { // don't loop through the the last col cos we're doing +1
            for j in 0..<dimensions {
                if (j != dimensions - 1){
                    test1 = canBeCombined(v1: tileValueBoard[i,j], v2: tileValueBoard[i, j+1])
                } else {
                    test1 = false
                }
                
                if (i != dimensions - 1){
                    test2 = canBeCombined(v1: tileValueBoard[i,j], v2: tileValueBoard[i+1, j])
                } else {
                    test2 = false
                }
                
                if (test1 || test2) == true { combinableCount += 1 }
       
            }
        }

        if emptyCount == 0 && combinableCount == 0 {
               return true
           }
        return false
    }
       
       
    func endGame() {
        // update stats
        if let savedScoreBoard = loadScores() {
            scoreBoard = savedScoreBoard
        }
        
        // increment num of games played by 1
        scoreBoard.runningStats["totalGamesPlayed"]! = scoreBoard.runningStats["totalGamesPlayed"]! + 1
        
        // update high score if new score is a record
        var newHighScore = false
        if scoreView.score > scoreBoard.runningStats["highScore"]! {
            scoreBoard.runningStats["highScore"]! = scoreView.score
            newHighScore = true
        }
        
        // update highest tile value if the highest tile is equal or greater than 112
        let highestTileValue = calculateHighestTileValue(tileValueBoard: tileValueBoard)
        if highestTileValue >= 112 {
            scoreBoard.tileCount[highestTileValue]! += 1
        }
        
        saveScores()
        
        // create endGame view
        endGamePopupView = EndGamePopupView(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height,  newHighScore: newHighScore )
        self.view.addSubview(endGamePopupView)

        closeEndGameButton = CloseEndGameButton(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height)
        
        endGamePopupView.restartButton.addTarget(self, action: #selector(restartAtEnd), for: .touchUpInside)
        closeEndGameButton.addTarget(self, action: #selector(closeEndGameButtonClicked), for: .touchUpInside)
        
        
        
        self.view.addSubview(endGamePopupView)
        self.view.addSubview(closeEndGameButton)
    }
    
    private func saveScores() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scoreBoard, toFile: ScoreBoard.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Scoreboard successfully updated in View Controller.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to update scoreboard D:", log: OSLog.default, type: .error)
        }
                
    }
    
    private func loadScores() -> ScoreBoard? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ScoreBoard.ArchiveURL.path) as? ScoreBoard
    }
    
    func restartGame(){
        // ***** delete all views *****
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        
        // **** reassign propertiies to initial state ****
        tileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        tileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        tileAnimationBoard = Gameboard<UIViewPropertyAnimator>(d: dimensions, initialValue: UIViewPropertyAnimator())
        rowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        colIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        newTileValueBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        newTileViewBoard = Gameboard<TileView?>(d: dimensions, initialValue: nil)
        newRowIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        newColIndexPositionBoard = Gameboard<Int>(d: dimensions, initialValue: 0)
        
        lastXTiles = [Int]()
        
        // Properties used to keep track of gameboard hint
        tileTrackingList = [SmallTileView?]()
        nextTileValue = 7
        nextNextTileValue  = 7
        scoreView.score = 0
        
        // Properties used to keep track of everything not on gameboard
        viewsToBeDeleted = [TileView]()
        direction = Direction.undefined
        
        // Swipe properties
        fractionComplete = 0.0
        isReversed = false
        directionForEndState = .undefined
        
        // **** re-setup game ****
        panGestureRecognizer.isEnabled = true
        startGame()
    }
    
    
    //MARK: Tile Tracking functions
    func addSmallTile(){
        // calculate how many small tiles can fit on the bottom, keep that much length + 1 (+1 bc we want the last tile to slide off the screen before getting deleted) in the list before removing
        let numSmallTiles : Int = Int(ceil(self.view.frame.width / (sizeAndPositionsDict["tileWidth"]! * smallTileScale + tileSpacing) - 0.5)) + Int(1)
        
        
        // if list is empty, add nextNextTile as 0, nextTile as 1. these should be views
        if tileTrackingList.count == 0 { // if tileTrackingList is empty
            tileTrackingList = Array(repeating: nil, count: numSmallTiles)
            
            tileTrackingList[0] = SmallTileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: nextNextTileValue, smallTileScale: smallTileScale)
            tileTrackingList[1] = SmallTileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: nextTileValue, smallTileScale: smallTileScale)
            
            self.view.addSubview(tileTrackingList[0]!)
            self.view.addSubview(tileTrackingList[1]!)
        } else { // if the list is non-empty, shift everything by 1 to the right
            
            // except for the last one, which gets deleted
            if let lastTrackingTile = tileTrackingList[numSmallTiles - 1] {
                lastTrackingTile.removeFromSuperview()
            }
            
            for i in stride(from: numSmallTiles - 2, through: 0, by: -1){
                tileTrackingList[i+1] = tileTrackingList[i]
            }
            
            // lastly, add nextNextTile to the first position
            tileTrackingList[0] = SmallTileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: nextNextTileValue, smallTileScale: smallTileScale)
            
            self.view.addSubview(tileTrackingList[0]!)
            
            // for the new 3rd subview, make text grey and background dimmer
            tileTrackingList[2]!.color = UIColor.gray
            
        }
        
        
        //after update, animate: y position of view shifts to be a multiple of the index number
        // also animate to make tiles a little smaller when they have arrived
        // for the updated list, add greyness to text for everythng after position 1

        var animator : UIViewPropertyAnimator
        var xShift: CGFloat, yShift: CGFloat
        var positionTrans: CGAffineTransform, shrinkTrans: CGAffineTransform
        var transformScale: CGFloat = 1
        for i in 0..<numSmallTiles {
            if let subview = tileTrackingList[i] { // if tracking tile exists
                xShift = sizeAndPositionsDict["tileWidth"]! * smallTileScale * CGFloat(i) + tileSpacing * CGFloat(i)
                
                yShift = 0
                
                
                switch i {
                case 0:
                    transformScale = 0.9
                case 1:
                    transformScale = 1
                case 2..<numSmallTiles:
                    transformScale = 0.9
                default:
                    transformScale = 1
                }
                
                shrinkTrans = CGAffineTransform(scaleX: transformScale, y: transformScale)
                positionTrans = CGAffineTransform(translationX: xShift, y: yShift)
                
                
                animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut, animations: {
                    subview.transform = shrinkTrans.concatenating(positionTrans)
                })
                
                
                animator.startAnimation()
            }
        }
    }
        
    //MARK: Click-related functions
    
    // restart
    @objc func restartAtEnd(sender: UIButton!) {
        restartGame()
    }
    
//    @IBAction func pauseAndRestart(_ sender: Any) {
//        restartGame()
//    }
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        
    }
    
    
    @objc func restartButtonClicked(){
        restartGame()
    }
    
    @objc func closeEndGameButtonClicked(){
        endGamePopupView.removeFromSuperview()
        // restartAtEndButton.removeFromSuperview()
        closeEndGameButton.removeFromSuperview()
        panGestureRecognizer.isEnabled = false
    }
    
    @objc func menuButtonClicked(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate the desired view controller from the storyboard using the view controllers identifier
        // Cast is as the custom view controller type you created in order to access it's properties and methods
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuViewController") as!MenuViewController
        
        menuViewController.modalPresentationStyle = .fullScreen
        menuViewController.modalTransitionStyle = .flipHorizontal

        present(menuViewController, animated: true, completion: nil)
    }
    
    @objc func helpButtonClicked(){
        let tutorialViewController = TutorialViewController()
        tutorialViewController.modalPresentationStyle = .overFullScreen
        present(tutorialViewController, animated: false, completion: nil)
    }
    
    
    //MARK: Swipe-related functions
    
    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        var direction : Direction

        var animator : UIViewPropertyAnimator

        switch recognizer.state {
        case .began:
            direction = directionFromVelocity(recognizer.velocity(in: self.view))
            directionForEndState = direction

            (newTileValueBoard, newTileViewBoard, newViewsToBeDeleted, newRowIndexPositionBoard, newColIndexPositionBoard) = updateGameAfterSwipe(dimensions: dimensions, direction: direction, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard, viewsToBeDeleted: viewsToBeDeleted, rowIndexPositionBoard: rowIndexPositionBoard, colIndexPositionBoard: colIndexPositionBoard)

            animateTiles(direction: direction, tileViewBoard: newTileViewBoard, rowIndexPositionBoard: newRowIndexPositionBoard, colIndexPositionBoard: newColIndexPositionBoard)

        case .changed:
            switch directionForEndState {
            case .left:
                fractionComplete = -recognizer.translation(in: self.view).x / (tileSpacing + sizeAndPositionsDict["tileWidth"]!)
            case .right:
                fractionComplete = recognizer.translation(in: self.view).x / (tileSpacing + sizeAndPositionsDict["tileWidth"]!)
            case .up:
                fractionComplete = -recognizer.translation(in: self.view).y / (tileSpacing + sizeAndPositionsDict["tileHeight"]!)
            case .down:
                fractionComplete = recognizer.translation(in: self.view).y / (tileSpacing + sizeAndPositionsDict["tileHeight"]!)
            default:
                ()
            }
            

            for row in 0..<dimensions {
                for col in 0..<dimensions {
                    animator = tileAnimationBoard[row, col]
                    animator.fractionComplete = fractionComplete
                }
            }
        case .ended:
            
             if fractionComplete < 0.2 {
                 isReversed = true
             } else {
                 isReversed = false
             }
             

             for row in 0..<dimensions {
                 for col in 0..<dimensions {
                     animator = tileAnimationBoard[row, col]
                     animator.isReversed = isReversed
                     animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                 }
             }
            
            if isReversed == false {
                
                
                // if gameboard didn't change it means we swiped in an un-viable way so a new tile shouldn't be added
                var gameboardChanged : Int = 0
                for i in 0..<dimensions {
                    for j in 0..<dimensions {
                        if tileValueBoard[i,j] != newTileValueBoard[i,j] {
                            gameboardChanged += 1
                        }
                    }
                }
                
                tileValueBoard = newTileValueBoard
                tileViewBoard = newTileViewBoard
                viewsToBeDeleted = newViewsToBeDeleted
                rowIndexPositionBoard = newRowIndexPositionBoard
                colIndexPositionBoard = newColIndexPositionBoard
                
                // if gameboard didn't change it means we swiped in an un-viable way so a new tile shouldn't be added
                if gameboardChanged != 0 {
                    let nextTileView : TileView = addNextTileView()
                    addNextTileOntoBoard(direction: directionForEndState, nextTileView: nextTileView)
                    
                }
                scoreView.score = calculateScores(tileValueBoard: tileValueBoard)
                deleteOldTiles()
            }
            
            
            isReversed = false

        default:
            ()
        }
    }
    
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
    
}



