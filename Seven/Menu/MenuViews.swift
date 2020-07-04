//
//  MenuViews.swift
//  Seven
//
//  Created by apple on 7/1/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class MenuHighScoreView : UIView {
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, highScore: Int, totalGamesPlayed: Int) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
        
        let paddingPct : CGFloat = 0.02
        let titleLabelPct : CGFloat = 0.29
        let highScoreViewPct : CGFloat = 0.55
        let commentLabelPct : CGFloat = 1 - (paddingPct*2 + titleLabelPct + highScoreViewPct)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height*titleLabelPct))
        let highScoreView = UIView(frame: CGRect(x: width*0.15, y: height*(paddingPct + titleLabelPct), width: width*0.7, height: height*highScoreViewPct))
        let highScoreLabel = UILabel(frame: CGRect(x: width*0.15, y: highScoreView.frame.minY+5, width: width*0.65, height: highScoreView.frame.height))
        let commentLabel = UILabel(frame: CGRect(x: width*0.1, y: height*(paddingPct*2 + titleLabelPct + highScoreViewPct), width: width*0.8, height: height*commentLabelPct))
        
        titleLabel.text = "YOUR HIGH SCORE:"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "TallBasic20-Regular", size: 46)!
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        
        highScoreView.backgroundColor = UIColor.init(red: 251.0/255.0, green: 217.0/255.0, blue: 208.0/255.0, alpha: 1)
        highScoreView.layer.cornerRadius = 10
        
        highScoreLabel.text = "\(highScore)"
        highScoreLabel.textAlignment = .center
        highScoreLabel.font = UIFont(name: "TallBasic20-Regular", size: 62)!
        highScoreLabel.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        highScoreLabel.adjustsFontSizeToFitWidth = true
        
        commentLabel.text = "(You've played \(totalGamesPlayed) games of Seven)"
        commentLabel.textAlignment = .center
        commentLabel.font = UIFont(name: "TallBasic20-Regular", size: 20)!
        commentLabel.textColor = UIColor.init(red: 255.0/255.0, green: 121.0/255.0, blue: 123.0/255.0, alpha: 1)
        commentLabel.adjustsFontSizeToFitWidth = true
        
        addSubview(titleLabel)
        addSubview(highScoreView)
        addSubview(highScoreLabel)
        addSubview(commentLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class TileCountRowView : UIView {
    init(width: CGFloat, height: CGFloat, rowIndex: CGFloat, tileValue: Int, tileCount: Int){
        
        // parameters for horizontal positions
        let w : CGFloat = width*0.9
        // let tileWidthPct : CGFloat = 0.2
        let widthGapPct : CGFloat = 0.05
        let widthPctOfHeight : CGFloat = 0.8
        
        // parmeter for vertical positions
        let numRows : CGFloat = 5
        let numGaps : CGFloat = numRows
        let titleLabelPct : CGFloat = 1/(numRows+1) * 0.6
        let gapPct : CGFloat = 0.015
        let rowPct : CGFloat = (1 - titleLabelPct - numGaps*gapPct)/numRows
        
        let dummySizeAndPositionsDict : [String: CGFloat] = ["tileWidth":100, "tileHeight":100, "gameboardWidth":1000, "gameboardHeight":1000, "gameboardX":0, "gameboardY":0, "tileX":0, "tileY":0, "spacing":10]
        
        super.init(frame: CGRect(x: (width-w)/2, y: rowIndex * height * (gapPct + rowPct) + titleLabelPct * height, width: w, height: height * rowPct))
        
        // Create tileView
        let tileView = TileView(sizeAndPositionsDict: dummySizeAndPositionsDict, tileValue: tileValue)
        tileView.frame = CGRect(x: 0, y: 0, width: height*rowPct*widthPctOfHeight, height: height*rowPct)
        
        let tileViewLabelWidth = tileView.frame.width * 0.75
        tileView.label.frame = CGRect(x: (tileView.frame.width-tileViewLabelWidth)/2, y: 2, width: tileViewLabelWidth, height: height*rowPct)
        tileView.label.font = UIFont(name: "TallBasic20-Regular", size: 32)!
        tileView.label.adjustsFontSizeToFitWidth = true
        
        tileView.layer.shadowColor = UIColor.white.cgColor
        tileView.layer.shadowOpacity = 0.8
        tileView.layer.shadowOffset = .zero
        tileView.layer.shadowOffset = CGSize(width: 2.0, height: 3)
        tileView.layer.shadowRadius = 3
        
        
        // Create numberLabel
        let tileCountLabel = UILabel(frame: CGRect(x: tileView.frame.width + w*widthGapPct, y: 0, width: w - w*widthGapPct - widthPctOfHeight*height*rowPct, height: height * rowPct))
        
        if tileCount == 0 {
            tileCountLabel.text = "None"
        } else if tileCount == 1 {
            tileCountLabel.text = "\(tileCount) game"
        } else {
            tileCountLabel.text = "\(tileCount) games"
        }
        
        tileCountLabel.textAlignment = .left
        tileCountLabel.font = UIFont(name: "TallBasic20-Regular", size: 34)!
        tileCountLabel.adjustsFontSizeToFitWidth = true
        tileCountLabel.textColor = UIColor.white
        
        addSubview(tileView)
        addSubview(tileCountLabel)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
}

class MenuTileCountView : UIView {
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, tileCountDict: [Int: Int]){
        super.init(frame: CGRect(x: x, y: y, width: width, height: height))
                
        // 1. Make title label
        let w : CGFloat = width*0.9
        let numRows : CGFloat = 5
        let titleLabelPct : CGFloat = 1/(numRows+1) * 0.6
        let titleLabel = UILabel(frame: CGRect(x: (width - w)/2, y: 0, width: width, height: height*titleLabelPct))
        titleLabel.text = "HIGH-TILE ACHIEVEMENTS:"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "TallBasic20-Regular", size: 34)!
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = UIColor.white
        titleLabel.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        
        // let row112 = TileCountRowView(width: width, height: height, rowIndex: 0, tileValue: 112, tileCount: tileCountDict[112]!)
        let row224 = TileCountRowView(width: width, height: height, rowIndex: 0, tileValue: 224, tileCount: tileCountDict[224]!)
        let row448 = TileCountRowView(width: width, height: height, rowIndex: 1, tileValue: 448, tileCount: tileCountDict[448]!)
        let row896 = TileCountRowView(width: width, height: height, rowIndex: 2, tileValue: 896, tileCount: tileCountDict[896]!)
        let row1792 = TileCountRowView(width: width, height: height, rowIndex: 3, tileValue: 1792, tileCount: tileCountDict[1792]!)
        let row3584 = TileCountRowView(width: width, height: height, rowIndex: 4, tileValue: 3584, tileCount: tileCountDict[3584]!)
        
        addSubview(titleLabel)
        // addSubview(row112)
        addSubview(row224)
        addSubview(row448)
        addSubview(row896)
        addSubview(row1792)
        addSubview(row3584)
    }
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
}

class MenuFooterView : UIView {
    var clearHistoryButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var contactUsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat){
        let w : CGFloat = width*0.9
        let h : CGFloat = height*0.8
        let buttonWidthPct : CGFloat = 0.3
        super.init(frame: CGRect(x: (width-w)/2, y: y, width: w, height: height))
        
        clearHistoryButton = UIButton(frame: CGRect(x: 0, y: 0, width: w * buttonWidthPct, height: h))
        contactUsButton = UIButton(frame: CGRect(x: w - w*buttonWidthPct, y: 0, width: w * buttonWidthPct, height: h))
        
        clearHistoryButton.setTitle("Clear history", for: [])
        clearHistoryButton.titleLabel?.font = UIFont(name: "TallBasic20-Regular", size: 16)!
        clearHistoryButton.titleLabel?.textColor = UIColor.white
        clearHistoryButton.backgroundColor = UIColor.init(red: 223.0/255.0, green: 0.0/255.0, blue: 4.0/255.0, alpha: 1.0)
        clearHistoryButton.layer.cornerRadius = 10
        // clearHistoryButton.addTarget(self, action:#selector(clearHistoryWarning), for: .touchUpInside)
        
        contactUsButton.setTitle("Contact Us", for: [])
        contactUsButton.titleLabel?.font = UIFont(name: "TallBasic20-Regular", size: 16)!
        contactUsButton.titleLabel?.textColor = UIColor.white
        contactUsButton.backgroundColor = UIColor.init(red: 14.0/255.0, green: 120.0/255.0, blue: 155.0/255.0, alpha: 1.0)
        contactUsButton.layer.cornerRadius = 10
            
        addSubview(clearHistoryButton)
        addSubview(contactUsButton)
    }
    
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
//    @objc func clearHistoryWarning(){
//        print("inside clear history warning")
//        let clearHistoryViewController = ClearHistoryViewController()
//        clearHistoryViewController.modalPresentationStyle = .fullScreen
//        // menuViewController.modalTransitionStyle = .flipHorizontal
//
//        present(clearHistoryViewController, animated: true, completion: nil)
//    }
}



