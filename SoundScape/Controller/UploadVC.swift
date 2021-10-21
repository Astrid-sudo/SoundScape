//
//  UploadVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit

enum AudioCategory: String, CaseIterable {
    case nature = "Nature"
    case meaningful = "Meaningful"
    case unique = "Unique"
}

class UploadVC: UIViewController {
    
    // MARK: - properties
    
    // MARK: - UI properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.title
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.description
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.category
        return label
    }()
    
    private  lazy var mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.pinOnMap
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.layer.borderWidth = 0.5
        textField.textAlignment = .left
        //      textField.delegate = self
        //      textField.addRightButtonOnKeyboardWithText(Stylish.Title.textFieldStepperButtOnKeyboard, target: self, action: #selector(done))
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.textColor = .black
        textView.font = UIFont(name: CommonUsage.font, size: 15)
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isSelectable = false
        textView.isScrollEnabled = false
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
    
    private lazy var mapView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
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
        
    }
    
    // MARK: - UI method
    
    private func setTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150)
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
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100)
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
            categorySegmentControl.heightAnchor.constraint(equalToConstant: 30)
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
            mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 16),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - method
    
    // MARK: - action
}
