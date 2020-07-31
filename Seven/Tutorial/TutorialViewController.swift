//
//  TutorialViewController.swift
//  Seven
//
//  Created by apple on 7/3/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        drawTutorial()
        
    }
    

    func drawTutorial() {
        let superviewWidth = self.view.frame.width
        let superviewHeight = self.view.frame.height
        
        //parameters
        let width = superviewWidth * 0.85
        let height = superviewHeight * 0.7
        
        let closeButtonWidth = width * 0.1
        let labelWidth = width * 0.9
        
        let topPaddingPct : CGFloat = 0.05
        let titleLabelPct : CGFloat = 0.1
        let secondPaddingPct : CGFloat = 0.03
        let descriptionLabel1Pct : CGFloat = 0.1
        let thirdPaddingPct : CGFloat = 0.01
        let descriptionLabel2Pct : CGFloat = 0.2
        let fourthPaddingPct : CGFloat = 0.025
        let bottomPaddingPct : CGFloat = 0.05
        let tileRulesPct : CGFloat = 1 - (topPaddingPct + titleLabelPct + secondPaddingPct + descriptionLabel1Pct + thirdPaddingPct + descriptionLabel2Pct + fourthPaddingPct + bottomPaddingPct)
        
        guard tileRulesPct > 0 else{
            fatalError("tutorial's size of tile rules view is <= 0")
        }
        
        // create various views

        let inverseCloseButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        inverseCloseButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        self.view.addSubview(inverseCloseButton)
        
        let popupView = UIView(frame: CGRect(x: (superviewWidth - width)/2, y: (superviewHeight - height)/2, width: width, height: height))
        popupView.backgroundColor = UIColor.init(red: 218/255, green: 239/255, blue: 244/255, alpha: 0.98)
        popupView.backgroundColor = UIColor.init(red: 192/255, green: 195/255, blue: 210/255, alpha: 0.97)
        popupView.layer.shadowColor = UIColor.lightGray.cgColor
        popupView.layer.shadowOpacity = 1
        popupView.layer.shadowOffset = .zero
        popupView.layer.shadowRadius = 5

        popupView.layer.cornerRadius = 12
        self.view.addSubview(popupView)
        
        let closeButton = TutorialCloseButton(x: popupView.frame.maxX - closeButtonWidth*0.8, y: popupView.frame.minY - closeButtonWidth*0.2, width: closeButtonWidth, height: closeButtonWidth)
        closeButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
        let titleLabel = TutorialTitleLabel(x: popupView.frame.minX + (width - labelWidth)/2, y: popupView.frame.minY + topPaddingPct*height, width: labelWidth, height: titleLabelPct * height)
        self.view.addSubview(titleLabel)
        
        let text1 = "Swipe to move and combine tiles to make multiples of 7! Tiles combine based on the rules below."
        let text2 =  "Everytime you swipe, a new tile will appear - when you have no more spaces to move on the board the game will end. What's the highest tile you can get??"
        let descriptionLabel1 = TutorialDescriptionLabel1(x: titleLabel.frame.minX, y: titleLabel.frame.maxY + secondPaddingPct * height, width: titleLabel.frame.width, height: descriptionLabel1Pct * height, descriptionText: text1)
        let descriptionLabel2 = TutorialDescriptionLabel1(x: titleLabel.frame.minX, y: descriptionLabel1.frame.maxY + thirdPaddingPct * height, width: titleLabel.frame.width, height: descriptionLabel2Pct * height, descriptionText: text2)
        self.view.addSubview(descriptionLabel1)
        self.view.addSubview(descriptionLabel2)
        
        let tileRulesView = TutorialTileRulesView(x: titleLabel.frame.minX, y: descriptionLabel2.frame.maxY + fourthPaddingPct * height, width: titleLabel.frame.width, height: tileRulesPct * height)
        self.view.addSubview(tileRulesView)
        
       

        
    }
    
    @objc func closeButtonClicked() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func outsideOfTutorialClicked() {
        dismiss(animated: false, completion: nil)
    }

}
