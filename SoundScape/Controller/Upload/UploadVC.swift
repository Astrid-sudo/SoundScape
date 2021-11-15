//
//  UploadVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit
import Lottie
import GoogleMaps
import CoreLocation

class UploadVC: UIViewController {
    
    // MARK: - properties
    
    var backFromBigMap = false
    
    let signInmanager = SignInManager.shared
    
    let firebasemanager = FirebaseManager.shared
    
    var selectedFileURL: URL?
    
    var selectedFileDuration: Double?
    
    var currentLocation: CLLocationCoordinate2D?
    
    var defaultLocation = CLLocationCoordinate2DMake(25.034012, 121.563461)
    
    var pinnedLocation: CLLocationCoordinate2D? {
        didSet {
            guard let pinnedLocation = pinnedLocation else { return }
            mapView.camera = GMSCameraPosition.camera(withLatitude: pinnedLocation.latitude,
                                                      longitude: pinnedLocation.longitude, zoom: 15)
            mapMarker.title = titleTextField.text
            mapMarker.position = pinnedLocation
            mapMarker.snippet = signInmanager.currentUserInfoFirebase?.username
            mapMarker.map = mapView
            mapView.selectedMarker = mapMarker
        }
    }
    
    private lazy var myLocation: CLLocationManager = {
        let location = CLLocationManager()
        location.delegate = self
        location.distanceFilter = kCLLocationAccuracyNearestTenMeters
        location.desiredAccuracy = kCLLocationAccuracyBest
        return location
    }()
    
    private var selectedCategoryIndex: IndexPath? {
        didSet {
            
            if let oldValue = oldValue {
                if let cell = collectionView.cellForItem(at: oldValue) as? SearchCollectionViewCell {
                    cell.setLabelColorGreen()
                }
            }
            
            guard let selectedCategoryIndex = selectedCategoryIndex,
                  let cell = collectionView.cellForItem(at: selectedCategoryIndex) as? SearchCollectionViewCell else { return }
            cell.setLabelColorRed()
        }
    }
    
    private var selectedImageIndex: IndexPath? {
        didSet {
            
            if let oldValue = oldValue {
                if let cell = audioImageCollectionView.cellForItem(at: oldValue) as? HomeCollectionViewCell {
                    cell.removeImageBorder()
                }
            }
            
            guard let index = selectedImageIndex,
                  let cell = audioImageCollectionView.cellForItem(at: index) as? HomeCollectionViewCell else { return }
            cell.setImageBorder()
        }
    }
    
    // MARK: - UI properties
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.contentSize = CGSize(width: CommonUsage.screenWidth, height: CommonUsage.screenHeight * 1.5)
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var mapMarker: GMSMarker = {
        var marker = GMSMarker(position: currentLocation ?? defaultLocation)
        marker.icon = GMSMarker.markerImage(with: UIColor(named: CommonUsage.scRed))
        marker.map = mapView
        return marker
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.title
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.description
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.category
        return label
    }()
    
    private  lazy var mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.pinOnMap
        return label
    }()
    
    private  lazy var audioImageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.audioImage
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textColor = .white
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 10
        textField.textAlignment = .left
        textField.backgroundColor = .clear
        textField.delegate = self
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.cornerRadius = 10
        textView.textColor = .white
        textView.font = UIFont(name: CommonUsage.font, size: 15)
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    private lazy var viewUndermap: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(named: CommonUsage.scWhite)?.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        let posision = pinnedLocation ?? currentLocation ?? defaultLocation
        let camera = GMSCameraPosition.camera(withLatitude: posision.latitude,
                                              longitude: posision.longitude, zoom: 15.0)
        mapView.delegate = self
        mapView.camera = camera
        mapView.layer.cornerRadius = 10
        do {
          if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          } else {
            NSLog("Unable to find style.json")
          }
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }

        if backFromBigMap {
            mapView.settings.myLocationButton = false
            mapView.isMyLocationEnabled = false
        } else {
            mapView.settings.myLocationButton = true
            mapView.isMyLocationEnabled = true
        }
        
        return mapView
    }()
    
    private lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        button.setTitle(CommonUsage.Text.upload, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(upload), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "lf30_editor_r2yecdir")
        animationView.frame = CGRect(x: 0, y: 100, width: 400, height: 400)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }()
    
    private lazy var searchPlaceButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        button.setTitle(CommonUsage.Text.searchPlace, for: .normal)
        button.titleLabel?.font = UIFont(name: CommonUsage.font, size: 14)
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.addTarget(self, action: #selector(presentBigMap), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 30)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
    
    private lazy var audioImageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.bounces = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(HomeCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setScrollView()
        setTitleLabel()
        setTitleTextField()
        setDescriptionLabel()
        setDescriptionTextView()
        setCategoryLabel()
        setCategoryCollectionView()
        setAudioImageLabel()
        setImageCollectionView()
        setMapLabel()
        setViewUnderMap()
        setMapView()
        setUploadButton()
        setViewBackgroundColor()
        setSearchPlaceButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let pinnedLocation = pinnedLocation else { return }
        mapView.camera = GMSCameraPosition.camera(withLatitude: pinnedLocation.latitude,
                                                  longitude: pinnedLocation.longitude,
                                                  zoom: 15)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let pinnedLocation = pinnedLocation else { return }
        askUserLocation()
        mapView.camera = GMSCameraPosition.camera(withLatitude: pinnedLocation.latitude,
                                                  longitude: pinnedLocation.longitude,
                                                  zoom: 15)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myLocation.stopUpdatingLocation()
    }
    
    // MARK: - UI method
    
    private func setViewBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backToLastPage))
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: CommonUsage.SFSymbol.back)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: CommonUsage.scWhite)
        navigationItem.title = CommonUsage.Text.upload
    }
    
    private func setScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    private func setTitleLabel() {
        scrollView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8)
        ])
    }
    
    private func setTitleTextField() {
        scrollView.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32)
        ])
    }
    
    private func setDescriptionLabel() {
        scrollView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16)
        ])
    }
    
    private func setDescriptionTextView() {
        scrollView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                                                         constant: 16),
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            descriptionTextView.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32)
        ])
    }
    
    private func setCategoryLabel() {
        scrollView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            categoryLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16)
        ])
    }
    
    private func setCategoryCollectionView() {
        scrollView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth ),
            collectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
            collectionView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setAudioImageLabel() {
        scrollView.addSubview(audioImageLabel)
        audioImageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImageLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                                                     constant: 16),
            audioImageLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16)
        ])
    }
    
    private func setImageCollectionView() {
        scrollView.addSubview(audioImageCollectionView)
        audioImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImageCollectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            audioImageCollectionView.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth),
            audioImageCollectionView.topAnchor.constraint(equalTo: audioImageLabel.bottomAnchor, constant: 8),
            audioImageCollectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setMapLabel() {
        scrollView.addSubview(mapLabel)
        mapLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            mapLabel.topAnchor.constraint(equalTo: audioImageCollectionView.bottomAnchor, constant: 8)
        ])
    }
    
    private func setViewUnderMap() {
        scrollView.addSubview(viewUndermap)
        viewUndermap.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewUndermap.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            viewUndermap.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32),
            viewUndermap.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 16),
            viewUndermap.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func setMapView() {
        viewUndermap.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: viewUndermap.leadingAnchor),
            mapView.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32),
            mapView.topAnchor.constraint(equalTo: viewUndermap.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: viewUndermap.bottomAnchor)
        ])
    }
    
    private func setUploadButton() {
        scrollView.addSubview(uploadButton)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadButton.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            uploadButton.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32),
            uploadButton.topAnchor.constraint(equalTo: viewUndermap.bottomAnchor, constant: 8),
            uploadButton.heightAnchor.constraint(equalToConstant: 50),
            uploadButton.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -4)
        ])
    }
    
    private func setSearchPlaceButton() {
        scrollView.addSubview(searchPlaceButton)
        searchPlaceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchPlaceButton.trailingAnchor.constraint(equalTo: uploadButton.trailingAnchor),
            searchPlaceButton.centerYAnchor.constraint(equalTo: mapLabel.centerYAnchor),
            searchPlaceButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - method
    
    private func addLottie() {
        view.addSubview(animationView)
        animationView.play()
    }
    
    private func backToHome() {
        navigationController?.popToRootViewController(animated: true)
        animationView.removeFromSuperview()
        guard let scTabBarController = UIApplication.shared.windows.filter({$0.rootViewController is SCTabBarController}).first?.rootViewController as? SCTabBarController else { return }
        scTabBarController.selectedIndex = 0
    }
    
    private func popFillAlert() {
        let alert = UIAlertController(title: "請填滿所有欄位", message: "登入後即可PO聲", preferredStyle: .alert )
        let okButton = UIAlertAction(title: "是！", style: .default)
        
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    private func askUserLocation() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            myLocation.requestWhenInUseAuthorization() // First time lanch app need to get authorize from user
            fallthrough
            
        case .authorizedWhenInUse:
            myLocation.startUpdatingLocation() // Start location
            
        case .denied:
            let alertController = UIAlertController(title: "定位權限已關閉",
                                                    message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    // MARK: - action
    
    @objc func backToLastPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func upload() {
        
        addLottie()
        
        guard let title = titleTextField.text,
              let content = descriptionTextView.text,
              let item = selectedCategoryIndex?.item,
        let audioImageNumber = selectedImageIndex?.item else {
                  popFillAlert()
                  return
              }
        
        var post = SCPost(documentID: "",
                          authorID: signInmanager.currentUserInfoFirebase?.userID ?? "No signIn",
                          authIDProvider: signInmanager.currentUserInfoFirebase?.provider ?? "No signIn",
                          authorName: signInmanager.currentUserInfoFirebase?.username ?? "No signIn",
                          title: title, content: content,
                          createdTime: nil, lastEditedTime: nil,
                          audioURL: nil,
                          imageNumber: audioImageNumber,
                          category: AudioCategory.allCases[item].rawValue,
                          audioLocation: clLocationToGepPoint(cl: pinnedLocation),
                          duration: 0.0)
        
        if let selectedFileDuration = selectedFileDuration {
            post.duration = selectedFileDuration
        }
        
        if let selectedFileURL = selectedFileURL {
            firebasemanager.upload(localURL: selectedFileURL, post: post, completion: backToHome)
        }
    }
    
    @objc func presentBigMap() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let audioMapVC = storyboard.instantiateViewController(withIdentifier: String(describing: AudioMapViewController.self)) as? AudioMapViewController else { return }
        
        audioMapVC.audioMapType = .pinOnMap
        
        audioMapVC.audioTitle = titleTextField.text
        
        audioMapVC.delegate = self
        
        navigationController?.pushViewController(audioMapVC, animated: true)
        
    }
    
}

// MARK: - conform to CLLocationManagerDelegate

extension UploadVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let updatedLocation: CLLocation = locations[0] as CLLocation
        print("\(updatedLocation.coordinate.latitude)")
        print(", \(updatedLocation.coordinate.longitude)")
        
        currentLocation = CLLocationCoordinate2D(latitude: updatedLocation.coordinate.latitude,
                                                 longitude: updatedLocation.coordinate.longitude)
        
        guard let currentLocation = currentLocation else { return }
        
        if backFromBigMap == false {
            mapView.camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude,
                                                      longitude: currentLocation.longitude,
                                                      zoom: 15)
        }
    }
    
}

// MARK: - conform to GMSMapViewDelegate

extension UploadVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        pinnedLocation = coordinate
    }
    
}

// MARK: - conform to UITextFieldDelegate

extension UploadVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        mapMarker.title = titleTextField.text
        mapMarker.snippet = signInmanager.currentUserInfoFirebase?.username
        mapView.selectedMarker = mapMarker
    }
    
}

// MARK: - conform to LocationCoordinatePassableDelegate

extension UploadVC: LocationCoordinatePassableDelegate {
    
    func displayPinOnSmallMap(locationFromBigMap: CLLocationCoordinate2D?) {
        pinnedLocation = locationFromBigMap
        mapView.isMyLocationEnabled = false
        backFromBigMap = true
    }
    
}

// MARK: - conform to UICollectionViewDataSource

extension UploadVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionView {
            return  AudioCategory.allCases.count
        }
        
        if collectionView == audioImageCollectionView {
            return CommonUsage.audioImages.count
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier,
                                                                for: indexPath) as? SearchCollectionViewCell else { return UICollectionViewCell()}
            cell.setContent(content: AudioCategory.allCases[indexPath.item].rawValue)
            if indexPath == selectedCategoryIndex {
                cell.setLabelColorRed()
            } else {
                cell.setLabelColorGreen()
            }
            return cell
        }
        
        if collectionView == audioImageCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.reuseIdentifier,
                                                                for: indexPath) as? HomeCollectionViewCell else { return UICollectionViewCell() }
            cell.setCellImage(image: CommonUsage.audioImages[indexPath.item])
            
            if indexPath == selectedImageIndex {
                cell.setImageBorder()
            } else {
                cell.removeImageBorder()
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}

// MARK: - conform to UICollectionViewDelegate

extension UploadVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            
            if let selectedCategoryIndex = selectedCategoryIndex {
                collectionView.deselectItem(at: selectedCategoryIndex, animated: true)
            }
            selectedCategoryIndex = indexPath
        }
        
        if collectionView == audioImageCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? HomeCollectionViewCell else { return }
            selectedImageIndex = indexPath
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SearchCollectionViewCell else { return }
            cell.setLabelColorGreen()
        }
        
        if collectionView == audioImageCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? HomeCollectionViewCell else { return }
            cell.removeImageBorder()
        }
    }
    
}

// MARK: - conform to UICollectionViewDelegateFlowLayout

extension UploadVC: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}

