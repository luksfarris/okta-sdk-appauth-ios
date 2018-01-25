//
//  WKWebViewController.swift
//  Okta_Example
//
//  Created by Lucas Farris on 25/01/2018.
//  Copyright © 2018 Okta. All rights reserved.
//

import UIKit
import WebKit

open class WKWebViewController : UIViewController, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @objc open var url:URL?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        
        open()
    }
    
    open func open() {
        if let requestUrl = url {
            let request = URLRequest.init(url: requestUrl)
            webView.load(request)
        }
    }
    
}
