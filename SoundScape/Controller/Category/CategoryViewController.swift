//
//  CategoryViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit

class CategoryViewController: UIViewController {
    
    // MARK: - properties
    
    private let remotePlayHelper = RemotePlayHelper.shared
    
    private var category: AudioCategory?
    
    private var data = [SCPost]()

    // MARK: - UI properties
    
    private lazy var headView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .redraw
        imageView.applyBlurEffect()
        return imageView
    }()
    
    private lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: CommonUsage.fontBungee, size: 40)
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = UIColor(named: CommonUsage.scBlue)
        table.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        return table
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
        setHeadView()
        setCategoryTitleLabel()
        setTableView()
        setHeadViewTitle()
    }
    
    // MARK: - method
    
    func config(category: AudioCategory, data: [SCPost]) {
        self.category = category
        self.data = data
    }
    
    // MARK: - config UI method
    
    private func setHeadView() {
        view.addSubview(headView)
        headView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headView.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 4)
        ])
    }
    
    private func setCategoryTitleLabel() {
        view.addSubview(categoryTitleLabel)
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryTitleLabel.centerXAnchor.constraint(equalTo: headView.centerXAnchor),
            categoryTitleLabel.centerYAnchor.constraint(equalTo: headView.centerYAnchor)
        ])
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: headView.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setHeadViewTitle() {
        categoryTitleLabel.text = category?.rawValue
        headView.image = UIImage(named: CommonUsage.audioImage2)
    }

}

// MARK: - conform to UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
                tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier) as? CategoryTableViewCell else { return UITableViewCell()}
        let data = data[indexPath.row]
        cell.setContent(title: data.title, author: data.authorName)
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let title = data[indexPath.item].title
        let author = data[indexPath.item].authorName
        let content = data[indexPath.item].content
        let duration = data[indexPath.item].duration
        let documentID = data[indexPath.item].documentID
        let authorUserID = data[indexPath.item].authorID
        let authorAccountProvider = data[indexPath.item].authIDProvider

        remotePlayHelper.url = data[indexPath.item].audioURL
        remotePlayHelper.setPlayInfo(title: title, author: author, content: content, duration: duration, documentID:documentID, authorUserID: authorUserID, authorAccountProvider:authorAccountProvider)
        AudioPlayerWindow.shared.show()

    }
}
