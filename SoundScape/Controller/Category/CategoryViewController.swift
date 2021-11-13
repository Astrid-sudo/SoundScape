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
    
    private var profileSection: ProfilePageSection?
    
    private var data = [SCPost]()
    
    // MARK: - UI properties
    
    private lazy var headView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        //        imageView.applyBlurEffect()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scLightBlue)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: CommonUsage.fontBungee, size: 40)
        label.numberOfLines = 0
        
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
        
        setViewBackgroundColor()
        setHeadView()
        
        if category != nil {
            setCategoryTitleLabel()
        } else {
            setProfileTitleLabel()
        }
        
        setTableView()
        setHeadViewTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - method
    
    func config(category: AudioCategory, data: [SCPost]) {
        self.category = category
        self.data = data
    }
    
    func config(profileSection: ProfilePageSection, data: [SCPost]) {
        self.profileSection = profileSection
        self.data = data
    }
    
    // MARK: - config UI method
    
    private func setViewBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setHeadView() {
        view.addSubview(headView)
        headView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headView.topAnchor.constraint(equalTo: view.topAnchor),
            headView.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 3.5)
        ])
    }
    
    private func setCategoryTitleLabel() {
        view.addSubview(categoryTitleLabel)
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(equalTo: headView.leadingAnchor, constant: 16),
            categoryTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4)
        ])
    }
    
    private func setProfileTitleLabel() {
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
            tableView.topAnchor.constraint(equalTo: headView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setHeadViewTitle() {
        
        headView.image = UIImage(named: CommonUsage.audioImage2)
        
        if let category = category {
            categoryTitleLabel.text = category.rawValue
            
            switch category {
            case .nature:
                headView.image = CommonUsage.audioImages[8]
                
            case .meaningful:
                headView.image = CommonUsage.audioImages[6]
                
            case .unique:
                headView.image = CommonUsage.audioImages[3]
                
            case .city:
                headView.image = CommonUsage.audioImages[9]
                
            case .animal:
                headView.image = CommonUsage.audioImages[1]
                
            case .other:
                headView.image = CommonUsage.audioImages[11]
                
            }
            
        }
        
        if let profileSection = profileSection {
            categoryTitleLabel.text = profileSection.rawValue
            categoryTitleLabel.textColor = UIColor(named: CommonUsage.scWhite)
            headView.image = CommonUsage.audioImages[12]
        }
        
        
        
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
        cell.setContent(title: data.title, author: data.authorName, audioImageNumber: data.imageNumber)
        cell.selectionStyle = .none
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        AudioPlayerWindow.shared.show()
        
        let title = data[indexPath.item].title
        let author = data[indexPath.item].authorName
        let content = data[indexPath.item].content
        let duration = data[indexPath.item].duration
        let documentID = data[indexPath.item].documentID
        let authorUserID = data[indexPath.item].authorID
        let audioImageNumber = data[indexPath.item].imageNumber
        let authorAccountProvider = data[indexPath.item].authIDProvider
        
        remotePlayHelper.url = data[indexPath.item].audioURL
        
        remotePlayHelper.setPlayInfo(title: title,
                                     author: author,
                                     content: content,
                                     duration: duration,
                                     documentID: documentID,
                                     authorUserID: authorUserID,
                                     audioImageNumber: audioImageNumber,
                                     authorAccountProvider: authorAccountProvider)
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == data.count - 1 {
            return 180
        } else {
            return 100
        }
    }
    
}
