//
//  EnigmaViewController.swift
//  FillUp
//
//  Game instructions view controller
//

import UIKit

class EnigmaViewController: UIViewController {
    
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
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "How to Play"
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        createInstructions()
    }
    
    func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(backButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        
        backgroundImageView.image = UIImage(named: "fillUpPhoto")
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func createInstructions() {
        let instructions = [
            ("🎮 How to Play", "• The top row shows a sequence of mahjong tiles with one or more gaps marked by '?'\n• Tap tiles from the bottom row to fill the gaps in order\n• Complete the sequence correctly to earn points and advance to the next round"),
            ("📈 Progression", "• Round 1 starts with 3 tiles and 1 gap\n• Each round adds more tiles and gaps\n• The difficulty increases as you progress\n• Gaps can appear at different positions"),
            ("💯 Scoring", "• Earn points based on: Number of gaps × 10 × Current round\n• More gaps and higher rounds = more points\n• Try to reach the highest score possible!"),
            ("❌ Game Over", "• The game ends when you fill the gaps incorrectly\n• Your score and progress will be saved to the records\n• You can retry anytime to beat your high score"),
            ("🎴 Tile Series", "• Choose from three different mahjong tile series:\n  - Bamboo Series (fillA)\n  - Character Series (fillB)\n  - Circle Series (fillC)\n• Each series has tiles numbered 1-9")
        ]
        
        var previousView: UIView = titleLabel
        
        for (index, (title, content)) in instructions.enumerated() {
            let sectionView = createInstructionSection(title: title, content: content)
            contentView.addSubview(sectionView)
            
            NSLayoutConstraint.activate([
                sectionView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 25),
                sectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                sectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
            
            if index == instructions.count - 1 {
                sectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
            }
            
            previousView = sectionView
            
            // Entrance animation
            sectionView.alpha = 0
            sectionView.transform = CGAffineTransform(translationX: -30, y: 0)
            UIView.animate(withDuration: 0.6, delay: Double(index) * 0.1, options: .curveEaseOut, animations: {
                sectionView.alpha = 1
                sectionView.transform = .identity
            })
        }
    }
    
    func createInstructionSection(title: String, content: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .systemYellow
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.textColor = .white
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15)
        ])
        
        return containerView
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true)
    }
}

