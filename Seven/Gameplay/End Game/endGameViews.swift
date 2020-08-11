//
//  endGameViews.swift
//  Seven
//
//  Created by apple on 7/9/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class EndGamePopupView : UIView {
    let translator = Translator()
    var language = "en"
    var restartButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var closeEndGameButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var socialMediaView = SocialMediaView(x: 0, y: 0, width: 10, height: 10)
    
    init(superviewWidth: CGFloat, superviewHeight: CGFloat, adCounter: Int, newHighScore: Bool, secret7168Achievement: Bool, secret14336Achievement: Bool){
        
        language = NSLocale.current.languageCode ?? "en"
        
        let popupWidth = superviewWidth * 0.95
        var popupHeight = superviewHeight * 0.4
        let labelWidth = superviewWidth * 0.85
        let labelHeight = superviewHeight * 0.2

        let popupX = (superviewWidth - popupWidth)/2
        var popupY = (superviewHeight - popupHeight)/2
        let labelX = (superviewWidth - labelWidth)/2
        var labelY = (superviewHeight - popupHeight)/2 // + superviewHeight*0.05
        
        let restartButtonWidth = labelWidth * 0.8
        let restartButtonHeight = labelHeight * 0.7
        let restartButtonX = labelX + (labelWidth - restartButtonWidth)/2
        let restartButtonY = labelY + labelHeight + labelHeight * 0.2 //superviewHeight*0.05

        
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
            popupLabel.text = translator.translateNewHighScoreEndGame(language)
        } else {
            popupLabel.text = translator.translateOutOfMoves(language)

        }
    
        popupLabel.textAlignment = .center
        popupLabel.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        popupLabel.font = UIFont(name: translator.getLanguageFont(language), size: 32)!
        popupLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        popupLabel.numberOfLines = 0
        
        restartButton = UIButton(frame: CGRect(x: restartButtonX, y: restartButtonY, width: restartButtonWidth, height: restartButtonHeight))

        restartButton.backgroundColor = UIColor.init(red: 250.0/255.0, green: 174.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        restartButton.titleLabel?.textAlignment = .center
        
        if adCounter == 0 {
            restartButton.setTitle(translator.translateWatchAnAd(language), for: [])
            restartButton.titleLabel?.numberOfLines = 3
            restartButton.titleLabel?.adjustsFontSizeToFitWidth = true
            restartButton.titleLabel?.lineBreakMode = .byTruncatingTail
            restartButton.titleEdgeInsets = UIEdgeInsets(top: 1,left: 3,bottom: 1,right: 3)
        } else {
            restartButton.setTitle(translator.translatePlayAgain(language, value: adCounter), for: [])
        }
        restartButton.titleLabel?.font = UIFont(name: translator.getLanguageFont(language), size: 32)!
        
        restartButton.titleLabel?.textColor = UIColor.white
        restartButton.layer.cornerRadius = 15
        
        
        let closeButtonWidth = popupWidth * 0.1
        let closeButtonHeight = closeButtonWidth
        var closeButtonX = popupWidth+popupX - closeButtonWidth*0.8
        var closeButtonY = popupY - closeButtonWidth*0.15
        closeEndGameButton = UIButton(frame: CGRect(x: closeButtonX, y: closeButtonY, width: closeButtonWidth, height: closeButtonHeight))
        closeEndGameButton.setImage(UIImage(named:"closeButton"), for: [])
        
         
        if secret7168Achievement || secret14336Achievement {
            // set up popupView to a larger view for the celebrations
            popupHeight = superviewHeight * 0.75
            popupY = (superviewHeight - popupHeight)/2
            labelY = (superviewHeight - popupHeight)/2 + superviewHeight*0.05
            popupView.frame = CGRect(x: popupX, y: popupY, width: popupWidth, height: popupHeight)
            popupView.backgroundColor = UIColor.init(red: 33.0/255.0, green: 31.0/255.0, blue: 38.0/255.0, alpha: 1)
            popupLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
            
            let topGapPct : CGFloat = 0.08
            let label1Pct : CGFloat = 0.18
            let gap2Pct : CGFloat = 0.05
            let label2Pct : CGFloat = 0.22
            let label3Pct : CGFloat = 0.12
            let socialMediaPct : CGFloat = 0.18
            let label4Pct : CGFloat = 1 - (topGapPct + gap2Pct + label1Pct + label2Pct + label3Pct + socialMediaPct)
            
            guard label4Pct > 0 else {
                fatalError("in endGame secret view, label4Pct is neagtive")
            }
            
            popupLabel.frame = CGRect(x: labelX, y: popupView.frame.minY + topGapPct*popupHeight, width: labelWidth, height: label1Pct * popupHeight)
            let popupLabel2 = UILabel(frame: CGRect(x: labelX, y: popupLabel.frame.maxY, width: labelWidth, height: label2Pct * popupHeight))
            let popupLabel3 = UILabel(frame: CGRect(x: labelX, y: popupLabel2.frame.maxY + gap2Pct*popupHeight, width: labelWidth, height: label3Pct * popupHeight))
            let socialMediaView = SocialMediaView(x: labelX, y: popupLabel3.frame.maxY, width: labelWidth, height: socialMediaPct * popupHeight)
            let popupLabel4 =  UILabel(frame: CGRect(x: labelX, y: socialMediaView.frame.maxY, width: labelWidth, height: label4Pct * popupHeight))
            
            // change popup appearance
            
            // add view for sharing on instagram
            if secret14336Achievement {
                popupLabel.text = "14336."
                popupLabel2.text = "Officially the highest tile anyone's ever achieved. Amazing!"
                popupLabel3.text = "Take a screenshot & tag us on social media to get a 14336-tile souvenir mailed to you!"
                popupLabel4.text = "CONGRATS ON BEATING THE GAME"
            } else if secret7168Achievement {
                 // write 7168 caption
                popupLabel.text = "7168."
                popupLabel2.text = "Congrats! You've reached the 7168 tile - a feat so few achieves it's not even on our stats page!"
                popupLabel3.text = "Take a screenshot & tag us on social media to get a 7168-tile souvenir mailed to you!"
                popupLabel4.text = "WELCOME TO THE 7K CLUB."
            }
            
            popupLabel.textAlignment = .left
            popupLabel.textColor = UIColor.white
            popupLabel.font = UIFont(name: "TallBasic30-Regular", size: 100)!
            popupLabel.adjustsFontSizeToFitWidth = true
           
            popupLabel2.textAlignment = .left
            popupLabel2.textColor = UIColor.white
            popupLabel2.font = UIFont(name: "TallBasic30-Regular", size: 35)!
            popupLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
            popupLabel2.adjustsFontSizeToFitWidth = true
            popupLabel2.numberOfLines = 0
           
            popupLabel3.textAlignment = .left
            popupLabel3.textColor = UIColor.white
            popupLabel3.font = UIFont(name: "TallBasic30-Regular", size: 22)!
            popupLabel3.lineBreakMode = NSLineBreakMode.byTruncatingTail
            popupLabel3.adjustsFontSizeToFitWidth = true
            popupLabel3.numberOfLines = 0
           
            popupLabel4.textAlignment = .center
            popupLabel4.textColor = UIColor.white
            popupLabel4.font = UIFont(name: "TallBasic30-Regular", size: 35)!
            popupLabel4.adjustsFontSizeToFitWidth = true
            
            closeEndGameButton.setImage(UIImage(named:"whiteCloseButton"), for: [])
            closeButtonX = popupWidth+popupX - closeButtonWidth*1.2
            closeButtonY = popupY + closeButtonWidth*0.2
            closeEndGameButton.frame = CGRect(x: closeButtonX, y: closeButtonY, width: closeButtonWidth, height: closeButtonHeight)
                
            addSubview(popupView)
            addSubview(popupLabel)
            addSubview(popupLabel2)
            addSubview(popupLabel3)
            addSubview(socialMediaView)
            addSubview(popupLabel4)
            addSubview(closeEndGameButton)
        } else { // if no secret view
            addSubview(popupView)
            addSubview(popupLabel)
            addSubview(restartButton)
            addSubview(closeEndGameButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
}

class SocialMediaView : UIView {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        
        let logoHeight = height*0.45
        let logoWidth = logoHeight*(1600/600)
        let logoX = (width-logoWidth)/2
        let logoY : CGFloat = 0
        let logoView = UIImageView(image: UIImage(named: "socialMediaLogos"))
        logoView.frame = CGRect(x: logoX, y: logoY, width: logoWidth, height: logoHeight)
        
        let handleHeight = height * 0.5
        let handleWidth = handleHeight * 3.2
        let handleX = (width-handleWidth)/2
        let handleY = logoView.frame.maxY
        let handleView = UIView(frame: CGRect(x: handleX, y: handleY + height*0.03, width: handleWidth, height: handleHeight))
        handleView.backgroundColor = UIColor.white
        handleView.layer.cornerRadius = 8
        handleView.layer.shadowRadius = 2
        handleView.layer.shadowColor = UIColor.gray.cgColor
        
        let labelWidth = handleWidth*0.9
        let labelX = handleX + (handleWidth - labelWidth)/2
        let handleLabel = UILabel(frame: CGRect(x: labelX, y: handleY, width: labelWidth, height: handleHeight))
        handleLabel.text = "@SevenGame3584"
        handleLabel.textColor = UIColor.init(red: 33.0/255.0, green: 31.0/255.0, blue: 38.0/255.0, alpha: 1)
        handleLabel.font = UIFont(name: "TallBasic30-Regular", size: 36)!
        handleLabel.adjustsFontSizeToFitWidth = true
        
        addSubview(logoView)
        addSubview(handleView)
        addSubview(handleLabel)
//        let elementWidth = width*0.45
//        let elementHeight = elementWidth*(450/1600)
//
//        let element1 = UIImageView(image: UIImage(named: "instagramHandle"))
//        element1.frame = CGRect(x: (width - 2*elementWidth)/3, y: (height - 2*elementHeight)/3, width: elementWidth, height: elementHeight)
//        let element1Label = UILabel(frame: CGRect(x: element1.frame.minX + elementWidth*(450/1600) + 5, y: element1.frame.minY + 2, width: elementWidth*(1-450/1600)-10, height: elementHeight))
//        element1Label.textAlignment = .left
//        element1Label.text = "SevenGame3584"
//        element1Label.textColor = UIColor.init(red: 33.0/255.0, green: 31.0/255.0, blue: 38.0/255.0, alpha: 1)
//        element1Label.font = UIFont(name: "TallBasic30-Regular", size: 24)!
//        element1Label.adjustsFontSizeToFitWidth = true
//
//        let element2 = UIImageView(image: UIImage(named: "twitterHandle"))
//        element2.frame = CGRect(x: element1.frame.maxX + (width - 2*elementWidth)/3, y: (height - 2*elementHeight)/3, width: elementWidth, height: elementHeight)
//        let element2Label = UILabel(frame: CGRect(x: element2.frame.minX + elementWidth*(450/1600) + 5, y: element2.frame.minY + 2, width: elementWidth*(1-450/1600)-10, height: elementHeight))
//        element2Label.textAlignment = .left
//        element2Label.text = "@SevenGame3584"
//        element2Label.textColor = UIColor.init(red: 33.0/255.0, green: 31.0/255.0, blue: 38.0/255.0, alpha: 1)
//        element2Label.font = UIFont(name: "TallBasic30-Regular", size: 24)!
//        element2Label.adjustsFontSizeToFitWidth = true
//
//        let element3 = UIImageView(image: UIImage(named: "facebookHandle"))
//        element3.frame = CGRect(x: (width - elementWidth)/2, y: element1.frame.maxY + (width - 2*elementWidth)/3, width: elementWidth, height: elementHeight)
//        let element3Label = UILabel(frame: CGRect(x: element3.frame.minX + elementWidth*(450/1600) + 5, y: element3.frame.minY + 2, width: elementWidth*(1-450/1600)-10, height: elementHeight))
//        element3Label.textAlignment = .left
//        element3Label.text = "SevenGame3584"
//        element3Label.textColor = UIColor.init(red: 33.0/255.0, green: 31.0/255.0, blue: 38.0/255.0, alpha: 1)
//        element3Label.font = UIFont(name: "TallBasic30-Regular", size: 24)!
//        element3Label.adjustsFontSizeToFitWidth = true
//
//        addSubview(element1)
//        addSubview(element2)
//        addSubview(element3)
//        addSubview(element1Label)
//        addSubview(element2Label)
//        addSubview(element3Label)
        
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}
