//
//  SettingViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/2.
//

import UIKit
import Lottie

class SettingViewController: UIViewController {

    var settingsOptions = ["隱私權政策", "使用說明", "關於"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLottie()
        setBackgroundColor()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(named: CommonUsage.scDarkGreen)
        table.dataSource = self
        table.allowsSelection = false
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.reuseIdentifier)
        return table
    }()
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "lf30_editor_xgoxkd3f")
        animationView.frame = CGRect(x: 0, y: CommonUsage.screenHeight / 8, width: 400, height: 400)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }()

    private func setBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scDarkGreen)
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
        animationView.play()
    }

}

extension SettingViewController: UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        cell.configCell(content: settingsOptions[indexPath.row])
        return cell
    }
}