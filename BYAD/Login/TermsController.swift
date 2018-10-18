//
//  TermsController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/22/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit

class TermsController: UIViewController, UIWebViewDelegate {
    
    let webView: UIWebView = {
        let wv = UIWebView()
        return wv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.shouldPresentLoadingView(true)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        
        let safeArea = view.safeAreaLayoutGuide

        view.backgroundColor = .white
        navigationItem.backBarButtonItem?.isEnabled = true
        navigationItem.title = "Terms & Conditions"

        view.addSubview(webView)
        webView.anchor(top: safeArea.topAnchor, left: safeArea.leftAnchor, bottom: view.bottomAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        webView.loadRequest(URLRequest(url: URL(string: "https://garsontech.com/byad-terms-conditions/")!))
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        shouldPresentLoadingView(false)
    }
}
