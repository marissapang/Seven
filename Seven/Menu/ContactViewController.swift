//
//  ContactViewController.swift
//  Seven
//
//  Created by apple on 7/4/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let superviewWidth = self.view.frame.width
        let superviewHeight = self.view.frame.height
        let width = superviewWidth * 0.9
        let height = superviewHeight * 0.4
        
        let backgroundCloseButton = UIButton(frame: CGRect(x: 0, y: 0, width: superviewWidth, height: superviewHeight))
        backgroundCloseButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        
        let view = UIView(frame: CGRect(x: (superviewWidth-width)/2, y: (superviewHeight-height)/2, width: width, height: height))
        
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.95)
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4
    
        
        let label = UILabel(frame: CGRect(x: (superviewWidth-width)/2, y: (superviewHeight-height)/2, width: width, height: height))
        label.text = "You can reach us at: \n seventhegame@outlook.com"
        label.textAlignment = .center
        label.textColor = UIColor.init(red: 58.0/255.0, green: 44.0/255.0, blue: 47.0/255.0, alpha: 1)
        label.font = UIFont(name: "TallBasic30-Regular", size: 32)!
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 2
        
        
        self.view.addSubview(backgroundCloseButton)
        self.view.addSubview(view)
        self.view.addSubview(label)
    }
    
    @objc func closeButtonClicked(){
        dismiss(animated: false, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
