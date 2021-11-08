//
//  AudioMapViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/6.
//

import UIKit
import GoogleMaps
import CoreLocation
import MapKit

protocol LocationCoordinatePassableDelegate: AnyObject {
    func displayPinOnSmallMap(locationFromBigMap: CLLocationCoordinate2D?)
}

enum AudioMapType {
    case pinOnMap
    case browseMap
}

class AudioMapViewController: UIViewController {
    
    // MARK: - properties
    
    let signInmanager = SignInManager.shared
    
    var audioMapType = AudioMapType.browseMap
    
    var pinnedLocation: CLLocationCoordinate2D?
    
    var audioTitle: String?
    
    let remotePlayHelper = RemotePlayHelper.shared
    
    var tappedMarker = GMSMarker()
    
    var scInfoWindow = SCMapInfoWindow()
    
    let firebaseManager = FirebaseManager.shared
    
    weak var delegate: LocationCoordinatePassableDelegate?
    
    private lazy var searchCompleter: MKLocalSearchCompleter = {
       let completer = MKLocalSearchCompleter()
        completer.delegate = self
        return completer
    }()
    
    private var completerResults = [MKLocalSearchCompletion]()
    
    var locationsFromFirebase: [SCLocation]? {
        didSet {
            filterOutAudioDocumentID()
        }
    }
    
    var searchedLocation: CLLocationCoordinate2D? {
        didSet {
            guard let searchedLocation = searchedLocation else { return }
            mapView.camera = GMSCameraPosition.camera(withLatitude: searchedLocation.latitude, longitude: searchedLocation.longitude, zoom: 15)
            searchResultMarker.position = searchedLocation
            searchResultMarker.map = mapView
        }
    }
    
    var currentLocation: CLLocationCoordinate2D?
    
    var defaultLocation = CLLocationCoordinate2DMake(25.034012, 121.563461)
    
    var audioPostCache: [String: SCPost] = [:]
    
    var newAudioDocumentIDs = Set<String>() {
        didSet {
            for documentID in newAudioDocumentIDs {
                firebaseManager.fetchPosts { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                        
                    case .success(let posts):
                        let audioPost = posts.filter({$0.documentID == documentID}).first
                        self.audioPostCache[documentID] = audioPost
                        self.makeMarker()
                    case .failure(let error):
                        print("Cant fetch new SCPost \(error)")
                    }
                }
            }
        }
    }
    
    var audioDocumentIDs = Set<String>() {
        didSet {
            if audioDocumentIDs != oldValue {
                newAudioDocumentIDs = audioDocumentIDs.subtracting(oldValue)
            }
        }
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch audioMapType {
        case .pinOnMap:
            setMap()
            addSearchBar()
            setTableView()
        case .browseMap:
            checkLocations()
            setMap()
            addSearchBar()
            setTableView()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if audioMapType == .pinOnMap {
            tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: - method
    
    private func checkLocations() {
        
        firebaseManager.checkLocationChange { result in
            
            switch result {
                
            case .success(let locations):
                self.locationsFromFirebase = locations
                
            case .failure(let error):
                
                print("AudioMapViewController failed to fetch locations \(error)")
            }
        }
    }
    
    private func filterOutAudioDocumentID() {
        
        guard let locationsFromFirebase = locationsFromFirebase else { return }
        
        audioDocumentIDs = Set(locationsFromFirebase.map({$0.audioDocumentID}))
    }
    
    private func makeMarker() {
        
        for newAudioDocumentID in newAudioDocumentIDs {
            
            if let post = audioPostCache[newAudioDocumentID] {
                
                if let audioLocation = post.audioLocation {
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: audioLocation.latitude, longitude: audioLocation.longitude))
                    marker.userData = post
                    marker.map = mapView
                }
            }
        }
    }
    
    // MARK: - UI properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = true
        table.separatorStyle = .singleLine
        table.register(MapSearchResultTableViewCell.self, forCellReuseIdentifier: MapSearchResultTableViewCell.reuseIdentifier)
        table.isHidden = true
        return table
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = UIColor(named: CommonUsage.scLightBlue)
        searchBar.layer.cornerRadius = 10
        searchBar.placeholder = CommonUsage.Text.search
        searchBar.delegate = self
        searchBar.searchTextField.textColor = UIColor(named: CommonUsage.scBlue)
        searchBar.showsCancelButton = true
        return searchBar
    }()

    private lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        let posision = currentLocation ?? defaultLocation
        let camera = GMSCameraPosition.camera(withLatitude: posision.latitude, longitude: posision.longitude, zoom: 15.0)
        mapView.delegate = self
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        return mapView
    }()
    
    private lazy var searchResultMarker: GMSMarker = {
        var marker = GMSMarker(position: searchedLocation ?? defaultLocation)
        marker.icon = GMSMarker.markerImage(with: UIColor(named: CommonUsage.scLightBlue))
        return marker
    }()
    
    private lazy var pinMarker: GMSMarker = {
        var marker = GMSMarker(position: currentLocation ?? defaultLocation)
        marker.icon = GMSMarker.markerImage(with: UIColor(named: CommonUsage.scRed))
        marker.map = mapView
        return marker
    }()

}

// MARK: - UI method

extension AudioMapViewController {
    
    private func addSearchBar() {
        navigationItem.titleView = searchBar
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

    }
    
    private func setMap() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

// MARK: - conform to GMSMapViewDelegate

extension AudioMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        switch audioMapType {
        case .pinOnMap:
            return nil
        case .browseMap:
            return UIView()
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        switch audioMapType {
        
        case .pinOnMap:
           
            return true
        
        case .browseMap:
            
            let location = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
            guard let post = marker.userData as? SCPost else { return false }
            let audioAuthorName = post.authorName
            let audioTitle = post.title
            scInfoWindow.setMapMarkerIcon(title: audioTitle, authorName: audioAuthorName)
            tappedMarker = marker
            scInfoWindow.center = mapView.projection.point(for: location)
            scInfoWindow.center.y -= 20
            scInfoWindow.delegate = self
            self.view.addSubview(scInfoWindow)
            return false
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        guard let post = tappedMarker.userData as? SCPost,
        let audioLocation = post.audioLocation else { return }
        let location = CLLocationCoordinate2D(latitude: audioLocation.latitude, longitude: audioLocation.longitude )
        scInfoWindow.center = mapView.projection.point(for: location)
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        switch audioMapType {
            
        case .pinOnMap:
            
            pinnedLocation = coordinate
            pinMarker.title = audioTitle
            pinMarker.position = coordinate
            pinMarker.snippet = signInmanager.currentUserInfoFirebase?.username
            pinMarker.map = mapView
            mapView.selectedMarker = pinMarker
            delegate?.displayPinOnSmallMap(locationFromBigMap: pinnedLocation)
        
        case .browseMap:
            
            scInfoWindow.removeFromSuperview()
        }
    }

}

// MARK: - conform to ButtonTappedPassableDelegate

extension AudioMapViewController: ButtonTappedPassableDelegate {
    
    func pushSoundDetailPage() {
        
        guard let post = tappedMarker.userData as? SCPost else { return }
        let documentID = post.documentID
        let url = post.audioURL
        let title = post.title
        let author = post.authorName
        let content = post.content
        let duration = post.duration
        let authorUserID = post.authorID
        let authorAccountProvider = post.authIDProvider

        remotePlayHelper.url = url
        remotePlayHelper.setPlayInfo(title: title,
                                     author: author,
                                     content: content,
                                     duration: duration,
                                     documentID: documentID,
                                     authorUserID: authorUserID,
                                     authorAccountProvider: authorAccountProvider)
        
        AudioPlayerWindow.shared.show()
    }
    
}

// MARK: - conform to UISearchBarDelegate

extension AudioMapViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchBar.text ?? ""

    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = false
        scInfoWindow.removeFromSuperview()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        tableView.isHidden = true
    }
    
}

// MARK: - conform to UITableViewDataSource

extension AudioMapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        completerResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MapSearchResultTableViewCell.reuseIdentifier, for: indexPath) as? MapSearchResultTableViewCell else { return UITableViewCell() }
        let suggestion = completerResults[indexPath.row]
        let title = suggestion.title
        let subTitle = suggestion.subtitle
        cell.configCell(title: title, subTitle: subTitle)
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension AudioMapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = completerResults[indexPath.row]
        let address = suggestion.subtitle.isEmpty ? suggestion.title : suggestion.subtitle
        
        LocationService.getCoordinate(addressString: address) { [weak self] (coordinate, error) in
            
            guard let self = self else { return }

          if let error = error {
            print("fetching coordinate error: \(error.localizedDescription)")
          } else {
            print("coordinate is \(coordinate)")
              self.searchedLocation = coordinate
          }
        }
        
        tableView.isHidden = true
        searchBar.endEditing(true)
        searchBar.text = suggestion.title

      }
    
}

// MARK: - conform to MKLocalSearchCompleterDelegate

extension AudioMapViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
      completerResults = completer.results
      tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
      print("didFailWithError: \(error.localizedDescription)")
    }

}
