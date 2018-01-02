//
//  ViewController.swift
//  SandBoxTool
//
//  Created by kris on 2018/1/2.
//  Copyright © 2018年 kris'Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ZFSandBoxTool.sharedInstance.enableSwipe()
        
        //test
        let filePath:String = NSHomeDirectory() + "/Documents/text.txt"
        let info = "test"
        try! info.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    


}

