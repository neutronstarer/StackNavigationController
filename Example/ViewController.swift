//
//  ViewController.swift
//  Example
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

import UIKit
import StackNavigationController
import SnapKit

class Cell: UITableViewCell {
    
    var label: UILabel = {()->UILabel in
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 18)
        v.textColor = UIColor.white
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor.init(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor.init(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        }
    }
}

class CellModel: NSObject {
    var title: String?
    var action: (()->())?
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var tableView = {()->UITableView in
        let v = UITableView(frame: .zero, style: .plain)
        v.register(Cell.self, forCellReuseIdentifier: "Cell")
        v.delegate = self
        v.dataSource = self
        v.estimatedRowHeight = UITableView.automaticDimension
        //        if #available(iOS 11.0, *) {
        //            v.contentInsetAdjustmentBehavior = .never
        //        } else {
        // Fallback on earlier versions
        //        }
        v.tableFooterView = UIView()
        return v
    }()
    
    lazy var animationLayer = {()->CALayer in
        let v = CALayer()
        v.backgroundColor = UIColor.red.cgColor
        return v
    }()
    
    lazy var searchViewController = {()->SearchViewController in
        guard let stackNavigationController = self.snc_navigationController else {
            fatalError("only support StackNavigationController")
        }
        let v = SearchViewController(entryViewController: self)
        v.title = self.nextTitle(seq: 1)
        return v
    }()
    
    var cellModels : [CellModel] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("\(self.title ?? "") viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("\(self.title ?? "") viewDidAppear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("\(self.title ?? "") viewWillDisappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("\(self.title ?? "") viewDidDisappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        //        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(tableView)
        view.layer.addSublayer(animationLayer)
        animationLayer.frame = CGRect.init(x: 100, y: 100, width: 50, height: 50)
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.repeatCount = 100000
        animation.duration = 1
        animation.byValue = Double.pi*2
        animation.isRemovedOnCompletion = false
        animationLayer.add(animation, forKey: "transform.rotation.z")
        tableView.snp.makeConstraints { (make) in
            //            if #available(iOS 11.0, *) {
            //                make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            //                make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            //                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            //                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            //                return
            //            }
            make.edges.equalToSuperview()
        }
        
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "pop"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.popViewController(animated: true)
            }
            return v
            }())
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "pop to root"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.popToRootViewController(animated: true)
            }
            return v
            }())
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "fade"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.pushViewController({[weak self]()->ViewController in
                    let v = ViewController()
                    v.title = self?.nextTitle(seq: 1)
                    v.snc_transition = {()->SNCTransition in
                        let v = SNCFadeTransition()
                        return v
                    }()
                    return v
                    }(), animated: true)
            }
            return v
            }())
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "curtain"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.setViewControllers([{[weak self] ()->ViewController in
                    let v = ViewController()
                    v.title = self?.nextTitle(seq: 1)
                    v.snc_transition = {()->SNCCurtainTransition in
                        let v = SNCCurtainTransition()
                        return v
                    }()
                    return v
                    }()], animated: true)
            }
            return v
            }())
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "push"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.pushViewController({[weak self]()->ViewController in
                    let v = ViewController()
                    v.title = self?.nextTitle(seq: 1)
                    return v
                    }(), animated: true)
            }
            return v
            }())
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "present"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.pushViewController({[weak self]()->ViewController in
                    let v = ViewController()
                    v.title = self?.nextTitle(seq: 1)
                    v.snc_transition = {()->SNCTransition in
                        let v = SNCPresentTransition()
                        return v
                    }()
                    return v
                    }(), animated: true)
            }
            return v
            }())
        
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "push and present"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.pushViewControllers([{[weak self]()->ViewController in
                    let v = ViewController()
                    v.title = self?.nextTitle(seq: 1)
                    return v
                    }(),{[weak self]()->ViewController in
                        let v = ViewController()
                        v.title = self?.nextTitle(seq: 2)
                        v.snc_transition = {()->SNCTransition in
                            let v = SNCPresentTransition()
                            return v
                        }()
                        return v
                        }()], animated: true)
            }
            return v
            }())
        
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "transparent push and present"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.pushViewControllers([{[weak self]()->ViewController in
                    let v = ViewController()
                    v.title = self?.nextTitle(seq: 1)
                    v.snc_transition.transparent = true
                    return v
                    }(),{[weak self]()->ViewController in
                        let v = ViewController()
                        v.title = self?.nextTitle(seq: 2)
                        v.snc_transition = {()->SNCTransition in
                            let v = SNCPresentTransition()
                            return v
                        }()
                        v.snc_transition.transparent = true
                        return v
                        }()], animated: true)
            }
            return v
            }())
        
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "alert"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.pushViewControllers([{()->AlertViewController in
                    let v = AlertViewController()
                    return v
                    }()], animated: true)
            }
            return v
            }())
        
        cellModels.append({()->CellModel in
            let v = CellModel()
            v.title = "action sheet"
            v.action = {[weak self] ()->() in
                self?.snc_navigationController?.pushViewControllers([{()->ActionSheetViewController in
                    let v = ActionSheetViewController()
                    return v
                    }()], animated: true)
            }
            return v
            }())
        tableView.tableHeaderView = searchViewController.searchBar
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func nextTitle(seq: Int) -> String {
        return String((Int(self.title ?? "0") ?? 0) + seq, radix: 10)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        cell.label.text = cellModels[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        cellModels[indexPath.row].action!()
    }
    
}
