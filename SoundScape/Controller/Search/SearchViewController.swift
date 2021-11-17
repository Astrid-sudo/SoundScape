//
//  SearchViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit
import Lottie

class SearchViewController: UIViewController {
    
    // MARK: - properties
    
    private let firebaseManager = FirebaseManager.shared
    
    private let remotePlayHelper = RemotePlayHelper.shared
    
    private var selectedCategories = [AudioCategory]()
    
    private var keyWord: String?
    
    private var audioFiles = [SCPost]()
    
    private var resultAudioFiles = [SCPost]() {
        didSet {
            
            if resultAudioFiles.count == 0 {
                noResultImage.isHidden = false
                noResultLabel.isHidden = false
            } else {
                noResultImage.isHidden = true
                noResultLabel.isHidden = true
            }

            tableView.reloadData()
        }
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        fetchDataFromFirebase()
        setViewBackgroundColor()
        setSearchBar()
        setHintLabel()
        setCategoryTitleLabel()
        setCollectionView()
        setSearchResultTitleLabel()
        setTableView()
        setNoResultImage()
        setNoResultLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - method
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAllAudioFile),
                                               name: .allAudioPostChange ,
                                               object: nil)
    }
    
    @objc func updateAllAudioFile() {
        fetchDataFromFirebase()
    }

    private func fetchDataFromFirebase() {
        audioFiles = AudioPostManager.shared.filteredAudioFiles
    }
    
    private func search() {
        
        guard let keyword = self.keyWord else { return }
        let titleResult = audioFiles.filter({$0.title.lowercased().contains(keyword.lowercased())})
        let authorResult = audioFiles.filter({$0.authorName.lowercased().contains(keyword.lowercased())})
        let contentResult = audioFiles.filter({$0.content.lowercased().contains(keyword.lowercased())})
        let allResult = titleResult + authorResult + contentResult
        let resultSet = Set(allResult)
        let resultArray = Array(resultSet)
 
        if selectedCategories.count == 0 {
            
            resultAudioFiles = resultArray
       
        } else {
            
            var filteredResult = [SCPost]()
            
            for result in resultArray {
                for category in selectedCategories {
                    if result.category == category.rawValue {
                        filteredResult.append(result)
                    }
                }
            }
            
            resultAudioFiles = filteredResult
            
        }
    }
    
    // MARK: - UI Properties
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "74194-sleepy-sleep")
        animationView.frame = CGRect(x: 0, y: 100, width: 100, height: 100)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }()
    
    private lazy var searchBar: UISearchBar = {
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
    
    private lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 18)
        label.textAlignment = .left
        label.text = CommonUsage.Text.category
        return label
    }()
    
    private lazy var searchResultTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 18)
        label.textAlignment = .left
        label.text = CommonUsage.Text.searchResult
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 95, height: 30)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.bounces = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(SearchCollectionViewCell.self,
                                forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        table.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
        return table
    }()
    
    private lazy var noResultImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = CommonUsage.audioImages[4]
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var noResultLabel: UILabel = {
        let label = UILabel()
        label.text = CommonUsage.Text.noResultTitle
        label.textColor = UIColor(named: CommonUsage.scWhite)
        return label
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = CommonUsage.Text.searchHintLabel
        label.textColor = UIColor(named: CommonUsage.scGray)
        label.font = UIFont(name: CommonUsage.font, size: 12)
        return label
    }()

    // MARK: - UI method
    
    private func setViewBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setSearchBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
    }
    
    private func setHintLabel() {
        view.addSubview(hintLabel)
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hintLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            hintLabel.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor)
        ])
    }
    
    private func setCategoryTitleLabel() {
        view.addSubview(categoryTitleLabel)
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTitleLabel.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 4)
        ])
    }
    
    private func setCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 4),
            collectionView.heightAnchor.constraint(equalToConstant: 50)
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
    
    private func setNoResultImage() {
        view.addSubview(noResultImage)
        noResultImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noResultImage.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            noResultImage.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -40),
            noResultImage.widthAnchor.constraint(equalToConstant: 150),
            noResultImage.heightAnchor.constraint(equalTo: noResultImage.widthAnchor)
        ])
    }
    
    private func setNoResultLabel() {
        view.addSubview(noResultLabel)
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noResultLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            noResultLabel.topAnchor.constraint(equalTo: noResultImage.bottomAnchor, constant: 8)
        ])
    }
    
}

// MARK: - conform to UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        AudioCategory.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell()}
        cell.setContent(content: AudioCategory.allCases[indexPath.item].rawValue)
        return cell
    }
    
}

// MARK: - conform to UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selected = AudioCategory.allCases[indexPath.item]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SearchCollectionViewCell else { return }
        
        if selectedCategories.contains(selected) {
            selectedCategories.removeAll(where: {$0 == selected})
            cell.setLabelColorGreen()
        } else {
            selectedCategories.append(selected)
            cell.setLabelColorRed()
        }
        
        search()
    }
    
}

// MARK: - conform to UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultAudioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? SearchTableViewCell else { return UITableViewCell()}
        let data = resultAudioFiles[indexPath.row]
        cell.selectionStyle = .none
        cell.setContent(title: data.title, author: data.authorName, imageNumber: data.imageNumber)
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath == IndexPath(row: resultAudioFiles.count - 1, section: 0) {
           
            return 140
        
        } else {
           
            return 70
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        AudioPlayerWindow.shared.show()
        
        let title = resultAudioFiles[indexPath.item].title
        let author = resultAudioFiles[indexPath.item].authorName
        let content = resultAudioFiles[indexPath.item].content
        let duration = resultAudioFiles[indexPath.item].duration
        let documentID =  resultAudioFiles[indexPath.item].documentID
        let authorUserID = resultAudioFiles[indexPath.item].authorID
        let audioImageNumber = resultAudioFiles[indexPath.item].imageNumber
        let authorAccountProvider = resultAudioFiles[indexPath.item].authIDProvider
        
        if let remoteURL = resultAudioFiles[indexPath.item].audioURL {
            RemoteAudioManager.shared.downloadRemoteURL(documentID: documentID, remoteURL: remoteURL) { localURL in
                AudioPlayHelper.shared.url = localURL
                AudioPlayHelper.shared.setPlayInfo(title: title,
                                                   author: author,
                                                   content: content,
                                                   duration: duration,
                                                   documentID: documentID,
                                                   authorUserID: authorUserID,
                                                   audioImageNumber: audioImageNumber,
                                                   authorAccountProvider: authorAccountProvider)
            }
        }
    }
    
}

// MARK: - conform to UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        keyWord = searchBar.text
        search()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        keyWord = searchBar.text
        search()
        searchBar.endEditing(true)
        searchBar.text = nil
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}

// MARK: - conform to UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}

