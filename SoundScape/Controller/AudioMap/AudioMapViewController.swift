//
//  AudioMapViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/6.
//

import UIKit
import GoogleMaps
import CoreLocation

class AudioMapViewController: UIViewController {
    
    // MARK: - properties
    
    let remotePlayHelper = RemotePlayHelper.shared
    
    var tappedMarker = GMSMarker()
    
    var scInfoWindow = SCMapInfoWindow()
    
    let firebaseManager = FirebaseManager.shared
    
    var locationsFromFirebase: [SCLocation]? {
        didSet {
            filterOutAudioDocumentID()
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
        checkLocations()
        setMap()
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
    
}

// MARK: - UI method

extension AudioMapViewController {
    
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
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
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
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        guard let post = tappedMarker.userData as? SCPost,
        let audioLocation = post.audioLocation else { return }
        let location = CLLocationCoordinate2D(latitude: audioLocation.latitude, longitude: audioLocation.longitude )
        scInfoWindow.center = mapView.projection.point(for: location)
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        scInfoWindow.removeFromSuperview()
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
