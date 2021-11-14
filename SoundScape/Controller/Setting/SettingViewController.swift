//
//  SettingViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/2.
//

import UIKit
import Lottie

class SettingViewController: UIViewController {

    var settingsOptions = ["Privacy Policy", "Delete Account", "About", "Log Out"]
    
    let signInHelper = SignInHelper.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        addLottie()
        setBackgroundColor()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        AudioPlayerWindow.shared.window?.isHidden = true
        animationView.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        animationView.stop()
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(named: CommonUsage.scBlue)
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.reuseIdentifier)
        return table
    }()
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "lf30_editor_xgoxkd3f")
        animationView.frame = CGRect(x: 0, y: 80, width: CommonUsage.screenWidth, height: CommonUsage.screenHeight / 3)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }()
    
    @objc func backToLastPage() {
        self.navigationController?.popViewController(animated: true)
    }

    private func setBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = CommonUsage.Text.settings
        navigationController?.navigationBar.barTintColor = UIColor(named: CommonUsage.scBlue)
        let font = UIFont(name: CommonUsage.fontBungee, size: 28)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,
                                                                   NSAttributedString.Key.foregroundColor: UIColor(named: CommonUsage.scWhite)]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self,action: #selector(backToLastPage))
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: CommonUsage.SFSymbol.back)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: CommonUsage.scWhite)
    }

    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addLottie() {
        view.addSubview(animationView)
    }
    
    private func navigateToSignInPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let signInViewController = storyboard.instantiateViewController(withIdentifier: String(describing: SignInViewController.self)) as? SignInViewController else { return }
        navigationController?.pushViewController(signInViewController, animated: true)
    }

}

extension SettingViewController: UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configCell(content: settingsOptions[indexPath.row])
        return cell
    }
}

extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if indexPath.row == 3 {
            signInHelper.signOutAuth { [weak self] in
                guard let self = self else { return }
                self.navigateToSignInPage()
            }
        }
        
        if indexPath.row == 0 {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let privacyPolicyVC = storyboard.instantiateViewController(withIdentifier: String(describing: PrivacyPolicyViewController.self)) as? PrivacyPolicyViewController else { return }
            
            navigationController?.pushViewController(privacyPolicyVC, animated: true)
            
        }
        
        if indexPath.row == 1 {
            let alert = UIAlertController(title: "Please contact us to delete your account.", message: "astridtingan@gmail.com", preferredStyle: .alert )
            let okButton = UIAlertAction(title: "ok", style: .default)
            
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)

        }
        
    }
    
}
