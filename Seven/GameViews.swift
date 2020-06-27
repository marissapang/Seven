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
        backgroundColor = UIColor.init(red: 66.0/255.0, green: 57.0/255.0, blue: 50.0/255.0, alpha: 1)
        
        // add a background grey view for each tile on the gameboard
        var tileView : UIView
        
        for row in 0..<dimensions {
            for col in 0..<dimensions {
                let x = (sizeAndPositionsDict["tileWidth"]! * CGFloat(row)) + (sizeAndPositionsDict["spacing"]! * CGFloat(row+1))
                
                let y = (sizeAndPositionsDict["tileHeight"]! * CGFloat(col)) + (sizeAndPositionsDict["spacing"]! * CGFloat(col+1))
                
                tileView = UIView(frame: CGRect(x: x, y: y, width: sizeAndPositionsDict["tileWidth"]!, height: sizeAndPositionsDict["tileHeight"]!))
                
                tileView.backgroundColor = UIColor.lightGray
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
        }
    }

    init(sizeAndPositionsDict: [String:CGFloat], tileValue: Int){
        // calculate where the (0,0) position for a view should be before it is moved onto gameboard
        value = tileValue
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: sizeAndPositionsDict["tileWidth"]!, height: sizeAndPositionsDict["tileHeight"]!))
        label.textAlignment = .center
        label.text = "\(tileValue)"
        label.font = appearance.font(value)
        
        let x = sizeAndPositionsDict["gameboardX"]! - sizeAndPositionsDict["tileWidth"]!
        let y = sizeAndPositionsDict["gameboardY"]! - sizeAndPositionsDict["tileHeight"]!
        
        super.init(frame: CGRect(x: x, y: y, width: sizeAndPositionsDict["tileWidth"]!, height: sizeAndPositionsDict["tileHeight"]!))
        
        backgroundColor = appearance.tileColor(value)
        layer.cornerRadius = 6.0
        
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder){
        value = 0
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        super.init(coder: aDecoder)
    }
}

//MARK: Tile Tracking
class SmallTileView: UIView {
    let appearance = Appearance()
    var label : UILabel
    var value : Int {
        didSet {
            label.text = "\(value)"
            // add in something to change tile color
            backgroundColor = appearance.tileColor(value)
            label.font = appearance.font(value)
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
        color = UIColor.black

        // create frame parameters
        let tileWidth = sizeAndPositionsDict["tileWidth"]! * smallTileScale
        let tileHeight = sizeAndPositionsDict["tileHeight"]! * smallTileScale
        let x = -tileWidth*0.75 // start at the very right of frame with tile only partially showing
        let y = sizeAndPositionsDict["gameboardY"]! + sizeAndPositionsDict["gameboardHeight"]! + tileHeight*0.75
        
        // create and format lbel
        label = UILabel(frame: CGRect(x: 0, y: 0, width: tileWidth, height: tileHeight))
        label.textAlignment = .center
        label.text = "\(tileValue)"
        label.font = appearance.fontSmallTile(value)
        
        
        // create frame
        super.init(frame: CGRect(x: x, y: y, width: tileWidth, height: tileHeight))
        
        backgroundColor = appearance.tileColor(value)
        layer.cornerRadius = 6.0 * smallTileScale
    
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
        let x = tileWidth*0.25 + sizeAndPositionsDict["spacing"]!/2 // start at the very right of frame with tile only partially showing
        
        let y = sizeAndPositionsDict["gameboardY"]! + sizeAndPositionsDict["gameboardHeight"]! + tileHeight*0.75 - sizeAndPositionsDict["spacing"]!/2
    
        
        // create and format label
        let label = UILabel(frame: CGRect(x: 0, y: -40, width: tileWidth*3, height: tileHeight))
        label.textAlignment = .left
        label.text = "Next Tile"
        label.textColor = UIColor.init(red: 252.0/255.0, green: 157.0/255.0, blue: 3.0/255.0, alpha: 1)
        label.font = UIFont(name: "Chalkboard SE", size: 16)!
        
        
        // create frame
        super.init(frame: CGRect(x: x, y: y, width: tileWidth + sizeAndPositionsDict["spacing"]!, height: tileHeight + sizeAndPositionsDict["spacing"]!))
        
        backgroundColor = UIColor.clear
        layer.borderWidth = 4
        layer.borderColor = UIColor.init(red: 252.0/255.0, green: 157.0/255.0, blue: 3.0/255.0, alpha: 1).cgColor
        layer.cornerRadius = 6.0 * smallTileScale * 1.1
    
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

//MARK: Endgame
class EndGamePopupView : UIView {
    init(superviewWidth: CGFloat, superviewHeight: CGFloat){
        
        let popupWidth = superviewWidth * 0.95
        let popupHeight = superviewHeight * 0.4
        let labelWidth = superviewWidth * 0.85
        let labelHeight = superviewWidth * 0.3

        
        let popupX = (superviewWidth - popupWidth)/2
        let popupY = (superviewHeight - popupHeight)/2
        let labelX = (superviewWidth - labelWidth)/2
        let labelY = (superviewHeight - popupHeight)/2 + superviewHeight*0.05
        
        // first create a white translucent mask across the entire screen
        super.init(frame: CGRect(x: 0, y: 0, width: superviewWidth, height: superviewHeight))
        backgroundColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        
        
        let popupView = UIView(frame: CGRect(x: popupX, y: popupY, width: popupWidth, height: popupHeight))
        
        let popupLabel = UILabel(frame: CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight))
        
        
        popupView.backgroundColor = UIColor.init(red: 102.0/255.0, green: 179.0/255.0, blue: 255.0/255.0, alpha: 0.97)
        popupView.layer.cornerRadius = 15
        popupLabel.text = "Noo you're out of moves! "
        popupLabel.textAlignment = .center
        popupLabel.font = UIFont(name: "Chalkboard SE", size: 32)!
        popupLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        popupLabel.numberOfLines = 0
        
         
        addSubview(popupView)
        addSubview(popupLabel)
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
        
        backgroundColor = UIColor.init(red: 97.0/255.0, green: 56.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        setTitle("Play Again!", for: [])
        titleLabel?.font = UIFont(name: "Chalkboard SE", size: 32)!
        titleLabel?.textColor = UIColor.white
        layer.cornerRadius = 15
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
        let height = sizeAndPositionsDict["gameboardY"]! * 0.4
        let x = sizeAndPositionsDict["gameboardX"]! + (sizeAndPositionsDict["gameboardWidth"]! - width)/2
        let y = sizeAndPositionsDict["gameboardY"]! * 0.5
        
        label = UILabel(frame: CGRect(x: 0, y:0, width: width, height: height))
        label.text = "\(score)"
        label.textAlignment = .center
        label.font = UIFont(name: "Chalkboard SE", size: 48)!
        
        
        
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        backgroundColor = UIColor.init(red: 255.0/255.0, green: 221.0/255.0, blue: 153.0/255.0, alpha: 1)
        layer.cornerRadius = 15
        
        addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder){
        label = UILabel(frame: CGRect(x: 0, y:0, width: 10, height: 10))
        super.init(coder: aDecoder)
    }
}




