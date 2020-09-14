//
//  RootViewController.swift
//  Example
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

import UIKit
import StackNavigationController

class RootViewController: StackNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.setViewControllers([{()->ViewController in
            let v = ViewController()
            v.title = "0"
            return v
            }()], animated: false)
        // Do any additional setup after loading the view.
    }

}

