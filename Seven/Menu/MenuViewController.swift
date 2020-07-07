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
        self.view.backgroundColor = UIColor.init(red: 164/255, green: 215/255, blue: 228/255, alpha: 1)
        
        // Load saved scores, if none, everything should be zero
        if let savedScoreBoard = loadScores() {
            scoreBoard = savedScoreBoard
        }
        
        // Create Menu high score view
        drawMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        
        if let savedScoreBoard = loadScores() {
            scoreBoard = savedScoreBoard
        }
        drawMenu()
    }
    
    func drawMenu() {
        let w = self.view.frame.width
        let h = self.view.frame.height
        let highScoreViewWidth = w * 0.7
        let topGapPct : CGFloat = 0.1
        let highScoreViewPct : CGFloat = 0.2
        let secondGapPct : CGFloat = 0.02
        let tileCountViewPct : CGFloat = 0.6
        let thirdGapPct : CGFloat = 0.02
        let bottomGapPct : CGFloat = 0.02
        let footerPct : CGFloat = 1 - (topGapPct + highScoreViewPct + secondGapPct + tileCountViewPct + thirdGapPct + bottomGapPct)
        
        guard footerPct > 0 else {
            fatalError("footer pct is negative")
        }
        
        let backButtonWidth = w*0.1
        let backButtonHeight = backButtonWidth * (850/1000)
        let backButton = UIButton(frame: CGRect(x: 10, y: (h * topGapPct - backButtonHeight)/2, width: backButtonWidth, height: backButtonHeight))
        backButton.setImage(UIImage(named:"backButton"), for: [])
//        backButton.setTitle("Back", for: [])
//        backButton.titleLabel?.font = UIFont(name: "TallBasic30-Regular", size: 20)!
//        backButton.titleLabel?.textColor = UIColor.white
        backButton.addTarget(self, action:#selector(backButtonClicked), for: .touchUpInside)
        
        let menuHighScoreView = MenuHighScoreView(x: (w - highScoreViewWidth)/2, y: h * topGapPct, width: highScoreViewWidth, height: h * highScoreViewPct, highScore: scoreBoard.runningStats["highScore"]!, totalGamesPlayed: scoreBoard.runningStats["totalGamesPlayed"]!)
        let menuTileCountView = MenuTileCountView(x: 0, y: h * (topGapPct + highScoreViewPct + secondGapPct), width: w, height: h*tileCountViewPct, tileCountDict: scoreBoard.tileCount)
        let menuFooterView = MenuFooterView(x: 0, y: h * (topGapPct + highScoreViewPct + secondGapPct + tileCountViewPct + thirdGapPct), width: w, height: h*footerPct)
        
        menuFooterView.clearHistoryButton.addTarget(self, action:#selector(clearHistoryButtonClicked), for: .touchUpInside)
        menuFooterView.contactUsButton.addTarget(self, action:#selector(contactUsButtonClicked), for: .touchUpInside)
        self.view.addSubview(backButton)
        self.view.addSubview(menuHighScoreView)
        self.view.addSubview(menuTileCountView)
        self.view.addSubview(menuFooterView)
        
    }
    
    @objc func backButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func clearHistoryButtonClicked() {
        let clearHistoryViewController = ClearHistoryViewController()
        clearHistoryViewController.modalPresentationStyle = .fullScreen
        present(clearHistoryViewController, animated: false, completion: nil)
    }
    
    @objc func contactUsButtonClicked(){
        let contactViewController = ContactViewController()
        contactViewController.modalPresentationStyle = .overFullScreen
        present(contactViewController, animated: false, completion: nil)

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
