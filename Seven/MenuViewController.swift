//
//  MenuViewController.swift
//  Seven
//
//  Created by apple on 6/27/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit
import os.log

class MenuViewController: UIViewController {
    
    //MARK: Properties
    var scoreBoard = ScoreBoard()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(scoreBoard.tileCount)

        self.view.backgroundColor = UIColor.init(red: 164/255, green: 215/255, blue: 228/255, alpha: 1)
        
        // Load saved scores, if none, everything should be zero
        if let savedScoreBoard = loadScores() {
            scoreBoard = savedScoreBoard
        }
        
        // Create Menu high score view
        drawMenu()
    }
    
    func drawMenu() {
        let w = self.view.frame.width
        let h = self.view.frame.height
        let topGapPct : CGFloat = 0.05
        let highScoreViewPct : CGFloat = 0.2
        let secondGapPct : CGFloat = 0.0
        let tileCountViewPct : CGFloat = 0.65
        let thirdGapPct : CGFloat = 0.02
        let bottomGapPct : CGFloat = 0.02
        let footerPct : CGFloat = 1 - (topGapPct + highScoreViewPct + secondGapPct + tileCountViewPct + thirdGapPct + bottomGapPct)
        
        guard footerPct > 0 else {
            fatalError("footer pct is negative")
        }
        
        let menuHighScoreView = MenuHighScoreView(x: 0, y: h * topGapPct, width: w, height: h * highScoreViewPct, highScore: scoreBoard.highScore)
        let menuTileCountView = MenuTileCountView(x: 0, y: h * (topGapPct + highScoreViewPct + secondGapPct), width: w, height: h*tileCountViewPct, tileCountDict: scoreBoard.tileCount)
        let menuFooterView = MenuFooterView(x: 0, y: h * (topGapPct + highScoreViewPct + secondGapPct + tileCountViewPct + thirdGapPct), width: w, height: h*footerPct)
        
        
        self.view.addSubview(menuHighScoreView)
        self.view.addSubview(menuTileCountView)
        self.view.addSubview(menuFooterView)
    }
    
    
    private func clearScores() {
        scoreBoard = ScoreBoard()
        let isSuccessfulClear = NSKeyedArchiver.archiveRootObject(scoreBoard, toFile: ScoreBoard.ArchiveURL.path)
        if isSuccessfulClear {
            os_log("Scoreboard successfully ucleared.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to clear scoreboard D:", log: OSLog.default, type: .error)
        }
    }

    private func saveScores() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scoreBoard, toFile: ScoreBoard.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Scoreboard successfully updated.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to update scoreboard D:", log: OSLog.default, type: .error)
        }
    }
    
    private func loadScores() -> ScoreBoard? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ScoreBoard.ArchiveURL.path) as? ScoreBoard
    }

}
