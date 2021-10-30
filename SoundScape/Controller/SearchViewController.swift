//
//  SearchViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - properties
    
    let firebaseManager = FirebaseManager.shared
    
    var allAudioFiles = [SCPost]()
    
    var resultAudioFiles = [SCPost]()
    
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
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
        setSearchBar()
        setCategoryTitleLabel()
        setCollectionView()
        setSearchResultTitleLabel()
        setTableView()
        
        
        
    }
    
    // MARK: - method
    
    // MARK: - UI Properties
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = UIColor(named: CommonUsage.scLightBlue)
        searchBar.layer.cornerRadius = 10
        searchBar.placeholder = CommonUsage.Text.search
        searchBar.delegate = self
        searchBar.searchTextField.textColor = UIColor(named: CommonUsage.scWhite)
        searchBar.showsCancelButton = true
        return searchBar
    }()
    
    lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.font, size: 18)
        label.textAlignment = .left
        label.text = CommonUsage.Text.category
        return label
    }()
    
    lazy var searchResultTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.font, size: 18)
        label.textAlignment = .left
        label.text = CommonUsage.Text.searchResult
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 90, height: 44)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentifier)

        return collectionView
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        table.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
        return table
    }()
    
    // MARK: - UI method
    
    private func setSearchBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])

    }
    
    private func setCategoryTitleLabel() {
        view.addSubview(categoryTitleLabel)
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTitleLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8)
        ])
    }
    
    private func setCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 4),
            collectionView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setSearchResultTitleLabel() {
        view.addSubview(searchResultTitleLabel)
        searchResultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchResultTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchResultTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchResultTitleLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchResultTitleLabel.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 30)
        ])
    }

}

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        AudioCategory.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell()}
        cell.setContent(content: AudioCategory.allCases[indexPath.item].rawValue)
        return cell
    }
    
}

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //搜尋那個種類
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fakeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier, for: indexPath) as? SearchTableViewCell else { return UITableViewCell()}
        let data = fakeData[indexPath.row]
        cell.setContent(title: data.title, author: data.authorName)
        return cell
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
300
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //搜尋local資料
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //搜尋local資料 清空搜尋bar
        searchBar.text = ""
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}
