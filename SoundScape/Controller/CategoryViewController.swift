//
//  CategoryViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit

class CategoryViewController: UIViewController {
    
    // MARK: - properties
    
    var category = "Unique"
    
    var fakeData = [SCPost(documentID: "",
                           authorID: "Santa",
                           authIDProvider: "Google",
                           authorName: "來自北極的聖誕老公公",
                           title: "雪琪天晴朗",
                           content: "聖誕節快到了",
                           category: "Unique",
                           duration: 110),
                    SCPost(documentID: "",
                           authorID: "yyy",
                           authIDProvider: "Google",
                           authorName: "來自南極的企鵝老婆婆",
                           title: "晴朗",
                           content: "哇哈哈",
                           category: "Unique",
                           duration: 110),
                    SCPost(documentID: "",
                           authorID: "mmm",
                           authIDProvider: "Google",
                           authorName: "南極企鵝",
                           title: "我家在哪",
                           content: "了",
                           category: "Unique",
                           duration: 110)]

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
        label.font = UIFont(name: CommonUsage.fontBungee, size: 70)
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
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
        categoryTitleLabel.text = category
        headView.image = UIImage(named: CommonUsage.audioImage2)
    }

}

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fakeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
                tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier) as? CategoryTableViewCell else { return UITableViewCell()}
        let data = fakeData[indexPath.row]
        cell.setContent(title: data.title, author: data.authorName)
        return cell
    }
    
}

extension CategoryViewController: UITableViewDelegate {
    
}
