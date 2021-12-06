//
//  UploadViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit
import GoogleMaps
import CoreLocation

class UploadViewController: UIViewController {
    
    // MARK: - properties
    
    var backFromBigMap = false
    
    let loggedInUserManager = LoggedInUserManager.shared
    
    let firebasemanager = FirebaseManager.shared
    
    var selectedFileURL: URL?
    
    var selectedFileDuration: Double?
    
    var currentLocation: CLLocationCoordinate2D?
    
    var defaultLocation = CLLocationCoordinate2DMake(23.97565, 120.9738819)
    
    var pinnedLocation: CLLocationCoordinate2D? {
        didSet {
            pinMarkerOnMap()
        }
    }
    
    lazy var myLocation: CLLocationManager = {
        let location = CLLocationManager()
        location.delegate = self
        location.distanceFilter = kCLLocationAccuracyNearestTenMeters
        location.desiredAccuracy = kCLLocationAccuracyBest
        return location
    }()
    
    var selectedCategoryIndex: IndexPath? {
        didSet {
            
            if let oldValue = oldValue {
                if let cell = collectionView.cellForItem(at: oldValue) as? SearchCollectionViewCell {
                    cell.setLabelColorLightBlue()
                }
            }
            // swiftlint:disable line_length
            guard let selectedCategoryIndex = selectedCategoryIndex,
                  let cell = collectionView.cellForItem(at: selectedCategoryIndex) as? SearchCollectionViewCell else { return }
            // swiftlint:enable line_length
            cell.setLabelColorSupLightBlue()
        }
    }
    
    var selectedImageIndex: IndexPath? {
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
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askUserLocation()
        configLayout()
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
        mapView.camera = GMSCameraPosition.camera(withLatitude: pinnedLocation.latitude,
                                                  longitude: pinnedLocation.longitude,
                                                  zoom: 15)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myLocation.stopUpdatingLocation()
    }
    
    // MARK: - method
    
    private func backToHome() {
        navigationController?.popToRootViewController(animated: true)
        animationView.removeFromSuperview()
        SPAlertWrapper.shared.presentSPAlert(title: "Post added!", message: nil, preset: .done, completion: nil)
        // swiftlint:disable line_length
        guard let scTabBarController = UIApplication.shared.windows.filter({$0.rootViewController is SCTabBarController}).first?.rootViewController as? SCTabBarController else { return }
        scTabBarController.selectedIndex = 0
    }
    
    private func popFillAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        let okButton = UIAlertAction(title: "OK", style: .default)
        
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
            let alertController = UIAlertController(title: "Allow SoundScape_ to access your location if you wish to pin marker from your current location.",
                                                    message: "Settings > SoundScape_ > Allow access location",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        default:
            break
        }
    }
    // swiftlint:enable line_length
    
    private func pinMarkerOnMap() {
        guard let pinnedLocation = pinnedLocation else { return }
        mapView.camera = GMSCameraPosition.camera(withLatitude: pinnedLocation.latitude,
                                                  longitude: pinnedLocation.longitude, zoom: 15)
        mapMarker.title = titleTextField.text
        mapMarker.position = pinnedLocation
        mapMarker.snippet = loggedInUserManager.currentUserInfoFirebase?.username
        mapMarker.map = mapView
        mapView.selectedMarker = mapMarker
    }
    
    // MARK: - action
    
    @objc func backToLastPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func upload() {
        
        guard let title = titleTextField.text,
              title.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                  popFillAlert(title: "Please fill in Title field.", message: nil)
                  return
              }
        
        guard  let content = descriptionTextView.text,
               content.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                   popFillAlert(title: "Please fill in Description field.", message: nil)
                   return
               }
        
        guard let item = selectedCategoryIndex?.item else {
            popFillAlert(title: "Please tap one Category.", message: nil)
            return
        }
        
        guard let audioImageNumber = selectedImageIndex?.item else {
            popFillAlert(title: "Please choose one cover image.", message: nil)
            return
        }
        
        var post = SCPost(documentID: "",
                          authorID: loggedInUserManager.currentUserInfoFirebase?.userID ?? "No signIn",
                          authIDProvider: loggedInUserManager.currentUserInfoFirebase?.provider ?? "No signIn",
                          authorName: loggedInUserManager.currentUserInfoFirebase?.username ?? "No signIn",
                          title: title, content: content,
                          createdTime: nil, lastEditedTime: nil,
                          audioURL: nil,
                          imageNumber: audioImageNumber,
                          category: AudioCategory.allCases[item].rawValue,
                          audioLocation: clLocationToGepPoint(cl: pinnedLocation),
                          duration: 0.0)
        
        addLottie()
        
        if let selectedFileDuration = selectedFileDuration {
            post.duration = selectedFileDuration
        }
        
        if let selectedFileURL = selectedFileURL {
            firebasemanager.upload(localURL: selectedFileURL,
                                   post: post,
                                   completion: backToHome) { [weak self] errorMessage in
                guard let self = self else { return }
                self.animationView.stop()
                self.animationView.removeFromSuperview()
                // swiftlint:disable line_length
                self.popErrorAlert(title: "Failed to upload audio. Please terminate SoundScape_ and try again.", message: errorMessage)
                // swiftlint:enable line_length
            }
        }
    }
    
    @objc func presentBigMap() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable line_length
        guard let audioMapVC = storyboard.instantiateViewController(withIdentifier: AudioMapViewController.reuseIdentifier) as? AudioMapViewController else { return }
        // swiftlint:enable line_length
        
        audioMapVC.audioMapType = .pinOnMap
        
        audioMapVC.audioTitle = titleTextField.text
        
        audioMapVC.delegate = self
        
        navigationController?.pushViewController(audioMapVC, animated: true)
        
    }
    
    // MARK: - UI properties
    
    lazy var mapNoticeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scGray)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: Constant.font, size: 12)
        label.text = Constant.Text.pinOnMapHint
        return label
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.contentSize = CGSize(width: UIProperties.screenWidth, height: UIProperties.screenHeight * 1.5)
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    lazy var mapMarker: GMSMarker = {
        var marker = GMSMarker(position: currentLocation ?? defaultLocation)
        marker.icon = GMSMarker.markerImage(with: UIColor(named: Constant.scRed))
        marker.map = mapView
        return marker
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: Constant.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = Constant.Text.title
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: Constant.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = Constant.Text.description
        return label
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: Constant.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = Constant.Text.category
        return label
    }()
    
    lazy var mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: Constant.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = Constant.Text.pinOnMap
        return label
    }()
    
    lazy var audioImageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: Constant.fontSemibold, size: 15)
        label.textAlignment = .left
        label.text = Constant.Text.audioImage
        return label
    }()
    
    lazy var titleTextField: UITextField = {
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
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.cornerRadius = 10
        textView.textColor = .white
        textView.font = UIFont(name: Constant.font, size: 15)
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    lazy var viewUndermap: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(named: Constant.scWhite)?.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var mapView: GMSMapView = {
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
    
    lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: Constant.scLightBlue)
        button.setTitle(Constant.Text.upload, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(upload), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    let animationView = LottieWrapper.shared.createLottieAnimationView(lottieType: .greyStripeLoading,
                                                                       frame: CGRect(x: 0,
                                                                                     y: 100,
                                                                                     width: 400,
                                                                                     height: 400))
    
    lazy var searchPlaceButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: Constant.scLightBlue)
        button.setTitle(Constant.Text.searchPlace, for: .normal)
        button.titleLabel?.font = UIFont(name: Constant.font, size: 14)
        button.setTitleColor(UIColor(named: Constant.scWhite), for: .normal)
        button.addTarget(self, action: #selector(presentBigMap), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
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
    
    lazy var audioImageCollectionView: UICollectionView = {
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
    
}

