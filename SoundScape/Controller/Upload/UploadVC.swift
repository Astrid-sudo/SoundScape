//
//  UploadVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit
import Lottie

class UploadVC: UIViewController {
    
    // MARK: - properties
    
    let signInmanager = SignInManager.shared
    
    let firebasemanager = FirebaseManager.shared
    
    var selectedFileURL: URL?
    
    var selectedFileDuration: Double?
    
    // MARK: - UI properties
    
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
    
    private lazy var mapView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: CommonUsage.fakeMap)
        view.contentMode = .scaleAspectFill
        return view
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
            mapView.topAnchor.constraint(equalTo: mapLabel.bottomAnchor, constant: 16),
            mapView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setUploadButton() {
        view.addSubview(uploadButton)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            uploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            uploadButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            uploadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - method
    
    private func addLottie() {
        view.addSubview(animationView)
        animationView.play()
    }
    
    func backToHome() {
        navigationController?.popToRootViewController(animated: true)
        animationView.removeFromSuperview()
        guard let scTabBarController = UIApplication.shared.windows.filter({$0.rootViewController is SCTabBarController}).first?.rootViewController as? SCTabBarController else { return }
        scTabBarController.selectedIndex = 0
    }
    
    func popFillAlert() {
        let alert = UIAlertController(title: "請填滿所有欄位", message: "登入後即可PO聲", preferredStyle: .alert )
        let okButton = UIAlertAction(title: "是！", style: .default)
        
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
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
                          authorID: signInmanager.currentUserInfo?.userID ?? "No signIn",
                          authIDProvider: signInmanager.currentUserInfo?.provider ?? "No signIn",
                          authorName: signInmanager.currentUserInfo?.username ?? "No signIn",
                          title: title,
                          content: content,
                          category: category,
                          duration: 0.0)
        
        
        if let selectedFileDuration = selectedFileDuration {
            post.duration = selectedFileDuration
        }
        
        if let selectedFileURL = selectedFileURL {
            firebasemanager.upload(localURL: selectedFileURL, post: post, completion: backToHome)
        }
    }
    
}
