//
//  HomeVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

class HomeVC: UIViewController {
    
    // MARK: - properties

    let firebaseManager = FirebaseManager.shared
    
    var allAudioFiles = [SCPost]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - UI properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.separatorStyle = .singleLine
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        table.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        table.register(HomeTableViewHeader.self, forHeaderFooterViewReuseIdentifier: HomeTableViewHeader.reuseIdentifier)
        return table
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseManager.delegate = self
        firebaseManager.fetchPost()
        firebaseManager.checkPostChange()
        setTableView()
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - config UI method
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - method
}

// MARK: - conform to UITableViewDataSource

extension HomeVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        AudioCategory.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        cell.firebaseData = allAudioFiles
        cell.category = AudioCategory.allCases[indexPath.item].rawValue
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension HomeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeader.reuseIdentifier) as? HomeTableViewHeader else { return UIView()}
        
        headerView.delegate = self
        
        headerView.setContent(content: AudioCategory.allCases[section].rawValue)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
}

extension HomeVC: PostsPassableDelegate {
    
    func passPosts(posts: [SCPost]) {
        
        self.allAudioFiles = posts
    }
    
}

extension HomeVC: PressPassableDelegate {
    
    func goCategoryPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
}
