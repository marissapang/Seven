//
//  GameViews.swift
//  Seven
//
//  Created by apple on 6/12/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class TileView: UIView {

    init(sizeAndPositionsDict: [String:CGFloat], tileValue: Int){
        // calculate where the (0,0) position for a view should be before it is moved onto gameboard
        
        let x = sizeAndPositionsDict["gameboardX"]! - sizeAndPositionsDict["tileWidth"]!
        let y = sizeAndPositionsDict["gameboardY"]! - sizeAndPositionsDict["tileHeight"]!
        
        super.init(frame: CGRect(x: x, y: y, width: sizeAndPositionsDict["tileWidth"]!, height: sizeAndPositionsDict["tileHeight"]!))
        
        backgroundColor = UIColor.green
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: sizeAndPositionsDict["tileWidth"]!, height: sizeAndPositionsDict["tileHeight"]!))
        label.textAlignment = .center
        label.text = "\(tileValue)"
        label.font = label.font.withSize(22)
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

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
