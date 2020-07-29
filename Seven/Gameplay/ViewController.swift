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
    
    /* Appearance */
    let dimensions : Int = 4
    let tileSpacing : CGFloat = 15
    let smallTileScale : CGFloat = 0.75
    var sizeAndPositionsDict = [String:CGFloat]()
    
    /* Next tile generation */
    
    // Currently scores above 28 are calculated based on the rounded value of log base 21 of (7^x) where x is the x such that 2x*7 = score
    let scoreDict : [Int: Int] = [0: 0, 2: 2, 3: 3, 4: 4, 5: 5, 7:7, 14: 18, 28: 36, 56: 107, 112: 286, 224: 716, 448: 1718, 896: 4009, 1792: 9163, 3584: 20616, 7168: 45814, 14336: 100792, 28672: 219909, 57344: 476469, 114688: 1026242]
    var freqTracking : [Int: Int] = [2: 0, 3: 0, 4: 0, 5: 0]
    var nextTileValue : Int = 7
    var nextNextTileValue : Int = 7
    var lensView = LensView(sizeAndPositionsDict: ["tileWidth":100, "tileHeight":100, "gameboardWidth":1000, "gameboardHeight":1000, "gameboardX":0, "gameboardY":0, "tileX":0, "tileY":0, "spacing":10], imageName: "lensImage")
    var lensFrameView = LensView(sizeAndPositionsDict: ["tileWidth":100, "tileHeight":100, "gameboardWidth":1000, "gameboardHeight":1000, "gameboardX":0, "gameboardY":0, "tileX":0, "tileY":0, "spacing":10], imageName: "lensOutline")
    
    /* Gameboard Tracking */
    var tileValueList = [Int]()
    var tileValueBoard : Gameboard<Int>
    var tileViewBoard : Gameboard<TileView?>
    var tileAnimationBoard : Gameboard<UIViewPropertyAnimator>
    var rowIndexPositionBoard : Gameboard<Int>
    var colIndexPositionBoard : Gameboard<Int>
    
    var newTileValueBoard : Gameboard<Int>
    var newTileViewBoard : Gameboard<TileView?>
    var newViewsToBeDeleted = [TileView]()
    var newRowIndexPositionBoard : Gameboard<Int>, newColIndexPositionBoard : Gameboard<Int>
    
    var viewsToBeDeleted = [TileView]()
    
    /* Game Level Tracking */
    var gameMode : Int = 0
    var newGameMode : Int = 0
    let tutorialInitialFreq : [Int : Double] = [2: 0.2, 5: 0.2, 3: 0.2, 4: 0.2]
    let regularInitialFreq : [Int : Double] = [2: 0.04, 5: 0.04, 3: 0.04, 4: 0.04]
    let challengerInitialFreq : [Int : Double] = [2: 0.1, 5: 0.1, 3: 0.1, 4: 0.1]
    var initialFreq : [Int : Double] = [2: 0.04, 5: 0.04, 3: 0.04, 4: 0.04]
    var newInitialFreq : [Int : Double] = [2: 0.04, 5: 0.04, 3: 0.04, 4: 0.04]
    var modeChangeWarning = ModeChangeWarning(superviewWidth: 100, superviewHeight: 100, selectedMode: 0)
    
    
    /* Swipe */
    var fractionComplete : CGFloat = 0.0
    var isReversed : Bool = false
    var directionForEndState : Direction = .undefined
    var direction = Direction.undefined
    
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    /* Other game features*/
    var tileTrackingList = [LensTileView?]()
    
    var score : Int = 0
    var scoreView = ScoreView(sizeAndPositionsDict: ["tileWidth":10, "tileHeight":10, "gameboardWidth":100, "gameboardHeight":100, "gameboardX":50, "gameboardY":50, "tileX":50, "tileY":50, "spacing":15])
    var winTileAchieved : Bool = false
    let winTileValue : Int = 3584
    
    var scoreBoard = ScoreBoard()
    var endGamePopupView = EndGamePopupView(superviewWidth: 10, superviewHeight: 10, newHighScore: false)
    var closeEndGameButton = CloseEndGameButton(superviewWidth: 100, superviewHeight: 100)
    
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
        startGame()
    }
    
    //MARK: Set-up game functions
    
    func drawGameboard(sizeAndPositionsDict:[String:CGFloat]){        
        let gameboardView = GameboardView(dimensions: dimensions, sizeAndPositionsDict: sizeAndPositionsDict)
        scoreView = ScoreView(sizeAndPositionsDict: sizeAndPositionsDict)
        
        let restartButton = navButton(sizeAndPositionsDict: sizeAndPositionsDict, x: self.view.frame.size.width * 0.02, labelText: "RESET")
        restartButton.addTarget(self, action:#selector(restartButtonClicked), for: .touchUpInside)
        
        let menuButton = navButton(sizeAndPositionsDict: sizeAndPositionsDict, x: self.view.frame.size.width * 0.98 - sizeAndPositionsDict["gameboardWidth"]!*0.2, labelText: "STATS")
        menuButton.addTarget(self, action:#selector(menuButtonClicked), for: .touchUpInside)
        
        let helpButton = HelpButton(sizeAndPositionsDict: sizeAndPositionsDict)
        helpButton.addTarget(self, action: #selector(helpButtonClicked), for: .touchUpInside)
        
        // let tileTrackingStrip = TileTrackingStrip(sizeAndPositionsDict: sizeAndPositionsDict, superviewWidth: self.view.frame.width, smallTileScale: smallTileScale)
        
        lensView = LensView(sizeAndPositionsDict: sizeAndPositionsDict, imageName: "lensImage")
        lensFrameView = LensView(sizeAndPositionsDict: sizeAndPositionsDict, imageName: "lensOutline")
        
        let modeView = ModeView(sizeAndPositionsDict: sizeAndPositionsDict)
        modeView.tutorialButton.addTarget(self, action:#selector(tutorialModeSelected), for: .touchUpInside)
        modeView.regularButton.addTarget(self, action:#selector(regularModeSelected), for: .touchUpInside)
        modeView.challengerButton.addTarget(self, action:#selector(challengerModeSelected), for: .touchUpInside)
        
        switch gameMode {
        case 0:
            modeView.tutorialButton.backgroundColor = modeView.backgroundColor
            modeView.regularButton.backgroundColor = .clear
            modeView.challengerButton.backgroundColor = .clear
        case 1:
            modeView.tutorialButton.backgroundColor = .clear
            modeView.regularButton.backgroundColor = modeView.backgroundColor
            modeView.challengerButton.backgroundColor = .clear
        case 2:
            modeView.tutorialButton.backgroundColor = .clear
            modeView.regularButton.backgroundColor = .clear
            modeView.challengerButton.backgroundColor = modeView.backgroundColor
        default:
            modeView.tutorialButton.backgroundColor = .clear
            modeView.regularButton.backgroundColor = modeView.backgroundColor
            modeView.challengerButton.backgroundColor = .clear
        }
        
        self.view.addSubview(gameboardView)
        self.view.addSubview(scoreView)
        self.view.addSubview(lensView)
        self.view.addSubview(lensFrameView)
        self.view.addSubview(restartButton)
        self.view.addSubview(menuButton)
        // self.view.addSubview(helpButton)
        self.view.addSubview(modeView)
        self.view.addSubview(modeView.tutorialButton)
        self.view.addSubview(modeView.regularButton)
        self.view.addSubview(modeView.challengerButton)
        
        // self.view.addSubview(tileTrackingStrip)
        
    }
    
    
    
    func setGameMode(){
        // get game mode
        if let savedGameMode = loadMode() {
            gameMode = savedGameMode.gameMode["mode"]!
        } else {
            gameMode = 0
        }
        
        switch gameMode {
        case 0:
            initialFreq = tutorialInitialFreq
        case 1:
            initialFreq = regularInitialFreq
        case 2:
            initialFreq = challengerInitialFreq
        default:
            ()
        }
    }
    
    func startGame(){
        let superviewWidth = self.view.frame.size.width
        let superviewHeight = self.view.frame.size.height
        sizeAndPositionsDict = calculateViewSizeAndPositions(dimensions: dimensions, superviewWidth: superviewWidth, superviewHeight: superviewHeight, spacing: tileSpacing)
        
        
        setGameMode()
        drawGameboard(sizeAndPositionsDict: sizeAndPositionsDict)
        
        
        
        addSmallTile()
        
        // let smallTileHighlight = SmallTileHighlight(sizeAndPositionsDict: sizeAndPositionsDict, smallTileScale: smallTileScale)
        // self.view.addSubview(smallTileHighlight)
        

        
        // if there is a preivous gameboard saved, use that; if not start a new gameboard
        if let savedGameboard = loadTileValueList() {
            tileValueList = savedGameboard.tileValueList["tileValueList"]!
        } else {
            tileValueList = [0]
        }
        
        // if prevSavedBoard is not of length dxd it's the dummy generated by the code
        let prevSavedBoard : Bool = tileValueList.count == dimensions * dimensions ? true : false
        
        if prevSavedBoard == false { // if we are starting new board this is what we do
            (tileValueBoard, tileViewBoard) = addFirstTiles(dimensions: dimensions, sizeAndPositionsDict: sizeAndPositionsDict, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard)
        } else { // if there is a stored gameboard (game must have crashed) we restore what was saved
            
            // make gameboard list into new tile value board
            tileValueBoard = turnTileValueListToBoard(tileValueList: tileValueList)
            
            // update the tileViewBoard accorrding to the tileValueBoard
            var value : Int = 0
            for i in 0..<dimensions {
                for j in 0..<dimensions {
                    value = tileValueBoard[i,j]
                    if value != 0 { // if slot is non-empty we need to generate the view
                        tileViewBoard[i,j] = TileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: value)
                    }
                }
            }
        }
        
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
        scoreView.score = calculateScores(tileValueBoard: tileValueBoard, scoreDict: scoreDict)
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
    
    func resetAnimationBugFix(){
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
        // resetAnimationBugFix()
        // generate a tile view based on the value generate for the next time, this tile is currently hidden at (0,0)
        let nextTileView = TileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: nextTileValue)
        
        // after creating the view generate the next-up tile value
        nextTileValue = nextNextTileValue
        nextNextTileValue = generateRandTileValue(tileValueBoard: tileValueBoard, nextTileValue: nextTileValue, initialFreq: initialFreq, freqTracking: freqTracking, gameMode: gameMode)
        
        let trackedFreqs : [Int] = [2,3,4,5]
        if trackedFreqs.contains(nextNextTileValue) {
            freqTracking[nextNextTileValue]! += 1
        }
        
        return nextTileView
    }
    
    func addNextTileOntoBoard(direction: Direction, nextTileView: TileView) {
        // 1. figure out which index the new tile should be added based on the swipe direction
        let (newTileRow, newTileCol) = addTile(direction: direction, tileValueBoard: tileValueBoard)
        
        // 2. animate and move the tile to corresponding side of the board, still not added to subview
        // note: newTileRow and newColRow are on a 0 to d-1 scale as oppose to the 0 to d+1 animation scale we're using
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
            self.scoreView.score = calculateScores(tileValueBoard: self.tileValueBoard, scoreDict: self.scoreDict)
            
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
        
        // Update the storage of gameboard values so if app crashes we can go back
        tileValueList = turnTileValueBoardToList(tileValueBoard: tileValueBoard)
        saveTileValueList()
        
        // make sure there are no issues by checking # of views = number of values
        var numViews : Int = 0
        var numValues : Int = 0
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                if tileValueBoard[i,j] != 0 {
                    numValues += 1
                }
                if let _ = tileViewBoard[i,j] {
                    numViews += 1
                }
            }
        }
        guard numViews == numValues else {
            fatalError("tileValueBoard and tileViewBoard out of sync")
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
        
        // delete saved gameboard value
        tileValueList = [0]
        saveTileValueList()
        
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
        
        // add confetti if it's a new high score
        if newHighScore == true {
            let confettiTypes: [ConfettiType] = {
                let confettiColors = [
                    (r:149,g:58,b:255), (r:255,g:195,b:41), (r:255,g:101,b:26),
                    (r:123,g:92,b:255), (r:76,g:126,b:255), (r:71,g:192,b:255),
                    (r:255,g:47,b:39), (r:255,g:91,b:134), (r:233,g:122,b:208)
                    ].map { UIColor(red: $0.r / 255.0, green: $0.g / 255.0, blue: $0.b / 255.0, alpha: 1) }

                // For each position x shape x color, construct an image
                return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
                    return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                        return confettiColors.map { color in
                            return ConfettiType(color: color, shape: shape, position: position)
                        }
                    }
                }
            }()

            let confettiCells: [CAEmitterCell] = {
                return confettiTypes.map { confettiType in
                    let cell = CAEmitterCell()

                    cell.scaleRange = 0.1
                    cell.beginTime = 0.00001
                    cell.birthRate = 70
                    cell.contents = confettiType.image.cgImage
                    cell.emissionRange = CGFloat(Double.pi)
                    cell.lifetime = 7
                    cell.spin = 4
                    cell.spinRange = 8
                    cell.velocity = 400
                    cell.velocityRange = 50
                    cell.yAcceleration = -2
                    
                    
                    cell.setValue("plane", forKey: "particleType")
                    cell.setValue(Double.pi, forKey: "orientationRange")
                    cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
                    cell.setValue(Double.pi / 2, forKey: "orientationLatitude")

                    return cell
                }
            }()
            
            let confettiLayer: CAEmitterLayer = {
                let emitterLayer = CAEmitterLayer()

                emitterLayer.emitterCells = confettiCells
                emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.minY-150)
                emitterLayer.emitterSize = CGSize(width: view.bounds.size.width*1.2, height: 100) //view.bounds.size.height)
                emitterLayer.emitterShape = .rectangle
                emitterLayer.frame = view.bounds

                emitterLayer.beginTime = CACurrentMediaTime()
                emitterLayer.lifetime = 2.0
                return emitterLayer
            }()
            
            
            endGamePopupView.layer.addSublayer(confettiLayer)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                confettiLayer.birthRate = 0
            }
        }
    }
    
    //MARK: Save and load functions
    
    private func saveScores() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scoreBoard, toFile: ScoreBoard.ArchiveURL.path)
    }
    
    private func loadScores() -> ScoreBoard? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ScoreBoard.ArchiveURL.path) as? ScoreBoard
    }
    
    private func saveMode() {
        print("inside saveMode")
        let gameModeStorage = GameModeStorage()
        gameModeStorage.gameMode = ["mode": gameMode]
        print(gameModeStorage.gameMode)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(gameModeStorage, toFile: GameModeStorage.ArchiveURL.path)
        print("is succesful save is: \(isSuccessfulSave)")
    }
    
    private func loadMode() -> GameModeStorage? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: GameModeStorage.ArchiveURL.path) as? GameModeStorage
    }
    
    private func saveTileValueList() {
        let gameboardStorage = GameboardStorage()
        gameboardStorage.tileValueList = ["tileValueList":tileValueList]
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(gameboardStorage, toFile: GameboardStorage.ArchiveURL.path)
    }
    
    private func loadTileValueList() -> GameboardStorage? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: GameboardStorage.ArchiveURL.path) as? GameboardStorage
    }
    
    func turnTileValueBoardToList(tileValueBoard: Gameboard<Int>) -> [Int] {
        var tileValueList = [Int](repeating: 0, count: dimensions*dimensions)
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                tileValueList[i*dimensions + j] = tileValueBoard[i,j]
            }
        }
        return tileValueList
    }
    
    func turnTileValueListToBoard(tileValueList: [Int]) -> Gameboard<Int> {
        var savedTileValueBoard = Gameboard(d: dimensions, initialValue: 0)
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                savedTileValueBoard[i,j] = tileValueList[i*dimensions + j]
            }
        }
        return savedTileValueBoard
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
        
        freqTracking = [2: 0, 3: 0, 4: 0, 5: 0]
    
        
        tileValueList = [0]
        saveTileValueList()
        
        // Properties used to keep track of gameboard hint
        tileTrackingList = [LensTileView?]()
        nextTileValue = 7
        nextNextTileValue  = 7
        scoreView.score = 0
        
        // Properties used to keep track of everything not on gameboard
        viewsToBeDeleted = [TileView]()
        direction = Direction.undefined
        winTileAchieved = false
        
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
        let numSmallTiles : Int = 3
        
        // if list is empty, add nextNextTile as 0, nextTile as 1. these should be views
        if tileTrackingList.count == 0 { // if tileTrackingList is empty
            tileTrackingList = Array(repeating: nil, count: numSmallTiles)
            
            tileTrackingList[0] = LensTileView(tileValue: nextNextTileValue, lensWidth: lensView.frame.width/2, lensX: lensView.frame.minX + lensView.frame.width/2/4, lensY: lensView.frame.minY)
            tileTrackingList[1] = LensTileView(tileValue: nextTileValue, lensWidth: lensView.frame.width/2, lensX: lensView.frame.minX + lensView.frame.width/2/4, lensY: lensView.frame.minY)
            
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
            tileTrackingList[0] = LensTileView(tileValue: nextNextTileValue, lensWidth: lensView.frame.width/2, lensX: lensView.frame.minX + lensView.frame.width/2/4, lensY: lensView.frame.minY)
            
            self.view.addSubview(tileTrackingList[0]!)
        }
        lensFrameView.removeFromSuperview()
        scoreView.removeFromSuperview()
        self.view.addSubview(lensFrameView)
        self.view.addSubview(scoreView)
        
        
        
        //after update, animate: y position of view shifts to be a multiple of the index number
        // also animate to make tiles a little smaller when they have arrived
        // for the updated list, add greyness to text for everythng after position 1

        var animator : UIViewPropertyAnimator
        var xShift: CGFloat, yShift: CGFloat
        var positionTrans: CGAffineTransform, shrinkTrans: CGAffineTransform
        var transformScale: CGFloat = 1
        for i in 0..<numSmallTiles {
            if let subview = tileTrackingList[i] { // if tracking tile exists
                xShift = lensView.frame.width/3.7 * CGFloat(i) // + tileSpacing * CGFloat(i)
                
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
    
    /*
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
*/
    

    
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
    
    func countNumTiles() -> Int {
        var countTiles : Int = 0
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                if tileValueBoard[i,j] != 0 {
                    countTiles += 1
                }
            }
        }
        return countTiles
    }
    
    @objc func tutorialModeSelected(){
        print("in tutorial mode")
        let numTiles = countNumTiles()
        if numTiles <= 2{
            gameMode = 0
            initialFreq = tutorialInitialFreq
            saveMode()
            restartGame()
        } else {
            newGameMode = 0
            newInitialFreq = tutorialInitialFreq
            modeChangeWarning = ModeChangeWarning(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height, selectedMode: newGameMode)
            
            modeChangeWarning.noButton.addTarget(self, action: #selector(closeModeChangeWarning), for: .touchUpInside)
            modeChangeWarning.yesButton.addTarget(self, action: #selector(confirmModeChangeWarning), for: .touchUpInside)
            self.view.addSubview(modeChangeWarning)
            self.view.addSubview(modeChangeWarning.noButton)
            self.view.addSubview(modeChangeWarning.yesButton)
        }
    }
    
    @objc func regularModeSelected(){
        print("in regular mode")
        let numTiles = countNumTiles()
        if numTiles <= 2{
            gameMode = 1
            initialFreq = regularInitialFreq
            saveMode()
            restartGame()
        } else {
            newGameMode = 1
            newInitialFreq = regularInitialFreq
            modeChangeWarning = ModeChangeWarning(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height, selectedMode: newGameMode)
            
            modeChangeWarning.noButton.addTarget(self, action: #selector(closeModeChangeWarning), for: .touchUpInside)
            modeChangeWarning.yesButton.addTarget(self, action: #selector(confirmModeChangeWarning), for: .touchUpInside)
            self.view.addSubview(modeChangeWarning)
            self.view.addSubview(modeChangeWarning.noButton)
            self.view.addSubview(modeChangeWarning.yesButton)
        }
    }
    
    @objc func challengerModeSelected(){
        print("in challenger mode")
        let numTiles = countNumTiles()
        if numTiles <= 2{
            gameMode = 2
            initialFreq = challengerInitialFreq
            saveMode()
            restartGame()
        } else {
            newGameMode = 2
            newInitialFreq = challengerInitialFreq
            modeChangeWarning = ModeChangeWarning(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height, selectedMode: newGameMode)
            
            modeChangeWarning.noButton.addTarget(self, action: #selector(closeModeChangeWarning), for: .touchUpInside)
            modeChangeWarning.yesButton.addTarget(self, action: #selector(confirmModeChangeWarning), for: .touchUpInside)
            self.view.addSubview(modeChangeWarning)
            self.view.addSubview(modeChangeWarning.noButton)
            self.view.addSubview(modeChangeWarning.yesButton)
        }
    }
    
    @objc func closeModeChangeWarning(){
        modeChangeWarning.removeFromSuperview()
        modeChangeWarning.yesButton.removeFromSuperview()
        modeChangeWarning.noButton.removeFromSuperview()
    }
    
    @objc func confirmModeChangeWarning(){
        gameMode = newGameMode
        initialFreq = newInitialFreq
        saveMode()
        restartGame()
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
        case .ended, .cancelled:
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
                scoreView.score = calculateScores(tileValueBoard: tileValueBoard, scoreDict: scoreDict)
                
                // if the wintile is achieved then we put a crown on the scroeView
                let highestTileValue = calculateHighestTileValue(tileValueBoard: tileValueBoard)
                if winTileAchieved == false && highestTileValue >= winTileValue {
                    let crownBotLeftPct : CGFloat = 0.33
                    let crownBotRightPct : CGFloat = 4.8/8
                    let crownView = UIImageView(image: UIImage(named: "crownImage"))
                    let crownHeight = scoreView.frame.height*0.65
                    let crownWidth = crownHeight*2642/2048
                    
                    crownView.frame = CGRect(x: scoreView.frame.minX - crownWidth*crownBotLeftPct, y: scoreView.frame.minY-crownHeight*crownBotRightPct, width: crownWidth, height: crownHeight)
                    crownView.contentMode = .scaleAspectFill
                    
                    self.view.addSubview(crownView)
                    winTileAchieved = true
                }
                
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



