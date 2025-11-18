//
//  BaseViewController.swift
//  FillUp
//
//  Base view controller with common UI elements
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Common UI Elements
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Configuration
    
    var showBackButton: Bool = true
    var backgroundImageName: String = "fillUpPhoto"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseViews()
    }
    
    // MARK: - Setup Methods
    
    func setupBaseViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        
        backgroundImageView.image = UIImage(named: backgroundImageName)
        
        if showBackButton {
            view.addSubview(backButton)
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }
        
        setupBaseConstraints()
    }
    
    func setupBaseConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if showBackButton {
            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                backButton.widthAnchor.constraint(equalToConstant: 100),
                backButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    // MARK: - Actions
    
    @objc func backButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    
    func createStyledButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func createLabel(fontSize: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = .white, alignment: NSTextAlignment = .center) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = color
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }
    
    func createContainerView(alpha: CGFloat = 0.15) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

