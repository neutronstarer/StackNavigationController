//
//  SearchViewController.swift
//  Example
//
//  Created by neutronstarer on 2020/8/25.
//  Copyright © 2020 neutronstarer. All rights reserved.
//

import UIKit
import StackNavigationController

class SearchBar: UIView, UITextFieldDelegate {
    
    var placeholder: String? {
        didSet {
            searchTextField.placeholder = placeholder
        }
    }
    
    var text: String? {
        set {
            searchTextField.text = newValue
            _text = newValue
        }
        get {
            return _text
        }
    }
    
    private var _text: String?
    
    fileprivate var showsCancelButton: Bool = false {
        didSet {
            cancelButton.snp.remakeConstraints { (make) in
                make.height.equalTo(44).priorityHigh()
                make.bottom.equalToSuperview().priorityHigh()
                make.trailing.equalToSuperview().offset(-14).priorityHigh()
                make.width.equalTo(66).priorityHigh()
            }
            if (showsCancelButton){
                searchTextField.snp.remakeConstraints { (make) in
                    make.height.equalTo(32)
                    make.bottom.equalToSuperview().offset(-6)
                    make.leading.equalToSuperview().offset(14)
                    make.trailing.equalToSuperview().offset(-14-66-8)
                }
                cancelButton.alpha = 1
            }else{
                searchTextField.snp.remakeConstraints { (make) in
                    make.height.equalTo(32)
                    make.bottom.equalToSuperview().offset(-6)
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(-28).priorityHigh()
                }
                cancelButton.alpha = 0
            }
        }
    }
    
    fileprivate func clearText() {
        searchTextField.text = nil
        textDidChange!(nil)
    }
    
    fileprivate var shouldBeginEditing: (()->Bool)?
    fileprivate var textDidChange:((String?)->())?
    fileprivate var cancelButtonClicked: (()->())?
    fileprivate var searchButtonClicked: (()->())?
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var contentView = {()->UIView in
        let v = UIView()
        return v
    }()
    
    private var searchTextField = {()->UITextField in
        let v                 = UITextField()
        v.backgroundColor     = UIColor.init(white: 0, alpha: 1/7.0)
        v.layer.masksToBounds = true
        v.layer.cornerRadius  = 4
        v.returnKeyType       = .search
        return v
    }()
    
    private var cancelButton = {()->UIButton in
        let v = UIButton()
        v.setTitle("Cancel", for: .normal)
        v.setTitleColor(UIColor.black, for: .normal)
        return v
    }()
    
    override func becomeFirstResponder() -> Bool {
        return searchTextField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return searchTextField.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func build() {
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        self.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        searchTextField.delegate = self
        contentView.backgroundColor = UIColor.white
        cancelButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        contentView.addSubview(cancelButton)
        contentView.addSubview(searchTextField)
        self.addSubview(contentView)
        contentView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.showsCancelButton = false
        self.placeholder = "Search"
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChange(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing!()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonClicked!()
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func didChange(_ notification: Notification) {
        if !searchTextField.isEqual(notification.object) {
            return
        }
        textDidChange!(searchTextField.text)
    }
    
    @objc private func cancel() {
        cancelButtonClicked!()
    }
    
}

fileprivate class SearchTransition: SNCConvenientTransition {
    
    private weak var searchBar: SearchBar!
    private weak var targetNavigationController: StackNavigationController!
    private weak var searchViewController: SearchViewController!
    private var shouldHiddenNavigationBarOfPrevViewController: Bool!
    
    convenience init(searchBar: SearchBar, searchViewController: SearchViewController, targetNavigationController: StackNavigationController) {
        self.init()
        self.searchBar                  = searchBar
        self.searchViewController       = searchViewController
        self.targetNavigationController = targetNavigationController
        self.searchBar.shouldBeginEditing = { [weak self] ()->Bool in
            guard let self = self else {
                return false
            }
            self.targetNavigationController.pushViewController(self.searchViewController, animated: true)
            return false
        }
        self.shouldHiddenNavigationBarOfPrevViewController = false
        self.transparent = true
        self.animationOptions = .curveLinear
    }
    
    override func willPush() {
        // hide search bar controller 's navigation bar
        viewController!.setNavigationBarHidden(true, animated: false)
        
        if let vc = self.fromViewController {
            self.shouldHiddenNavigationBarOfPrevViewController = !vc.isNavigationBarHidden
        }
        
        view.snc_addTransparentBackground().alpha = 0
        
        toView.alpha = 0
        
        searchBar.showsCancelButton = false
        
        toView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 44, 0)

        self.moveContentViewToContainerViewWithPush()
    }
    
    override func pushing() {
        view.snc_addTransparentBackground().alpha = 2/3.0
        
        if (shouldHiddenNavigationBarOfPrevViewController){
            self.fromViewController!.setNavigationBarHidden(true, animated:true)
        }
        
        toView.alpha = 1
        
        searchBar.showsCancelButton = true
        
        self.moveContentViewToContainerViewWithPop()
        
        toView.layer.transform = CATransform3DIdentity
    }
    
    override func didPush() {
        if !transparent {
            view.snc_removeTransparentBackground()
        }
        searchBar.shouldBeginEditing = {()->Bool in
            return true
        }
        
        let _ = searchBar.becomeFirstResponder()
        
        self.moveContentViewToSearchView()
    }
    
    override func didCancelPush() {
        
        view.snc_removeTransparentBackground()
        
        if (shouldHiddenNavigationBarOfPrevViewController){
            self.fromViewController!.setNavigationBarHidden(false, animated:false)
        }
        
        searchBar.showsCancelButton = false
        
        toView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 44, 0)

        self.moveContentViewToSearchBar()
    }
    
    override func willPop() {
        view.snc_addTransparentBackground().alpha = 2/3.0
        
        fromView.alpha = 1
        
        searchBar.showsCancelButton = true
        
        fromView.layer.transform = CATransform3DIdentity

        self.moveContentViewToContainerViewWithPop()
        
    }
    
    override func poping() {
        view.snc_addTransparentBackground().alpha = 0
        
        fromView.alpha = 0
        
        searchBar.showsCancelButton = false
        
        if (shouldHiddenNavigationBarOfPrevViewController){
            self.toViewController!.setNavigationBarHidden(false, animated:true)
        }
        
        fromView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 44, 0)

        self.moveContentViewToContainerViewWithPush()
    }
    
    override func didPop() {
        view.snc_removeTransparentBackground()
        
        searchBar.shouldBeginEditing = { [weak self] ()->Bool in
            guard let self = self else {
                return false
            }
            self.targetNavigationController.pushViewController(self.searchViewController, animated: true)
            return false
        }
        
        searchBar.clearText()
        
        let _ = searchBar.resignFirstResponder()
        
        self.moveContentViewToSearchBar()
    }
    
    override func didCancelPop() {
        if !transparent {
            view.snc_removeTransparentBackground()
        }else{
            view.snc_addTransparentBackground().alpha = 2/3.0
        }
        
        fromView.alpha = 1
        
        searchBar.showsCancelButton = true
        
        fromView.layer.transform = CATransform3DIdentity
        
        if (shouldHiddenNavigationBarOfPrevViewController){
            self.toViewController!.setNavigationBarHidden(true, animated:false)
        }
        
        self.moveContentViewToSearchView()
    }
    
    private func moveContentViewToSearchBar() {
        let contentView = searchBar.contentView
        searchBar.addSubview(contentView)
        contentView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        searchBar.layoutIfNeeded()
    }
    
    private func moveContentViewToSearchView() {
        let contentView = searchBar.contentView
        let vc = self.viewController!.topViewController!
        vc.view.addSubview(contentView)
        contentView.snp.remakeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(vc.view!.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                make.bottom.equalTo(vc.topLayoutGuide.snp.bottom).offset(44)
            }
        }
        vc.view.layoutIfNeeded()
    }
    
    private func moveContentViewToContainerViewWithPush(){
        let contentView = searchBar.contentView
        containerView.addSubview(contentView)
        contentView.snp.remakeConstraints { (make) in
            let frame = searchBar.convert(searchBar.bounds, to: containerView)
            make.leading.equalToSuperview().offset(frame.minX)
            make.trailing.equalToSuperview().offset(containerView.bounds.width - frame.maxX)
            make.top.equalToSuperview().offset(frame.minY)
            make.height.equalTo(frame.height)
        }
        containerView.layoutIfNeeded()
    }
    
    private func moveContentViewToContainerViewWithPop(){
        let contentView = searchBar.contentView
        containerView.addSubview(contentView)
        contentView.snp.remakeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                make.bottom.equalTo(containerNavigationController!.topLayoutGuide.snp.bottom).offset(44)
            }
        }
        containerView.layoutIfNeeded()
    }
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private(set) lazy var searchBar: SearchBar = {()->SearchBar in
        let v = SearchBar()
        v.cancelButtonClicked = {[weak self] in
            self?.snc_navigationController?.popViewController(animated: true)
        }
        v.searchButtonClicked = {[weak v]()->() in
            let _ = v?.resignFirstResponder()
        }
        v.textDidChange = {[weak self] (text)->() in
            guard let self = self else{
                return
            }
            self.cellModels.removeAll()
            if text == nil || text?.count == 0 {
                self.tableView.reloadData()
                return
            }
            self.cellModels.append({()->CellModel in
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
            self.tableView.reloadData()
        }
        return v
    }()
    
    @available(*, unavailable)
    init() {
        fatalError("init() has not been implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(entryViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        let transition = {()->SearchTransition in
            let v = SearchTransition(searchBar: searchBar, searchViewController: self, targetNavigationController: entryViewController.snc_navigationController!)
            return v
        }()
        snc_transition = transition
    }
    
    lazy var tableView = {()->UITableView in
        let v = UITableView(frame: .zero, style: .plain)
        v.register(Cell.self, forCellReuseIdentifier: "Cell")
        v.backgroundColor = UIColor.clear
        v.delegate = self
        v.dataSource = self
        v.estimatedRowHeight = UITableView.automaticDimension
        v.tableFooterView = UIView()
        return v
    }()
    var cellModels : [CellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                self.automaticallyAdjustsScrollViewInsets = false
                make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(44)
            }
        }
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func nextTitle(seq: Int) -> String {
        return String((Int(self.title ?? "0") ?? 0) + seq, radix: 10)
    }
    
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
