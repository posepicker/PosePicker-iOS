//
//  MypageWebViewController.swift
//  posepicker
//
//  Created by 박경준 on 1/6/24.
//

import UIKit
import WebKit

class MypageWebViewController: BaseViewController {
    
    // MARK: - Subviews
    private var webView: WKWebView!
    
    private let activityView = UIActivityIndicatorView(style: .large)
        .then {
            $0.startAnimating()
            $0.color = .mainViolet
        }
    
    // MARK: - Properties
    var urlString: String
    var pageTitle: String
    
    // MARK: - Initialization
    init(urlString: String, pageTitle: String) {
        self.urlString = urlString
        self.pageTitle = pageTitle
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func configUI() {
        webView.navigationDelegate = self
        webView.backgroundColor = .bgWhite
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        view.backgroundColor = .bgWhite
        
        let backButton = UIBarButtonItem(image: ImageLiteral.imgArrowBack24.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        self.title = pageTitle
    }
    
    override func render() {
        webView = WKWebView()
        
        self.view.addSubViews([webView, activityView])
        
        webView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Objc Functions
    @objc
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

extension MypageWebViewController: WKNavigationDelegate { 
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityView.stopAnimating()
    }
}
