//
//  ClearHistoryViewController.swift
//  Seven
//
//  Created by apple on 7/2/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit
import os.log

class ClearHistoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: 164/255, green: 215/255, blue: 228/255, alpha: 1)
        
        let backgroundCloseButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        backgroundCloseButton.addTarget(self, action: #selector(noKeepButtonClicked), for: .touchUpInside)
        
        let warning = ClearHistoryPopupView(superviewWidth: self.view.frame.width, superviewHeight: self.view.frame.height)
        
        warning.noKeepButton.addTarget(self, action:#selector(noKeepButtonClicked), for: .touchUpInside)
        warning.yesDeleteButton.addTarget(self, action:#selector(yesDeleteButtonClicked), for: .touchUpInside)
        
        self.view.addSubview(backgroundCloseButton)
        self.view.addSubview(warning)
    }
    
    @objc func noKeepButtonClicked(){
        dismiss(animated: false, completion: nil)
        
        
    }
    
    
    @objc func yesDeleteButtonClicked(){
        let emptyScoreBoard = ScoreBoard()
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(emptyScoreBoard, toFile: ScoreBoard.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Scoreboard successfully cleared.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to clear scoreboard D:", log: OSLog.default, type: .error)
        }
        dismiss(animated: false, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
