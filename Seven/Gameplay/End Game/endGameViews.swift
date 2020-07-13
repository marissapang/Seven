//
//  endGameViews.swift
//  Seven
//
//  Created by apple on 7/9/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class EndGamePopupView : UIView {
    var restartButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    init(superviewWidth: CGFloat, superviewHeight: CGFloat, newHighScore: Bool){
        
        let popupWidth = superviewWidth * 0.95
        let popupHeight = superviewHeight * 0.4
        let labelWidth = superviewWidth * 0.85
        let labelHeight = superviewWidth * 0.3

        let popupX = (superviewWidth - popupWidth)/2
        let popupY = (superviewHeight - popupHeight)/2
        let labelX = (superviewWidth - labelWidth)/2
        let labelY = (superviewHeight - popupHeight)/2 + superviewHeight*0.05
        
        let restartButtonWidth = labelWidth * 0.8
        let restartButtonHeight = labelHeight * 0.7
        let restartButtonX = labelX + (labelWidth - restartButtonWidth)/2
        let restartButtonY = labelY + labelHeight + superviewHeight*0.05

        
        // first create a white translucent mask across the entire screen
        super.init(frame: CGRect(x: 0, y: 0, width: superviewWidth, height: superviewHeight))
        backgroundColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        
        
        let popupView = UIView(frame: CGRect(x: popupX, y: popupY, width: popupWidth, height: popupHeight))
        let popupLabel = UILabel(frame: CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight))
        popupView.backgroundColor = UIColor.init(red: 20.0/255.0, green: 165.0/255.0, blue: 213.0/255.0, alpha: 0.95)
        popupView.backgroundColor = UIColor.init(red: 195.0/255.0, green: 230.0/255.0, blue: 240.0/255.0, alpha: 1)
        popupView.layer.shadowColor = UIColor.gray.cgColor
        popupView.layer.shadowRadius = 3
        popupView.layer.shadowOpacity = 1
        popupView.layer.cornerRadius = 15
        
        if newHighScore == true {
            popupLabel.text = "🎉🎉🎉 Nice! You just got a new high score! 🎉🎉🎉"
        } else {
            popupLabel.text = "Nooo - you're out of moves :'( "

        }
        
        
        popupLabel.textAlignment = .center
        popupLabel.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        popupLabel.font = UIFont(name: "TallBasic30-Regular", size: 32)!
        popupLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        popupLabel.numberOfLines = 0
        
        restartButton = UIButton(frame: CGRect(x: restartButtonX, y: restartButtonY, width: restartButtonWidth, height: restartButtonHeight))
        
        restartButton.backgroundColor = UIColor.init(red: 253.0/255.0, green: 138.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        restartButton.backgroundColor = UIColor.init(red: 250.0/255.0, green: 174.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        restartButton.setTitle("Play Again!", for: [])
        restartButton.titleLabel?.font = UIFont(name: "TallBasic30-Regular", size: 32)!
        restartButton.titleLabel?.textColor = UIColor.white
        restartButton.layer.cornerRadius = 15
        
         
        addSubview(popupView)
        addSubview(popupLabel)
        addSubview(restartButton)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
}

class RestartButton : UIButton {
    init(superviewWidth: CGFloat, superviewHeight: CGFloat){
        // copy paste from endGamePopup view, helps with calculation
        let popupHeight = superviewHeight * 0.4
        let labelWidth = superviewWidth * 0.85
        let labelHeight = superviewWidth * 0.3
        let labelX = (superviewWidth - labelWidth)/2
        let labelY = (superviewHeight - popupHeight)/2 + superviewHeight*0.05

        
        let restartButtonWidth = labelWidth * 0.8
        let restartButtonHeight = labelHeight * 0.7
        let restartButtonX = labelX + (labelWidth - restartButtonWidth)/2
        let restartButtonY = labelY + labelHeight + superviewHeight*0.05
                
        super.init(frame: CGRect(x: restartButtonX, y: restartButtonY, width: restartButtonWidth, height: restartButtonHeight))
        
        backgroundColor = UIColor.init(red: 253.0/255.0, green: 138.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        
        setTitle("Play Again!", for: [])
        titleLabel?.font = UIFont(name: "TallBasic30-Regular", size: 32)!
        titleLabel?.textColor = UIColor.white
        layer.cornerRadius = 15
    }

    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class CloseEndGameButton : UIButton {
    init(superviewWidth: CGFloat, superviewHeight: CGFloat){
        // copy paste from endGamePopup view, helps with calculation
        let popupWidth = superviewWidth * 0.95
        let popupHeight = superviewHeight * 0.4
        let popupX = (superviewWidth - popupWidth)/2
        let popupY = (superviewHeight - popupHeight)/2
        
        let closeButtonWidth = popupWidth * 0.1
        let closeButtonHeight = closeButtonWidth
        let closeButtonX = popupWidth+popupX - closeButtonWidth*0.8
        let closeButtonY = popupY - closeButtonWidth*0.15
        
        super.init(frame: CGRect(x: closeButtonX, y: closeButtonY, width: closeButtonWidth, height: closeButtonHeight))
        
        setImage(UIImage(named:"closeButton"), for: [])
    }

    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}
