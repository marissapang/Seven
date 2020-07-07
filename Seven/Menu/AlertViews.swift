//
//  AlertViews.swift
//  Seven
//
//  Created by apple on 7/2/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class ClearHistoryPopupView : UIView {
    var warningMessage = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var yesDeleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var noKeepButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    init(superviewWidth: CGFloat, superviewHeight: CGFloat) {
        // parameters
        let width : CGFloat = superviewWidth * 0.8
        let height : CGFloat = superviewHeight * 0.3
        let x : CGFloat = (superviewWidth - width)/2
        let y : CGFloat = (superviewHeight - height)/2

        let vertGap : CGFloat = height * 0.08
        
        let labelWidth : CGFloat = width * 0.9
        let labelHeight : CGFloat = height * 0.5
        let labelX : CGFloat = (width - labelWidth)/2
        let labelY : CGFloat = vertGap
        
        let buttonHeight : CGFloat = height - labelHeight - vertGap*3
        let buttonWidth : CGFloat =  width * 0.4
        let buttonXLeft : CGFloat = labelX
        let buttonXRight : CGFloat = labelX + labelWidth - buttonWidth
        let buttonY : CGFloat = labelY + labelHeight + vertGap
    

        // create background rectangle
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        // backgroundColor = UIColor.init(red: 223.0/255.0, green: 0.0/255.0, blue: 4.0/255.0, alpha: 1.0)
        // backgroundColor = UIColor.init(red: 253.0/255.0, green: 138.0/255.0, blue: 115.0/255.0, alpha: 1.0)
        backgroundColor = UIColor.init(red: 244.0/255.0, green: 160.0/255.0, blue: 138.0/255.0, alpha: 1)
        
        layer.cornerRadius = 12
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = .zero
        layer.shadowRadius = 5

        // create warning message label
        warningMessage = UILabel(frame: CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight))
        warningMessage.text = "Whoa, you sure you want to delete all your game history?"
        warningMessage.textAlignment = .center
        warningMessage.textColor = UIColor.white
        warningMessage.font = UIFont(name: "TallBasic30-Regular", size: 32)!
        warningMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        warningMessage.numberOfLines = 0
        
        // create "No, Keep my data" button
        noKeepButton = UIButton(frame: CGRect(x: buttonXLeft, y: buttonY, width: buttonWidth, height: buttonHeight))
        // noKeepButton.backgroundColor = UIColor.init(red: 88.0/255.0, green: 140.0/255.0, blue: 178.0/255.0, alpha: 1.0)
        noKeepButton.backgroundColor = UIColor.init(red: 14.0/255.0, green: 120.0/255.0, blue: 155.0/255.0, alpha: 1.0)
        noKeepButton.setTitle("NO", for: [])
        noKeepButton.titleLabel?.font = UIFont(name: "TallBasic30-Regular", size: 22)!
        noKeepButton.titleLabel?.textColor = UIColor.white
        noKeepButton.layer.cornerRadius = 18
        
        
        yesDeleteButton = UIButton(frame: CGRect(x: buttonXRight, y: buttonY, width: buttonWidth, height: buttonHeight))

        yesDeleteButton.backgroundColor  = UIColor.init(red: 223.0/255.0, green: 0.0/255.0, blue: 4.0/255.0, alpha: 1.0)
        yesDeleteButton.setTitle("YES, DELETE", for: [])
        yesDeleteButton.titleLabel?.font = UIFont(name: "TallBasic30-Regular", size: 22)!
        yesDeleteButton.titleLabel?.textColor = UIColor.white
        yesDeleteButton.layer.cornerRadius = 18
        
        addSubview(warningMessage)
        addSubview(noKeepButton)
        addSubview(yesDeleteButton)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }

}
