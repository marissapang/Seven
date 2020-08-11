//
//  MenuViewController.swift
//  Seven
//
//  Created by apple on 6/27/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit
import os.log
import GameKit

class MenuViewController: UIViewController, GKGameCenterControllerDelegate {
    
    //MARK: Properties
    var scoreBoard = ScoreBoard()
    var gcEnabled = Bool()
    var gcDefaultLeaderboard = String ()
    let LEADERBOARD_ID = "highScoreLeaderboard"
    let LOWSCORE_ID = "lowScoreLeaderboard"
    let translator = Translator()
    var language : String = "en"
    

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 164/255, green: 215/255, blue: 228/255, alpha: 1)
        language = NSLocale.current.languageCode ?? "en"
        // Load saved scores, if none, everything should be zero
        if let savedScoreBoard = loadScores() {
            scoreBoard = savedScoreBoard
        }
        
        authenticateLocalPlayer()
        // submitHighScoreToGC()
        
        // Create Menu high score view
        drawMenu()
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
        let highScore = scoreBoard.runningStats["highScore"]!
        let lowScore = scoreBoard.runningStats["lowScore"]!

        
        // submit score to GC Leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(highScore)
        GKScore.report([bestScoreInt]) {(error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("High Score is submitted to your Leaderboard")
            }
        }
        
        if lowScore != 0 {
            let lowScoreInt = GKScore(leaderboardIdentifier: LOWSCORE_ID)
            lowScoreInt.value = Int64(lowScore)
            GKScore.report([lowScoreInt]) {(error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("low score value is \(lowScore)")
                    print("Low Score is submitted to your Leaderboard")
                }
            }
        }
    }
    
    @objc func checkGCLeaderboard(){
        authenticateLocalPlayer()
        
//        if true == true { // if the player has not previously logged into GC and has no record yet
//            submitHighScoreToGC()
//        }
        
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
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
        let topGapPct : CGFloat = 0.13
        let highScoreViewPct : CGFloat = 0.19
        let secondGapPct : CGFloat = 0.02
        let tileCountViewPct : CGFloat = 0.57
        let thirdGapPct : CGFloat = 0.02
        let bottomGapPct : CGFloat = 0.02
        let footerPct : CGFloat = 1 - (topGapPct + highScoreViewPct + secondGapPct + tileCountViewPct + thirdGapPct + bottomGapPct)
        
        guard footerPct > 0 else {
            fatalError("footer pct is negative")
        }
        
        let backButtonWidth = w*0.08
        let backButtonHeight = backButtonWidth
        let backButton = UIButton(frame: CGRect(x: 10, y: (h * topGapPct * 0.8) - backButtonHeight, width: backButtonWidth, height: backButtonHeight))
        backButton.setImage(UIImage(named:"backButton"), for: [])
        backButton.addTarget(self, action:#selector(backButtonClicked), for: .touchUpInside)
        
        let gcButtonHeight = backButtonHeight
        let gcButtonWidth = gcButtonHeight * 3
        
        let gcButton = UIButton(frame: CGRect(x: self.view.frame.width - 10 - gcButtonWidth, y: backButton.frame.minY, width: gcButtonWidth, height: gcButtonHeight))
        gcButton.backgroundColor = UIColor.init(red: 10.0/255.0, green: 86.0/255.0, blue: 111.0/255.0, alpha: 1)
        gcButton.setTitle(translator.translateLeaderboard(language), for: [])
        gcButton.titleEdgeInsets = UIEdgeInsets(top: translator.getLanguageTextPaddingTop(language), left:5, bottom: 0, right: 5)
        gcButton.titleLabel?.font = UIFont(name: translator.getLanguageFont(language), size: translator.translateLeaderboardFont(language))!
        gcButton.titleLabel?.adjustsFontSizeToFitWidth = true
        gcButton.titleLabel?.textColor = UIColor.white
        gcButton.layer.cornerRadius = 5
        gcButton.layer.shadowColor = UIColor.white.cgColor
        gcButton.layer.shadowOpacity = 1
        gcButton.layer.shadowOffset = .zero
        gcButton.layer.shadowRadius = 5
        
        gcButton.addTarget(self, action:#selector(checkGCLeaderboard), for: .touchUpInside)
        
        let menuHighScoreView = MenuHighScoreView(x: (w - highScoreViewWidth)/2, y: h * topGapPct, width: highScoreViewWidth, height: h * highScoreViewPct, highScore: scoreBoard.runningStats["highScore"]!, totalGamesPlayed: scoreBoard.runningStats["totalGamesPlayed"]!)
        let menuTileCountView = MenuTileCountView(x: 0, y: h * (topGapPct + highScoreViewPct + secondGapPct), width: w, height: h*tileCountViewPct, tileCountDict: scoreBoard.tileCount)
        let menuFooterView = MenuFooterView(x: 0, y: h * (topGapPct + highScoreViewPct + secondGapPct + tileCountViewPct + thirdGapPct), width: w, height: h*footerPct)
        
        menuFooterView.clearHistoryButton.addTarget(self, action:#selector(clearHistoryButtonClicked), for: .touchUpInside)
        menuFooterView.contactUsButton.addTarget(self, action:#selector(contactUsButtonClicked), for: .touchUpInside)
        self.view.addSubview(backButton)
        self.view.addSubview(gcButton)
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
