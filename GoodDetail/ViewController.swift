//
//  ViewController.swift
//  GoodDetail
//
//  Created by 罗伟 on 2017/2/6.
//  Copyright © 2017年 罗伟. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var webView: UIWebView?
    var activity: UIActivityIndicatorView?
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let maxContentOfSetY: CGFloat = 80
    var webHeaderView: UILabel?
    var isLoadedWeb = false
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        self.initWebView()
        self.initWebHeaderView()
        self.initActivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private method
    
    func initWebView() {
        let webView = UIWebView.init(frame: CGRect(x: 0, y: self.tableView.frame.maxY, width: self.view.frame.width, height: self.view.frame.height))
        webView.delegate = self
        webView.scrollView.delegate = self
        webView.backgroundColor = UIColor.white
        self.view.addSubview(webView)
        self.webView = webView
    }
    
    func initWebHeaderView() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
        label.textAlignment = .center
        label.text = "上拉，返回宝贝详情"
        label.font = UIFont.systemFont(ofSize: 13)
        label.alpha = 0
        self.webView?.addSubview(label)
        self.webHeaderView = label
        //label.bringSubview(toFront: self.webView!)
    }
    
    func initActivity() {
        let activity = UIActivityIndicatorView()
        activity.center = CGPoint(x: screenWidth/2, y: (screenHeight - 64)/2)
        activity.isHidden = true
        activity.activityIndicatorViewStyle = .gray
        self.webView?.addSubview(activity)
        self.activity = activity
    }
    
    func goToWebDetail() {
        UIView.animate(withDuration: 0.3, animations: {
            self.webView?.frame = CGRect(x: 0, y: 64, width: self.screenWidth, height: self.screenHeight)
            self.tableView.frame = CGRect(x: 0, y: -self.screenHeight, width: self.screenWidth, height: self.screenHeight)
            
        }) { (finished) in
            guard !self.isLoadedWeb else {
                return
            }
            let request = URLRequest(url: URL(string: "https://www.apple.com/cn/")!)
            self.webView?.loadRequest(request)
            self.isLoadedWeb = true
        }
    }
    
    func backToTableDetail() {
        UIView.animate(withDuration: 0.3, animations: {
            self.webView?.frame = CGRect(x: 0, y: self.screenHeight, width: self.screenWidth, height: self.screenHeight)
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        }, completion: nil)
    }
    
    func handleWebHeaderViewAnimation(_ offSetY: CGFloat) {
        self.webHeaderView?.alpha = -offSetY/maxContentOfSetY
        self.webHeaderView?.center = CGPoint(x: screenWidth/2, y: -offSetY/2)
        
        if -offSetY > maxContentOfSetY {
            self.webHeaderView?.text = "释放，返回宝贝详情"
        } else {
            self.webHeaderView?.text = "下拉，返回宝贝详情"
        }
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TestTableViewCell", for: indexPath) as! TestTableViewCell
        cell.textLabel?.text = "这是第\(indexPath.row)行"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offSetY = scrollView.contentOffset.y
        let beyondOffSetY = scrollView.contentSize.height - screenHeight
        
        if scrollView.isMember(of: UITableView.self) {
            if offSetY - beyondOffSetY >= self.maxContentOfSetY {
                self.goToWebDetail()
            }
        } else {
            if offSetY <= -self.maxContentOfSetY, offSetY < 0 {
                self.backToTableDetail()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isMember(of: UITableView.self) {
            self.handleWebHeaderViewAnimation(scrollView.contentOffset.y)
        }
    }
    
    // MARK: - Webview delegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        self.activity?.isHidden = false
        self.activity?.startAnimating()
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activity?.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
       self.activity?.stopAnimating()
    }
}

