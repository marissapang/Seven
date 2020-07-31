//
//  GameViews.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

//MARK: Core Game
class GameboardView: UIView {
    init(dimensions: Int, sizeAndPositionsDict: [String:CGFloat]){
        super.init(frame: CGRect(x: sizeAndPositionsDict["gameboardX"]!,
                                 y: sizeAndPositionsDict["gameboardY"]!,
                                 width: sizeAndPositionsDict["gameboardWidth"]!,
                                 height: sizeAndPositionsDict["gameboardHeight"]!)
        )
        layer.cornerRadius = 10.0
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        
        backgroundColor = UIColor.init(red: 47.0/255.0, green: 58.0/255.0, blue: 61.0/255.0, alpha: 0.95)
        
        // add a background grey view for each tile on the gameboard
        var tileView : UIView
        
        for row in 0..<dimensions {
            for col in 0..<dimensions {
                let x = (sizeAndPositionsDict["tileWidth"]! * CGFloat(row)) + (sizeAndPositionsDict["spacing"]! * CGFloat(row+1))
                
                let y = (sizeAndPositionsDict["tileHeight"]! * CGFloat(col)) + (sizeAndPositionsDict["spacing"]! * CGFloat(col+1))
                
                tileView = UIView(frame: CGRect(x: x, y: y, width: sizeAndPositionsDict["tileWidth"]!, height: sizeAndPositionsDict["tileHeight"]!))
                
                tileView.backgroundColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
                tileView.layer.cornerRadius = 6.0
                
                addSubview(tileView)
            }
        }

    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TileView: UIView {
    let appearance = Appearance()
    var label : UILabel
    var value : Int {
        didSet {
            label.text = "\(value)"
            // add in something to change tile color
            backgroundColor = appearance.tileColor(value)
            label.font = appearance.font(value)
            layer.borderColor = appearance.borderColor(value)
        }
    }

    init(sizeAndPositionsDict: [String:CGFloat], tileValue: Int){
        // calculate where the (0,0) position for a view should be before it is moved onto gameboard
        value = tileValue
        
        let labelWidth = sizeAndPositionsDict["tileWidth"]!*0.75
        label = UILabel(frame: CGRect(x: (sizeAndPositionsDict["tileWidth"]!-labelWidth)/2, y: 3, width: labelWidth, height: sizeAndPositionsDict["tileHeight"]!))
        label.textAlignment = .center
        label.text = "\(tileValue)"
        label.font = appearance.font(value)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        
        let x = sizeAndPositionsDict["gameboardX"]! - sizeAndPositionsDict["tileWidth"]!
        let y = sizeAndPositionsDict["gameboardY"]! - sizeAndPositionsDict["tileHeight"]!
        
        super.init(frame: CGRect(x: x, y: y, width: sizeAndPositionsDict["tileWidth"]!, height: sizeAndPositionsDict["tileHeight"]!))
        
        backgroundColor = appearance.tileColor(value)
        layer.cornerRadius = 6.0
        layer.borderWidth = 4
        layer.borderColor = appearance.borderColor(value)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize(width: 1.3, height: 2)
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder){
        value = 0
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        super.init(coder: aDecoder)
    }
}

//MARK: Tile Tracking

class TileTrackingStrip: UIView {
    init(sizeAndPositionsDict: [String:CGFloat], superviewWidth: CGFloat, smallTileScale: CGFloat){


        // create frame parameters
        let tileHeight = sizeAndPositionsDict["tileHeight"]! * smallTileScale
        let y = (sizeAndPositionsDict["gameboardY"]! + sizeAndPositionsDict["gameboardHeight"]! + tileHeight*0.65)
        
        // create frame
        super.init(frame: CGRect(x: 0, y: y*0.95, width: superviewWidth, height: tileHeight*5))
        
//        backgroundColor = UIColor.init(red: 10.0/255.0, green: 86.0/255.0, blue: 111.0/255.0, alpha: 0.3)
//        backgroundColor = UIColor.init(red: 198.0/255.0, green: 193.0/255.0, blue: 194.0/255.0, alpha: 0.9)
//        backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.7)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class SmallTileView: UIView {
    let appearance = Appearance()
    var label : UILabel
    var value : Int {
        didSet {
            label.text = "\(value)"
            // add in something to change tile color
            backgroundColor = appearance.tileColor(value)
            label.font = appearance.font(value)
            layer.borderColor = appearance.borderInactiveColor(value)
        }
    }
    var color : UIColor {
        didSet {
            backgroundColor = appearance.tileInactiveColor(value)
            label.textColor = color
        }
    }

    init(sizeAndPositionsDict: [String:CGFloat], tileValue: Int, smallTileScale: CGFloat){
        
        value = tileValue
        color = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)

        // create frame parameters
        let tileWidth = sizeAndPositionsDict["tileWidth"]! * smallTileScale
        let tileHeight = sizeAndPositionsDict["tileHeight"]! * smallTileScale
        let x = -tileWidth*0.65 // start at the very right of frame with tile only partially showing
        let y = sizeAndPositionsDict["gameboardY"]! + sizeAndPositionsDict["gameboardHeight"]! + tileHeight*0.65
        
        // create and format lbel
        label = UILabel(frame: CGRect(x: 0, y: 0, width: tileWidth, height: tileHeight))
        label.textAlignment = .center
        label.text = "\(tileValue)"
        label.font = appearance.fontSmallTile(value)
        label.textColor = color
        
        
        // create frame
        super.init(frame: CGRect(x: x, y: y, width: tileWidth, height: tileHeight))
        
        backgroundColor = appearance.tileColor(value)
        layer.cornerRadius = 6.0 * smallTileScale
        layer.borderWidth = 4.0
        layer.borderColor = appearance.borderColor(value)
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 1.3, height: 2)
        layer.shadowOffset = .zero
        layer.shadowRadius = 0.5
    
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder){
        value = 0
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        color = UIColor.black
        super.init(coder: aDecoder)
    }
}

class SmallTileHighlight : UIView {

    init(sizeAndPositionsDict: [String:CGFloat], smallTileScale: CGFloat){
        
        // create frame parameters
        let tileWidth = sizeAndPositionsDict["tileWidth"]! * smallTileScale
        let tileHeight = sizeAndPositionsDict["tileHeight"]! * smallTileScale
        let x = tileWidth*0.25 + sizeAndPositionsDict["spacing"]! // start at the very right of frame with tile only partially showing
        
        let y = sizeAndPositionsDict["gameboardY"]! + sizeAndPositionsDict["gameboardHeight"]! + tileHeight*0.65 // - sizeAndPositionsDict["spacing"]!/2
    

        
        // create frame
        super.init(frame: CGRect(x: x, y: y, width: tileWidth + sizeAndPositionsDict["spacing"]!, height: tileHeight + sizeAndPositionsDict["spacing"]!))
        
        // create and format label
        let label = UILabel(frame: CGRect(x: -self.frame.width*0.25, y: -tileHeight*0.45+3, width: self.frame.width*1.5, height: tileHeight*0.45))
        label.textAlignment = .center
        label.text = "Next Tile"
        label.textColor = UIColor.init(red: 255.0/255.0, green: 121.0/255.0, blue: 123.0/255.0, alpha: 1)
        label.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 0.75)
        label.font = UIFont(name: "TallBasic30-Regular", size: 24)!
        label.adjustsFontSizeToFitWidth = true
        
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
            
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}



//MARK: Scores
class ScoreView : UIView {
    var label : UILabel
    var score = 0 {
        didSet {
            label.text = "\(score)"
        }
    }
    
    init(sizeAndPositionsDict: [String: CGFloat]) {
        let width = sizeAndPositionsDict["gameboardWidth"]! * 0.6
        let height = sizeAndPositionsDict["gameboardY"]! * 0.45
        let x = sizeAndPositionsDict["gameboardX"]! + (sizeAndPositionsDict["gameboardWidth"]! - width)/2
        let y = sizeAndPositionsDict["gameboardY"]! * 0.45
        
        label = UILabel(frame: CGRect(x: 0, y:3, width: width, height: height))
        label.text = "\(score)"
        label.textAlignment = .center
        label.font = UIFont(name: "TallBasic30-Regular", size: 62)!
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = UIColor.init(red: 207.0/255.0, green: 233.0/255.0, blue: 240.0/255.0, alpha: 1)

        layer.cornerRadius = 15
        layer.shadowColor = UIColor.init(red: 207.0/255.0, green: 233.0/255.0, blue: 240.0/255.0, alpha: 1).cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        
        addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder){
        label = UILabel(frame: CGRect(x: 0, y:0, width: 10, height: 10))
        super.init(coder: aDecoder)
    }
}

//MARK: Navigation
class navButton : UIButton {
    init(sizeAndPositionsDict: [String: CGFloat], x: CGFloat, labelText: String){
        let y = sizeAndPositionsDict["gameboardY"]! * 0.2
        let width = sizeAndPositionsDict["gameboardWidth"]! * 0.2
        let height = sizeAndPositionsDict["gameboardY"]! * 0.18
        
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
                
        backgroundColor = UIColor.init(red: 244.0/255.0, green: 160.0/255.0, blue: 138.0/255.0, alpha: 1)
        
        
        
        if labelText == "STATS" {
            setImage(UIImage(named:"statsIcon"), for: [])
            imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8,right: 8)
        } else {
            titleEdgeInsets = UIEdgeInsets(top: 3,left: 3,bottom: 0,right: 3)
            setTitle(labelText, for: [])
            titleLabel?.font = UIFont(name: "TallBasic30-Regular", size: 24)!
            titleLabel?.adjustsFontSizeToFitWidth = true
            titleLabel?.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        }
        
        
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.85
        layer.shadowOffset = .zero
        layer.shadowRadius = 2.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class HelpButton : UIButton {
    init(sizeAndPositionsDict: [String: CGFloat]){
        let width : CGFloat = 65
        let height: CGFloat = 65
        let x = sizeAndPositionsDict["gameboardX"]! + sizeAndPositionsDict["gameboardWidth"]! - width/2
        let y = sizeAndPositionsDict["gameboardY"]! - height*1.05
        super.init(frame: CGRect(x:x, y:y, width: width, height: height))
        setImage(UIImage(named:"helpButton"), for: [])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}




