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
    
    //MARK: Modified properties
    var tileValueBoard : Gameboard<Int>
    var tileMovementBoard : Gameboard<Movement>
    var tileViewBoard : Gameboard<TileView?>
    var tileAnimationBoard : Gameboard<UIViewPropertyAnimator>
    var rowIndexPositionBoard : Gameboard<Int>
    var colIndexPositionBoard : Gameboard<Int>
    
    
    var direction = Direction.undefined
    
    //MARK: Placeholder swipes
    
    @IBAction func swipeUp(_ sender: Any) {
        print("swipeUp button clicked")
        direction = .up
        
        tileAnimationBoard = moveAllTiles(dimensions: dimensions, tileViewBoard: tileViewBoard, tileAnimationBoard: tileAnimationBoard)
        
        // test code for animating everyhing on the board
        var animator : UIViewPropertyAnimator
        var view : TileView?
        
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                animator = tileAnimationBoard[i,j]
                animator.startAnimation()
            }
        }
        

        // test code to see if i can animte before showing the subview
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            for i in 0..<self.dimensions {
                for j in 0..<self.dimensions {
                    view = self.tileViewBoard[i,j]
                    
                    if let v = view {
                        self.view.addSubview(v)
                    }
                }
            }

        }
                
        // test to see if i can remove a view from a super view from list
        /* var count : Int = 0
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                if let subview = tileViewBoard[i,j] { //if subview is not nil
                    count = count+1
                    print(count)
                    if count > 1 {
                        subview.removeFromSuperview()
                    }
                }
            }
        } */
    }
    @IBAction func swipeDown(_ sender: Any) {
        print("swipeDown button clicked")
        direction = .down
    }
    @IBAction func swipeLeft(_ sender: Any) {
        print("swipeLeft button clicked")
        direction = .left
    }
    @IBAction func swipeRight(_ sender: Any) {
        print("swipeRight button clicked")
        direction = .right
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
    
    func drawGameboard(){
        let superviewWidth = self.view.frame.size.width
        let superviewHeight = self.view.frame.size.height
        let sizeAndPositionsDict = calculateViewSizeAndPositions(dimensions: dimensions, superviewWidth: superviewWidth, superviewHeight: superviewHeight, spacing: tileSpacing)
        
        print(sizeAndPositionsDict)
        let gameboardView = GameboardView(dimensions: dimensions, sizeAndPositionsDict: sizeAndPositionsDict)
        self.view.addSubview(gameboardView)
        
        
    }
    func startGame(){
        drawGameboard()
        (tileValueBoard, tileViewBoard) = addFirstTiles(dimensions: dimensions, tileValueBoard: tileValueBoard, tileViewBoard: tileViewBoard)
        
        for i in 0..<dimensions {
            for j in 0..<dimensions {
                if let subview = tileViewBoard[i,j] { //if subview is not nil
                    //self.view.addSubview(subview)
                }
            }
        }
    }


}

