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
            mapView.camera = GMSCameraPosition.camera(withLatitude: pinnedLocation.latitude, longitude: pinnedLocation.longitude, zoom: 15)
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
    
    // MARK: - UI properties
    
    private lazy var mapMarker: GMSMarker = {
        var marker = GMSMarker(position: currentLocation ?? defaultLocation)
        marker.icon = GMSMarker.markerImage(with: UIColor(named: CommonUsage.scRed))
        marker.map = mapView
        return marker
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.title
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.description
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.category
        return label
    }()
    
    private  lazy var mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.pinOnMap
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textColor = .white
        textField.layer.borderWidth = 0.5
        textField.textAlignment = .left
        textField.backgroundColor = .clear
        textField.delegate = self
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.textColor = .white
        textView.font = UIFont(name: CommonUsage.font, size: 15)
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    lazy var categorySegmentControl: UISegmentedControl = {
        let control = UISegmentedControl(
            items: [
                AudioCategory.nature.rawValue,
                AudioCategory.meaningful.rawValue,
                AudioCategory.unique.rawValue
            ]
        )
        control.tintColor = UIColor.black
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        let posision = pinnedLocation ?? currentLocation ?? defaultLocation
        let camera = GMSCameraPosition.camera(withLatitude: posision.latitude, longitude: posision.longitude, zoom: 15.0)
        mapView.delegate = self
        mapView.camera = camera
        
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
        button.backgroundColor = UIColor(named: CommonUsage.scGreen)
        button.setTitle(CommonUsage.Text.upload, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(upload), for: .touchUpInside)
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
        button.backgroundColor = UIColor(named: CommonUsage.scSuperLightBlue)
        button.setTitle(CommonUsage.Text.searchPlace, for: .normal)
        button.setTitleColor(UIColor(named: CommonUsage.scRed), for: .normal)
        button.addTarget(self, action: #selector(presentBigMap), for: .touchUpInside)
        return button
    }()

    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel()
        setTitleTextField()
        setDescriptionLabel()
        setDescriptionTextView()
        setCategoryLabel()
        setCategorySegmentControl()
        setMapLabel()
        setMapView()
        setUploadButton()
        setViewBackgroundColor()
        setSearchPlaceButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let pinnedLocation = pinnedLocation else { return }
        mapView.camera = GMSCameraPosition.camera(withLatitude: pinnedLocation.latitude, longitude: pinnedLocation.longitude, zoom: 15)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let pinnedLocation = pinnedLocation else { return }
        askUserLocation()
        mapView.camera = GMSCameraPosition.camera(withLatitude: pinnedLocation.latitude, longitude: pinnedLocation.longitude, zoom: 15)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myLocation.stopUpdatingLocation()
    }
    
    // MARK: - UI method
    
    private func setViewBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func setTitleTextField() {
        view.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setDescriptionLabel() {
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16)
        ])
    }
    
    private func setDescriptionTextView() {
        view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setCategoryLabel() {
        view.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16)
        ])
    }
    
    private func setCategorySegmentControl() {
        view.addSubview(categorySegmentControl)
        categorySegmentControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categorySegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categorySegmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categorySegmentControl.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
            categorySegmentControl.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    private func setMapLabel() {
        view.addSubview(mapLabel)
        mapLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapLabel.topAnchor.constraint(equalTo: categorySegmentControl.bottomAnchor, constant: 16)
        ])
    }
    
    private func setMapView() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 16)
        ])
    }
    
    private func setUploadButton() {
        view.addSubview(uploadButton)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            uploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            uploadButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8),
            uploadButton.heightAnchor.constraint(equalToConstant: 30),
            uploadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
    }
    
    private func setSearchPlaceButton() {
        view.addSubview(searchPlaceButton)
        searchPlaceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchPlaceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchPlaceButton.topAnchor.constraint(equalTo: categorySegmentControl.bottomAnchor, constant: 16)
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
    
    @objc func upload() {
        
        addLottie()
        
        guard let title = titleTextField.text,
              let content = descriptionTextView.text,
              let category = categorySegmentControl.titleForSegment(at: categorySegmentControl.selectedSegmentIndex) else {
                  popFillAlert()
                  return
              }
        
        var post = SCPost(documentID: "",
                          authorID: signInmanager.currentUserInfoFirebase?.userID ?? "No signIn",
                          authIDProvider: signInmanager.currentUserInfoFirebase?.provider ?? "No signIn",
                          authorName: signInmanager.currentUserInfoFirebase?.username ?? "No signIn",
                          title: title,
                          content: content,
                          category: category,
                          audioLocation: clLocationToGepPoint(cl: pinnedLocation ?? currentLocation),
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
//        mapMarker.title = titleTextField.text
//        mapMarker.position = coordinate
//        mapMarker.snippet = signInmanager.currentUserInfoFirebase?.username
//        mapMarker.map = mapView
//        mapView.selectedMarker = mapMarker
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

extension UploadVC: LocationCoordinatePassableDelegate {
   
    func displayPinOnSmallMap(locationFromBigMap: CLLocationCoordinate2D?) {
        pinnedLocation = locationFromBigMap
        mapView.isMyLocationEnabled = false
        backFromBigMap = true
    }
    
}
