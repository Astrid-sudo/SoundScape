//
//  UploadVC + extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/20.
//

import UIKit

 extension UploadVC {
    // MARK: - UI method
    
     func setViewBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
     func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backToLastPage))
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: CommonUsage.SFSymbol.back)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: CommonUsage.scWhite)
        navigationItem.title = CommonUsage.Text.upload
    }
    
     func setScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
     func setTitleLabel() {
        scrollView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8)
        ])
    }
    
     func setTitleTextField() {
        scrollView.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32)
        ])
    }
    
     func setDescriptionLabel() {
        scrollView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16)
        ])
    }
    
     func setDescriptionTextView() {
        scrollView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                                                         constant: 16),
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            descriptionTextView.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32)
        ])
    }
    
     func setCategoryLabel() {
        scrollView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            categoryLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16)
        ])
    }
    
     func setCategoryCollectionView() {
        scrollView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth ),
            collectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
            collectionView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
     func setAudioImageLabel() {
        scrollView.addSubview(audioImageLabel)
        audioImageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImageLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                                                     constant: 16),
            audioImageLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16)
        ])
    }
    
     func setImageCollectionView() {
        scrollView.addSubview(audioImageCollectionView)
        audioImageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImageCollectionView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            audioImageCollectionView.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth),
            audioImageCollectionView.topAnchor.constraint(equalTo: audioImageLabel.bottomAnchor, constant: 8),
            audioImageCollectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
     func setMapLabel() {
        scrollView.addSubview(mapLabel)
        mapLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            mapLabel.topAnchor.constraint(equalTo: audioImageCollectionView.bottomAnchor, constant: 8)
        ])
    }
     
     func setMapHintLabel() {
        scrollView.addSubview(mapNoticeLabel)
         mapNoticeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapNoticeLabel.leadingAnchor.constraint(equalTo: mapLabel.trailingAnchor, constant: 4),
            mapNoticeLabel.centerYAnchor.constraint(equalTo: mapLabel.centerYAnchor)
        ])
    }
    
     func setViewUnderMap() {
        scrollView.addSubview(viewUndermap)
        viewUndermap.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewUndermap.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            viewUndermap.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32),
            viewUndermap.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 16),
            viewUndermap.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
     func setMapView() {
        viewUndermap.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: viewUndermap.leadingAnchor),
            mapView.widthAnchor.constraint(equalToConstant: CommonUsage.screenWidth - 32),
            mapView.topAnchor.constraint(equalTo: viewUndermap.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: viewUndermap.bottomAnchor)
        ])
    }
    
     func setUploadButton() {
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
    
     func setSearchPlaceButton() {
        scrollView.addSubview(searchPlaceButton)
        searchPlaceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchPlaceButton.trailingAnchor.constraint(equalTo: uploadButton.trailingAnchor),
            searchPlaceButton.centerYAnchor.constraint(equalTo: mapLabel.centerYAnchor),
            searchPlaceButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    

}
