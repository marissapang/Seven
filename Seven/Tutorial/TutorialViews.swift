//
//  TutorialViews.swift
//  Seven
//
//  Created by apple on 7/3/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class TutorialCloseButton : UIButton {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x:x, y:y, width: width, height: height))
        setImage(UIImage(named:"closeButton"), for: [])
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TutorialTitleLabel : UILabel {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        text = "Welcome to Seven!"
        font = UIFont(name: "TallBasic30-Regular", size: 38)!
        textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TutorialDescriptionLabel1 : UILabel {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, descriptionText: String){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        text = descriptionText
        font = UIFont(name: "TallBasic30-Regular", size: 20)!
        adjustsFontSizeToFitWidth = true
        textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        lineBreakMode = .byWordWrapping
        numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}


class TutorialTileRulesView : UIView {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        
        // parameters
        let label1Pct : CGFloat = 0.1
        let label2Pct : CGFloat = 0.1
        let gapPct : CGFloat = 0.05
        let numRules : CGFloat = 3
        let rowPct = (1 - (label1Pct + label2Pct + gapPct * (numRules-1)))/numRules
        
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: label1Pct*height))
        label1.text = "For tiles with values of 7 or higher:"
        label1.textColor = UIColor(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        label1.font = UIFont(name: "TallBasic30-Regular", size: 22)!
        label1.textAlignment = .left

        let row1 = TutorialTileRulesRowView(y: label1Pct*height, width: width, height: rowPct*height, gapHeight: gapPct*height, tileValue1: 7, tileValue2: 7)

        let label2 = UILabel(frame: CGRect(x: 0, y: row1.frame.maxY + gapPct*height, width: width, height: label1Pct*height))
        label2.text = "For tiles with values less than 7:"
        label2.textColor = UIColor(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        label2.font = UIFont(name: "TallBasic30-Regular", size: 22)!
        label2.textAlignment = .left
        
        let row2 = TutorialTileRulesRowView(y: row1.frame.maxY+gapPct*height+label2Pct*height, width: width, height: rowPct*height, gapHeight: gapPct*height, tileValue1: 2, tileValue2: 5)
        let row3 = TutorialTileRulesRowView(y: row2.frame.maxY+gapPct*height, width: width, height: rowPct*height, gapHeight: gapPct*height, tileValue1: 3, tileValue2: 4)
       //  let row4 = TutorialTileRulesRowView(y: row3.frame.maxY+gapPct*height, width: width, height: rowPct*height, gapHeight: gapPct*height, tileValue1: 2, tileValue2: 2)

        // add views
        addSubview(label1)
        addSubview(label2)
        addSubview(row1)
        addSubview(row2)
        addSubview(row3)
        // addSubview(row4)
    }
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TutorialTileRulesRowView: UIView {
    init(y: CGFloat, width: CGFloat, height: CGFloat, gapHeight: CGFloat, tileValue1: Int, tileValue2: Int){
        super.init(frame: CGRect(x: width*0.1, y: y, width: width*0.8, height: height))
        
        let dummySizeAndPositionsDict : [String: CGFloat] = ["tileWidth":100, "tileHeight":100, "gameboardWidth":1000, "gameboardHeight":1000, "gameboardX":0, "gameboardY":0, "tileX":0, "tileY":0, "spacing":10]
        let tileWidth = height * 0.85
        
        let tile1 = TileView(sizeAndPositionsDict: dummySizeAndPositionsDict, tileValue: tileValue1)
        let tile2 = TileView(sizeAndPositionsDict: dummySizeAndPositionsDict, tileValue: tileValue2)
        let tile3 = TileView(sizeAndPositionsDict: dummySizeAndPositionsDict, tileValue: tileValue1 + tileValue2)
        
        tile1.frame = CGRect(x: 0, y: 0, width: tileWidth, height: height)
        tile1.label.frame = CGRect(x: 0, y: 3, width: tileWidth, height: height)
        tile1.label.font = UIFont(name: "TallBasic30-Regular", size: 37)!
        tile2.frame = CGRect(x: tileWidth * 2, y: 0, width: tileWidth, height: height)
        tile2.label.frame = CGRect(x: 0, y: 3, width: tileWidth, height: height)
        tile2.label.font = UIFont(name: "TallBasic30-Regular", size: 37)!
        tile3.frame = CGRect(x: tileWidth * 4, y: 0, width: tileWidth, height: height)
        tile3.label.frame = CGRect(x: 0, y: 3, width: tileWidth, height: height)
        tile3.label.font = UIFont(name: "TallBasic30-Regular", size: 37)!
        
        tile1.layer.shadowColor = UIColor.lightGray.cgColor
        tile1.layer.shadowOpacity = 1
        tile1.layer.shadowOffset = .zero
        tile1.layer.shadowOffset = CGSize(width: 1.3, height: 2)
        tile1.layer.shadowRadius = 3
        
        tile2.layer.shadowColor = UIColor.lightGray.cgColor
        tile2.layer.shadowOpacity = 1
        tile2.layer.shadowOffset = .zero
        tile2.layer.shadowOffset = CGSize(width: 1.3, height: 2)
        tile2.layer.shadowRadius = 3
        
        tile3.layer.shadowColor = UIColor.lightGray.cgColor
        tile3.layer.shadowOpacity = 1
        tile3.layer.shadowOffset = .zero
        tile3.layer.shadowOffset = CGSize(width: 1.3, height: 2)
        tile3.layer.shadowRadius = 3
        
        
        let plusLabel = UILabel(frame: CGRect(x: tileWidth, y: 5, width: tileWidth, height: height))
        plusLabel.text = "+"
        plusLabel.textAlignment = .center
        plusLabel.font = UIFont(name: "TallBasic30-Regular", size: 50)!
        
        let equalLabel = UILabel(frame: CGRect(x: tileWidth*3, y: 5, width: tileWidth, height: height))
        equalLabel.text = "="
        equalLabel.textAlignment = .center
        equalLabel.font = UIFont(name: "TallBasic30-Regular", size: 50)!
        
        if tileValue1 == 7 {
            tile1.label.text = "value"
            tile2.label.text = "value"
            tile3.label.text = "value + value"
            
            
            tile1.label.font = UIFont(name: "TallBasic30-Regular", size: 18)!
            tile1.label.adjustsFontSizeToFitWidth = true
            
            tile2.label.adjustsFontSizeToFitWidth = true
            tile2.label.font = UIFont(name: "TallBasic30-Regular", size: 18)!
            
            tile3.label.font = UIFont(name: "TallBasic30-Regular", size: 16)!
            tile3.label.lineBreakMode = .byWordWrapping
            tile3.label.numberOfLines = 0
            
        }
        
        addSubview(tile1)
        addSubview(tile2)
        addSubview(tile3)
        addSubview(plusLabel)
        addSubview(equalLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}
