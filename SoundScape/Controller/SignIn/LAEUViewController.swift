//
//  LAEUViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/18.
//

import UIKit
import WebKit

class LAEUViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebView()
        loadURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - method
    
    private func loadURL() {
        if let url = URL(string: Constant.LAEUURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
     
    // MARK: - UI properties
    
    private lazy var webView: WKWebView = {
        let web = WKWebView()
        web.navigationDelegate = self
        return web
    }()
    
    let webLoadingView = LottieWrapper.shared.createLottieAnimationView(lottieType: .blueStripeLoading,
                                                                        frame: CGRect(x: 0,
                                                                                      y: 0,
                                                                                      width: UIProperties.screenWidth,
                                                                                      height: UIProperties.screenHeight))
}

// MARK: - WKNavigationDelegate

extension LAEUViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        popErrorAlert(title: "Network problem", message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
        view.addSubview(webLoadingView)
        webLoadingView.play()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        webLoadingView.stop()
        webLoadingView.removeFromSuperview()
    }
    
}

// MARK: - UI method

extension LAEUViewController {
    
    private func setWebView() {
        view.addSubview(webView)
        view.sendSubviewToBack(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}
