//
//  ViewController.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit
import os.log
import GameKit
// import GoogleMobileAds
import Firebase

/*
 // ADS NOTES
 // at 7:00 on https://www.youtube.com/watch?v=dWnLUH3qCE0 admob youtube video
 // opened addmob and firebase account
 // with ads, need to add a buy premium version
 */

class ViewController: UIViewController, GKGameCenterControllerDelegate, GADRewardedAdDelegate {
    
    //MARK: Properties
    
    var numberCalls: Int = 0
    /* Appearance */
    let dimensions : Int = 4
    let tileSpacing : CGFloat = 12
    let smallTileScale : CGFloat = 0.92
    var sizeAndPositionsDict = [String:CGFloat]()
    
    /* Next tile generation */
    let initialFreq : [Int: Double] = [2: 0.05, 5: 0.05, 3: 0.04, 4: 0.04]
    // Currently scores above 28 are calculated based on the rounded value of log base 21 of (7^x) where x is the x such that 2x*7 = score
    let scoreDict : [Int: Int] = [0: 0, 2: 2, 3: 3, 4: 4, 5: 5, 7:7, 14: 18, 28: 36, 56: 107, 112: 286, 224: 716, 448: 1718, 896: 4009, 1792: 9163, 3584: 20616, 7168: 45814, 14336: 100792, 28672: 219909, 57344: 476469, 114688: 1026242]
    var freqTracking : [Int: Int] = [2: 0, 3: 0, 4: 0, 5: 0]
    var nextTileValue : Int = 7
    var nextNextTileValue : Int = 7
    
    /* Gameboard-tracking */
    var tileValueList = [Int]()
    var tileValueBoard : Gameboard<Int>
    var tileViewBoard : Gameboard<TileView?>
    var tileAnimationBoard : Gameboard<UIViewPropertyAnimator>
    var rowIndexPositionBoard : Gameboard<Int>
    var colIndexPositionBoard : Gameboard<Int>
    var tileTrackingList = [SmallTileView?]()
    
    var newTileValueBoard : Gameboard<Int>
    var newTileViewBoard : Gameboard<TileView?>
    var newViewsToBeDeleted = [TileView]()
    var newRowIndexPositionBoard : Gameboard<Int>, newColIndexPositionBoard : Gameboard<Int>
    
    var viewsToBeDeleted = [TileView]()
    
    /* Tutorial */
    var playTutorialButton = TutorialButton(sizeAndPositionsDict: ["tileWidth":10, "tileHeight":10, "gameboardWidth":100, "gameboardHeight":100, "gameboardX":50, "gameboardY":50, "tileX":50, "tileY":50, "spacing":15])
    var tutorialActive : Bool = false
    var manualTutorialRequest : Bool = false
    var tutorialPaused : Bool = false
    var tutorialBlock = TutorialBlock(sizeAndPositionsDict: ["tileWidth":10, "tileHeight":10, "gameboardWidth":100, "gameboardHeight":100, "gameboardX":50, "gameboardY":50, "tileX":50, "tileY":50, "spacing":15], labelText: "")
    var tutorialIndex : Int = 0
    var tutorialStuckCounter : Int = 0
    let tutorialSequence : [Int] = [7, 7, 7, 7, 7, 3, 4, 7, 7, 2, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,7, 7, 7, 7, 7, 7, 7, 7]
    let tutorialIntroComments: [String] = ["Welcome to SEVEN!", "7s are the building blocks of the game - swipe until you make 14!"]
    var tutorialWaitpoints: [Int:Bool] = [0: false, 2: false, 8: false] // achievements: 0: complete 14, 2: complete 28, 5: complete 3+4,
    var playTutorialWarningView = ClearHistoryPopupView(superviewWidth: 100, superviewHeight: 100)
    let tutorialComments: [Int:String] = [0: "Nice! Keep swipin'", 1: "Can you make 28?", 2: "Awesome!", 3: "Ready for a challenge?", 4: "Ready for a challenge?", 5: "3s only combine with 4s..", 6: "3s only combine with 4s..", 7: "Try combining 3 and 4 to make 7!", 8: "Woo - you now have a 7!", 9: "Woo - you now have a 7!",10: "Similarly, 2s only combine with 5s", 11: "Similarly, 2s only combine with 5s", 12: "Similarly, 2s only combine with 5s", 13: "Similarly, 2s only combine with 5s", 14: "Similarly, 2s only combine with 5s", 15: "You're doing great!", 16: "You're doing great!", 19: "Use the Next Tile hints at the bottom to help you!", 24: "Have fun playing!"]
    
    /* Scoreboard */
    var score : Int = 0
    var scoreView = ScoreView(sizeAndPositionsDict: ["tileWidth":10, "tileHeight":10, "gameboardWidth":100, "gameboardHeight":100, "gameboardX":50, "gameboardY":50, "tileX":50, "tileY":50, "spacing":15])
    var restartButton = navButton(sizeAndPositionsDict: ["tileWidth":10, "tileHeight":10, "gameboardWidth":100, "gameboardHeight":100, "gameboardX":50, "gameboardY":50, "tileX":50, "tileY":50, "spacing":15], x: 10, labelText: "RESET")
    var winTileAchieved : Bool = false
    let winTileValue : Int = 3584
    var scoreBoard = ScoreBoard()
    
    /* Game Center */
    var gcEnabled = Bool()
    var gcDefaultLeaderboard = String ()
    let LEADERBOARD_ID = "highScoreLeaderboard"
    let LOWSCORE_ID = "lowScoreLeaderboard"
    
    
    /* End game */
    var endGamePopupView = EndGamePopupView(superviewWidth: 10, superviewHeight: 10, adCounter: 7, newHighScore: false, secret7168Achievement: false, secret14336Achievement: false)
    // var closeEndGameButton = CloseEndGameButton(superviewWidth: 100, superviewHeight: 100)
    
    /* Ads */
    var rewardedAd: GADRewardedAd?
    var adCounter : Int = 7 {
        didSet {
            restartButton.setTitle("RESET(\(adCounter))", for: [])
        }
    }
    
    /* Swipe */
    var fractionComplete : CGFloat = 0.0
    var isReversed : Bool = false
    var directionForEndState : Direction = .undefined
    var direction = Direction.undefined
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
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
        
        startGame(calledInViewDidLoad: true)
        
        // ads

//        self.view.addSubview(rewardButton)
//        rewardedAd?.load(GADRequest()) { error in
//          if let error = error {
//            print("ad didnt load")
//          } else {
//            print("ad successfully loaded")
//          }
//        }

    }

    
    //MARK: Set-up game functions
    
    func drawGameboard(sizeAndPositionsDict:[String:CGFloat]){        
        let gameboardView = GameboardView(dimensions: dimensions, sizeAndPositionsDict: sizeAndPositionsDict)
        scoreView = ScoreView(sizeAndPositionsDict: sizeAndPositionsDict)
        
        restartButton = navButton(sizeAndPositionsDict: sizeAndPositionsDict, x: self.view.frame.size.width * 0.02, labelText: "RESET(\(adCounter))")
        restartButton.addTarget(self, action:#selector(restartButtonClicked), for: .touchUpInside)
        
        let menuButton = navButton(sizeAndPositionsDict: sizeAndPositionsDict, x: self.view.frame.size.width * 0.98 - sizeAndPositionsDict["gameboardWidth"]!*0.2, labelText: "STATS")
        menuButton.addTarget(self, action:#selector(menuButtonClicked), for: .touchUpInside)
        
        playTutorialButton = TutorialButton(sizeAndPositionsDict: sizeAndPositionsDict)
        playTutorialButton.addTarget(self, action: #selector(playTutorialButtonClicked), for: .touchUpInside)
        
        let tileTrackingStrip = TileTrackingStrip(sizeAndPositionsDict: sizeAndPositionsDict, superviewWidth: self.view.frame.width, smallTileScale: smallTileScale)
        
        self.view.addSubview(gameboardView)
        self.view.addSubview(scoreView)
        self.view.addSubview(restartButton)
        self.view.addSubview(menuButton)
        self.view.addSubview(playTutorialButton)
        self.view.addSubview(tileTrackingStrip)
    }
    
    func startGame(calledInViewDidLoad: Bool){
        rewardedAd = loadRewardedAd()
        
        /* Appearance, sizes, etc */
        let superviewWidth = self.view.frame.size.width
        let superviewHeight = self.view.frame.size.height
        sizeAndPositionsDict = calculateViewSizeAndPositions(dimensions: dimensions, superviewWidth: superviewWidth, superviewHeight: superviewHeight, spacing: tileSpacing)
        
        
        let smallTileHighlight = SmallTileHighlight(sizeAndPositionsDict: sizeAndPositionsDict, smallTileScale: smallTileScale)
        self.view.addSubview(smallTileHighlight)
        
        /* Ad counter */
        if let a = loadAdCounter() {
            print("adCounter was loaded")
            adCounter = a.adCounter["adCounter"]!
        } else {
            print("adCounter was not loaded so is set to 7")
            adCounter = 7
        }
        
        // increment ad tracker
        if !calledInViewDidLoad {
            adCounter -= 1
            adCounter = max(adCounter, 0)
            saveAdCounter()
        }
        
        /* Look for previous gameboards */
        // if there is a preivous gameboard saved, use that; if not start a new gameboard
        if let savedGameboard = loadTileValueList() {
            tileValueList = savedGameboard.tileValueList["tileValueList"]!
            freqTracking = savedGameboard.freqTracking
            nextTileValue = savedGameboard.tileValueList["nextTileValue"]![0]
            nextNextTileValue = savedGameboard.tileValueList["nextNextTileValue"]![0]
        } else {
            tileValueList = [0]
            freqTracking = [2: 0, 3: 0, 4: 0, 5: 0]
        }
        
        // if prevSavedBoard is not of length dxd it's the dummy generated by the code
        let prevSavedBoard : Bool = tileValueList.count == dimensions * dimensions ? true : false
        
        if prevSavedBoard == false { // if we are starting new board this is what we do
            freqTracking = [2: 0, 3: 0, 4: 0, 5: 0]
            nextTileValue = 7
            nextNextTileValue = 7
            (tileValueBoard, tileViewBoard) = addFirstTiles(dimensions: dimensions, sizeAndPositionsDict: sizeAndPositionsDict, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard)
        } else { // if there is a stored gameboard (game must have crashed) we restore what was saved
                        
            // make gameboard list into new tile value board
            // tileValueList = [7, 14, 28, 56, 112, 224, 448, 896, 1792, 3584, 7168, 0, 0, 0, 0, 0]
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
        
        drawGameboard(sizeAndPositionsDict: sizeAndPositionsDict)
        addSmallTile()
        
        /* Add first tiles */
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
        
        /* See if tutorial mode should be true */
        
        var totalGamesPlayed : Int
        if let savedScoreBoard = loadScores() {
            totalGamesPlayed = savedScoreBoard.runningStats["totalGamesPlayed"]!
        } else {
            totalGamesPlayed = 0
        }
        
        if (totalGamesPlayed == 0 && !prevSavedBoard) || manualTutorialRequest {
            tutorialActive = true
            playTutorialButton.isEnabled = false
        } else {
            tutorialActive = false
        }
        
        if tutorialActive {
            drawTutorialIntro()
        }
        
        print("adCounter at startgame is \(adCounter)")
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
    
    func addNextTileView(override: Bool, overrideValue: Int) -> TileView {
        // generate a tile view based on the value generate for the next time, this tile is currently hidden at (0,0)
        
        let nextTileView = TileView(sizeAndPositionsDict: sizeAndPositionsDict, tileValue: nextTileValue)
        
        // after creating the view generate the next-up tile value
        nextTileValue = nextNextTileValue
        
        if override {
            nextNextTileValue = overrideValue
        } else if tutorialActive == false {
            nextNextTileValue = generateRandTileValue(tileValueBoard: tileValueBoard, nextTileValue: nextTileValue, initialFreq: initialFreq, freqTracking: freqTracking)
        } else if tutorialActive == true {
            print("in addNextTileView: tutorial is active, and index is \(tutorialIndex)")
            nextNextTileValue = tutorialSequence[tutorialIndex]
        }
        
        
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
            
            // Update the storage of gameboard values so if app crashes we can go back
            self.tileValueList = self.turnTileValueBoardToList(tileValueBoard: self.tileValueBoard)
            self.saveTileValueList()
            
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
        
//        // Update the storage of gameboard values so if app crashes we can go back
//        tileValueList = turnTileValueBoardToList(tileValueBoard: tileValueBoard)
//        saveTileValueList()
        
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
                    transformScale = 1.1
                case 2..<numSmallTiles:
                    transformScale = 0.9
                default:
                    transformScale = 1
                }
                
                shrinkTrans = CGAffineTransform(scaleX: transformScale, y: transformScale)
                positionTrans = CGAffineTransform(translationX: xShift, y: yShift)
                
                
                animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
                    subview.transform = shrinkTrans.concatenating(positionTrans)
                })
                
                
                animator.startAnimation()
            }
        }
    }
    
    //MARK: Tutorial Functions
    func drawTutorialIntro() {
        tutorialBlock = TutorialBlock(sizeAndPositionsDict: sizeAndPositionsDict, labelText: tutorialIntroComments[0])
        tutorialBlock.closeButton.addTarget(self, action:#selector(closeTutorialButtonClicked), for: .touchUpInside)
        
        self.view.addSubview(self.tutorialBlock)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.tutorialBlock.label.text = self.tutorialIntroComments[1]
            self.tutorialBlock.label.font = UIFont(name: "TallBasic30-Regular", size: 30)!
        }
    }
    
    func tutorial34Merged(tileValueBoard: Gameboard<Int>, newTileValueBoard: Gameboard<Int>) -> Bool {
        var count3Old : Int = 0
        var count4Old : Int = 0
        var count3New : Int = 0
        var count4New : Int = 0
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                if tileValueBoard[i,j] == 3 {
                    count3Old += 1
                } else if tileValueBoard[i,j] == 4 {
                    count4Old += 1
                }
                
                if newTileValueBoard[i,j] == 3 {
                    count3New += 1
                } else if newTileValueBoard[i,j] == 4 {
                    count4New += 1
                }
            }
        }

        if count3Old > count3New || count4Old > count4New {
            return true
        }
        return false
    }
    
    func tutorialShouldNewTilesBePaused() {
        if let waitpoint = tutorialWaitpoints[tutorialIndex]{
            // if we are at a waitpoint index, and the waitpoint index has not yet been changed to true
            if waitpoint == false {
                tutorialPaused = true
            }
        }
    }
    
    func tutorialShouldNewTilesBeResumed(merged34: Bool) {
        switch tutorialIndex {
        case 0 where boardContains(dimensions: dimensions, tileValueBoard: tileValueBoard, value: 14):
            tutorialWaitpoints[tutorialIndex] = true
            tutorialPaused = false
            tutorialStuckCounter = 0
        case 2 where boardContains(dimensions: dimensions, tileValueBoard: tileValueBoard, value: 28):
            tutorialWaitpoints[tutorialIndex] = true
            tutorialPaused = false
            tutorialStuckCounter = 0
        case 8 where merged34:
            tutorialWaitpoints[tutorialIndex] = true
            tutorialPaused = false
            tutorialStuckCounter = 0
        default:
            tutorialStuckCounter += 1
        }
    }
    
    func tutorialGenerateNewTilesWhenStuck() -> TileView {
        var overrideValue = 7
        switch tutorialIndex {
        case 0, 2:
            overrideValue = 7
        case 8:
            if tutorialStuckCounter % 4 == 0 {
                overrideValue = 3
            } else if tutorialStuckCounter % 4 == 1{
                overrideValue = 4
            }
        default:
            ()
        }
        let nextTileView : TileView = addNextTileView(override: true, overrideValue: overrideValue)
        
        return nextTileView
    }
    
    
    
    //MARK: Game Center Functions
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if ((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
                
            } else if (localPlayer.isAuthenticated){
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifier, error) in
                    if error != nil {
                        print("inside the print error statement")
                        print(error as Any)
                    } else {
                        self.gcDefaultLeaderboard = leaderboardIdentifier!
                    }
                })
            } else {
                // 3. Game center is not enabled on the user's device
                self.gcEnabled = false
                print("Local player could not be authenticated")
                print(error as Any)
            }
        }
    }
    
    func submitHighScoreToGC() {
        // let highScore = scoreBoard.runningStats["highScore"]!
        // let lowScore = scoreBoard.runningStats["lowScore"]!
        let score = scoreView.score
        
        // submit score to GC Leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(score)
        GKScore.report([bestScoreInt]) {(error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("High Score is submitted to your Leaderboard")
            }
        }
        
        if score != 0 {
            let lowScoreInt = GKScore(leaderboardIdentifier: LOWSCORE_ID)
            lowScoreInt.value = Int64(score)
            GKScore.report([lowScoreInt]) {(error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("low score value is \(score)")
                    print("Low Score is submitted to your Leaderboard")
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
        
        
        // delete saved gameboard value
        // tileValueList = [0]
        // freqTracking = [2: 0, 3: 0, 4: 0, 5: 0]
        // saveTileValueList()
        
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
        
        
        // show SECRET popup if they get a super high score
        let highestTileValue = calculateHighestTileValue(tileValueBoard: tileValueBoard)
        
        var secret7168Achievement = false
        if (scoreBoard.tileCount[7168] == 0 &&
            scoreBoard.tileCount[14336] == 0 &&
            highestTileValue == 7168) { // if it's their first time getting the 7168 tile
            secret7168Achievement = true
        }
        
        var secret14336Achievement = false
        if (scoreBoard.tileCount[14336] == 0 && highestTileValue == 14336){ // if it's first time geeting the 14336 tile
            secret14336Achievement = true
        }
        
        guard !(secret7168Achievement && secret14336Achievement) else {
            fatalError("both 7168 an 14336 achievements are true")
        }
        
        if let s = scoreBoard.runningStats["lowScore"] {
            if scoreView.score < s || s != 0 {
                scoreBoard.runningStats["lowScore"] = scoreView.score
            }
        } else {
            scoreBoard.runningStats["lowScore"] = scoreView.score
        }
        
        
        // update highest tile value if the highest tile is equal or greater than 112
        
        if highestTileValue >= 112 {
            scoreBoard.tileCount[highestTileValue]! += 1
        }
        
        saveScores()
        authenticateLocalPlayer()
        submitHighScoreToGC()
        
        // create endGame view
        endGamePopupView = EndGamePopupView(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height,  adCounter: adCounter, newHighScore: newHighScore,  secret7168Achievement:  secret7168Achievement, secret14336Achievement:  secret14336Achievement)
        self.view.addSubview(endGamePopupView)
    
        // closeEndGameButton = CloseEndGameButton(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height)
        
        if adCounter == 0 {
            endGamePopupView.restartButton.addTarget(self, action: #selector(watchAd), for: .touchUpInside)
        } else {
            endGamePopupView.restartButton.addTarget(self, action: #selector(restartAtEnd), for: .touchUpInside)
        }
        endGamePopupView.closeEndGameButton.addTarget(self, action: #selector(closeEndGameButtonClicked), for: .touchUpInside)
        // closeEndGameButton.addTarget(self, action: #selector(closeEndGameButtonClicked), for: .touchUpInside)
        
        self.view.addSubview(endGamePopupView)
        self.view.addSubview(endGamePopupView.closeEndGameButton)
        
        // add confetti if it's a new high score
        if (newHighScore || secret7168Achievement || secret14336Achievement) {
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
                    cell.birthRate = 80
                    cell.contents = confettiType.image.cgImage
                    cell.emissionRange = CGFloat(Double.pi)
                    cell.lifetime = 5
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
                // confettiCells.cell.birthRate = 10
                confettiLayer.birthRate = 0
            }
        }
    }
    
    //MARK: Save and load functions
    
    private func saveScores() {
        let _ = NSKeyedArchiver.archiveRootObject(scoreBoard, toFile: ScoreBoard.ArchiveURL.path)
    }
    
    private func loadScores() -> ScoreBoard? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ScoreBoard.ArchiveURL.path) as? ScoreBoard
    }
    
    private func saveAdCounter() {
        let adCounterStorage = AdCounterStorage()
        adCounterStorage.adCounter = ["adCounter": adCounter]
        let _ = NSKeyedArchiver.archiveRootObject(adCounterStorage, toFile: AdCounterStorage.ArchiveURL.path)
    }
    
    private func loadAdCounter() -> AdCounterStorage? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: AdCounterStorage.ArchiveURL.path) as? AdCounterStorage
    }
    
    private func saveTileValueList() {
        let gameboardStorage = GameboardStorage()
        gameboardStorage.tileValueList = ["tileValueList":tileValueList, "nextTileValue": [nextTileValue], "nextNextTileValue": [nextNextTileValue]]
        gameboardStorage.freqTracking = freqTracking
        let _ = NSKeyedArchiver.archiveRootObject(gameboardStorage, toFile: GameboardStorage.ArchiveURL.path)
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
        panGestureRecognizer.isEnabled = true
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        tutorialActive = false
        tutorialWaitpoints = [0: false, 2: false, 8: false]
        tutorialIndex = 0
        tutorialStuckCounter = 0
        playTutorialButton.isEnabled = true
        
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
  
        // Properties used to keep track of gameboard hint
        tileTrackingList = [SmallTileView?]()
        nextTileValue = 7
        nextNextTileValue  = 7
        scoreView.score = 0
        
        // freqTracking = [2: 0, 3: 0, 4: 0, 5: 0]

        tileValueList = [0]
        saveTileValueList()
        
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
        startGame(calledInViewDidLoad: false)
    }
        
    //MARK: Click-related functions
    
    // ads
    
    @objc func watchAd() {
        print("watchAd is called")
        print("rewardedAd is ready is \(rewardedAd!.isReady)")
        if rewardedAd?.isReady == true {
            rewardedAd?.present(fromRootViewController: self, delegate:self)
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Reward is received")
        print("adCounter used to be \(adCounter)")
        adCounter += 7
        print("adCounter is now \(adCounter)")
        saveAdCounter()
        restartGame()
        
    }
    
    func loadRewardedAd() -> GADRewardedAd? {
        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
        rewardedAd?.load(GADRequest()) { error in
            if let error = error {
                print(error)
            } else {
                print("ad succesfully loaded!")
            }
        }
        return rewardedAd
    }
        
    @objc func restartAtEnd(sender: UIButton!) {
        // rewardedAd = loadRewardedAd()
        restartGame()
    }
    
    @objc func restartButtonClicked(){
        // rewardedAd = loadAd()
        if adCounter != 0 {
            restartGame()
        } else {
            // create a popup that asks someone to watch an ad!
            watchAd()
            // restartGame()
        }
        
    }
    
    @objc func closeEndGameButtonClicked(){
        endGamePopupView.removeFromSuperview()
        endGamePopupView.closeEndGameButton.removeFromSuperview()
        // closeEndGameButton.removeFromSuperview()
        panGestureRecognizer.isEnabled = false
    }
    
    @objc func menuButtonClicked(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuViewController") as!MenuViewController
        menuViewController.modalPresentationStyle = .fullScreen
        menuViewController.modalTransitionStyle = .flipHorizontal
        present(menuViewController, animated: true, completion: nil)
    }
    
    @objc func closeTutorialButtonClicked(){
        print("closeTutorialButtonClicked is called")
        UIView.animate(withDuration: 1.0, animations: {self.tutorialBlock.alpha = 0.0},
        completion: { (value: Bool) in self.tutorialBlock.removeFromSuperview() })
        tutorialActive = false
        manualTutorialRequest = false
        tutorialWaitpoints = [0: false, 2: false, 8: false]
        tutorialIndex = 0
        tutorialStuckCounter = 0
        playTutorialButton.isEnabled = true
        print(playTutorialButton.isEnabled)
    }
    
    @objc func playTutorialButtonClicked() {
        print("play Tutorial button is clicke")
        if scoreView.score > 14 { // if player is in game, make sure they're okay with deleting progress
            playTutorialButton.isEnabled = false
            playTutorialWarningView = TutorialWarningView(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height)
            playTutorialWarningView.yesDeleteButton.addTarget(self, action: #selector(confirmPlayTutorial), for: .touchUpInside)
            playTutorialWarningView.noKeepButton.addTarget(self, action: #selector(rejectPlayTutorial), for: .touchUpInside)
            
            self.view.addSubview(playTutorialWarningView)
            panGestureRecognizer.isEnabled = false
            
        } else {
            manualTutorialRequest = true
            restartGame()
        }
        
    }
    
    @objc func confirmPlayTutorial() {
        manualTutorialRequest = true
        panGestureRecognizer.isEnabled = true
        restartGame()
    }
    
    @objc func rejectPlayTutorial() {
        playTutorialWarningView.removeFromSuperview()
        panGestureRecognizer.isEnabled = true
        playTutorialButton.isEnabled = true
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
             if fractionComplete < 0.25 {
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
                
                // TUTORIAL insert: check old vs new board to see if any 3 and 4s have merged before updating tileValueBoard
                var merged34 = false
                if tutorialActive && tutorialIndex == 8 {
                    merged34 = tutorial34Merged(tileValueBoard: tileValueBoard, newTileValueBoard: newTileValueBoard)
                }
                
                tileValueBoard = newTileValueBoard
                tileViewBoard = newTileViewBoard
                viewsToBeDeleted = newViewsToBeDeleted
                rowIndexPositionBoard = newRowIndexPositionBoard
                colIndexPositionBoard = newColIndexPositionBoard
                
                for i in 0..<dimensions {
                    for j in 0..<dimensions {
                        if let tileView = tileViewBoard[i,j]{
                            tileView.value = tileValueBoard[i,j]
                        }
                    }
                }
                
                // if gameboard didn't change it means we swiped in an un-viable way so a new tile shouldn't be added
                // if gameboard did change we'll need to add a new tile, and do more complicated things if we're in tutorial
                if gameboardChanged != 0 {
                    /* TUTORIAL */
                    //pause and unpause new tiles in tutorial when applicable (tutorialPaused=true/false)
                    if tutorialActive {
                        tutorialShouldNewTilesBePaused()
                        print("tutorialIndex is \(tutorialIndex)")
                    }
                    if tutorialActive && tutorialPaused {
                        print("tutorial is active and paused!")
                        tutorialShouldNewTilesBeResumed(merged34: merged34)
                    } // also increments stuckCounter if not unpaused
                    
                    // add new tiles that are of helpful values if stuck counter is too high
                    if tutorialActive && tutorialPaused && tutorialStuckCounter > 4 {
                        let nextTileView = tutorialGenerateNewTilesWhenStuck()
                        addNextTileOntoBoard(direction: directionForEndState, nextTileView: nextTileView)
                    }
                    
                    // End tutorial when tutorial is over
                    if tutorialActive && tutorialIndex >= tutorialSequence.count-1 {
                        closeTutorialButtonClicked()
                    }
                    
                    // Add new tiles both when tutorial is not paused and when not in tutorial
                    if (tutorialActive && !tutorialPaused) || !tutorialActive {
                        tutorialIndex += 1
                        let nextTileView : TileView = addNextTileView(override: false, overrideValue: 0)
                        addNextTileOntoBoard(direction: directionForEndState, nextTileView: nextTileView)
                    }
                
                    if tutorialActive {
                        if let labelText = tutorialComments[tutorialIndex-1] {
                            tutorialBlock.label.text = labelText
                        }
                    }
                }
                
                /* Scores Calculation */
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
                numberCalls += 1

                
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



