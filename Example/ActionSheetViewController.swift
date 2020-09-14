//
//  ActionSheetViewController.swift
//  Example
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

import UIKit
import StackNavigationController

class ActionSheetViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        build()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }
    
    func build() {
        self.snc_transition = {()->SNCActionSheetTransition in
            let v = SNCActionSheetTransition()
            return v
        }()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let contentView = {()->UIView in
            let v = UIView()
            let label = {()->UILabel in
                let v = UILabel()
                v.backgroundColor = UIColor.init(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1)
                v.textColor = UIColor.white
                v.textAlignment = .center
                v.text = "This is a action sheet"
                v.preferredMaxLayoutWidth = view.bounds.width-28
                return v
            }()
            let button = {()->UIButton in
                let v = UIButton()
                v.backgroundColor = UIColor.init(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1)
                v.setTitle("Got it", for: .normal)
                v.setTitleColor(UIColor.white, for: .normal)
                v.addTarget(self, action: #selector(pop), for: .touchUpInside)
                return v
            }()
            v.addSubview(label)
            v.addSubview(button)
            label.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(14)
                make.leading.equalToSuperview().offset(14)
                make.trailing.equalToSuperview().offset(-14)
                make.bottom.equalTo(button.snp.top).offset(-44)
            }
            button.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(14)
                make.trailing.equalToSuperview().offset(-14)
                make.bottom.equalTo(v).offset(-14)
            }
            return v
        }()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.lessThanOrEqualTo(view)
            }
        }
        view.layoutIfNeeded()
        let width: CGFloat = 325
        var height: CGFloat = 0
        if #available(iOS 11.0, *) {
            height = fmin(contentView.bounds.size.height + (self.navigationController?.view.safeAreaInsets.bottom)!, width)
        } else {
            height = fmin(contentView.bounds.size.height, width)
        }
        let transition = self.snc_transition as! SNCActionSheetTransition
        transition.contentSize = CGSize(width: width, height: height)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        let navigationView = self.navigationController?.view
        navigationView?.layer.masksToBounds = false
        navigationView?.layer.shadowOpacity = 1
        navigationView?.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 8).cgPath
        navigationView?.layer.shadowColor = UIColor.black.cgColor
        navigationView?.layer.shadowOffset = CGSize(width: 0, height: 0)
        navigationView?.layer.shadowRadius = 8
    }
    
    @objc func pop() {
        self.snc_navigationController?.popViewController(animated: true)
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
