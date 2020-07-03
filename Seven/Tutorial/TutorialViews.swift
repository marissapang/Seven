//
//  TutorialViews.swift
//  Seven
//
//  Created by apple on 7/3/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class TutorialTitleLabel : UILabel {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        text = "Welcome to Seven!"
        font = UIFont(name: "TallBasic-Regular", size: 38)!
        textColor = UIColor.init(red: 255.0/255.0, green: 121.0/255.0, blue: 123.0/255.0, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TutorialDescriptionLabel1 : UILabel {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        text = "Swipe to combine tiles and make multiples of 7! A '7' tile will combine with another '7' tile, a '14' tile will combine with another '14' tile... and so on - play to see what the highest tile you can get!"
        font = UIFont(name: "TallBasic-Regular", size: 24)!
        textColor = UIColor.init(red: 255.0/255.0, green: 121.0/255.0, blue: 123.0/255.0, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TutorialDescriptionLabel2 : UILabel {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        text = "When tiles smaller than 7 appear, they combine based on the rules below. Everytime you swipe a new tile will appear, when you have no more spaces to move on the board the game will end!"
        font = UIFont(name: "TallBasic-Regular", size: 24)!
        textColor = UIColor.init(red: 255.0/255.0, green: 121.0/255.0, blue: 123.0/255.0, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TutorialTileRulesView : UIView {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = UIColor.red
    }
    
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TutorialTileRulesRowView: UIView {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}
