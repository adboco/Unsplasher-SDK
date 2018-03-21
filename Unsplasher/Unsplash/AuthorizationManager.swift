//
//  AuthManager.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 26/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation

/// It manages authorization process through a custom view controller
final class AuthorizationManager {
    
    /// Request authorization to the user by presenting a view controller with a webview to an authorization url
    ///
    /// - Parameters:
    ///   - controller: Source view controller
    ///   - url: Authorization url
    ///   - callbackURLScheme: Callback url scheme
    ///   - completion: Completion handler
    static func authorize(from controller: UIViewController, url: URL?, callbackURLScheme: String?, completion: @escaping (AuthorizationResult) -> Void) {
        guard let authURL = url, let scheme = callbackURLScheme else {
            completion(.failure(UnsplashError.authorizationError))
            return
        }
        let authController = UnsplashAuthViewController(url: authURL, callbackURLScheme: scheme, completion: completion)
        let navController = UINavigationController(rootViewController: authController)
        
        controller.present(navController, animated: true, completion: nil)
    }
    
}

/// View controller for Unsplash Authorization
final class UnsplashAuthViewController: UIViewController {
    
    /// Authorization url
    var authURL: URL
    
    /// Callback url
    var callbackURLScheme: String
    
    /// Completion handler
    var completionHandler: (AuthorizationResult) -> Void
    
    let webView = UIWebView()
    
    init(url: URL, callbackURLScheme: String, completion: @escaping (AuthorizationResult) -> Void) {
        self.authURL = url
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = completion
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(sender:)))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(sender:)))
        
        self.navigationItem.title = "Unsplash"
        self.navigationItem.leftBarButtonItem = cancel
        self.navigationItem.rightBarButtonItem = refresh
        
        webView.frame = self.view.frame
        webView.backgroundColor = UIColor.white
        webView.delegate = self
        
        self.view.addSubview(webView)
        
        let margins = self.view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            webView.topAnchor.constraint(equalTo: margins.topAnchor),
            webView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
        
        let urlRequest = URLRequest(url: authURL)
        webView.loadRequest(urlRequest)
    }
    
    @objc func cancel(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            self.completionHandler(.failure(UnsplashError.cancelAuthenticationError))
        })
    }
    
    @objc func refresh(sender: UIBarButtonItem) {
        let urlRequest = URLRequest(url: authURL)
        webView.loadRequest(urlRequest)
    }
    
}

extension UnsplashAuthViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let urlString = request.url?.absoluteString, urlString.starts(with: callbackURLScheme) else {
            return true
        }
        guard let code = URLComponents(string: urlString)?.queryItems?.first(where: { $0.name == "code" })?.value else {
            self.dismiss(animated: true, completion: {
                self.completionHandler(.failure(UnsplashError.authorizationError))
            })
            return true
        }
        self.dismiss(animated: true, completion: {
            self.completionHandler(.success(code))
        })
        return false
    }
    
}
