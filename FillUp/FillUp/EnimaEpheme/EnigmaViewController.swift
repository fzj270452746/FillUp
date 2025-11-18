//
//  EnigmaViewController.swift
//  FillUp
//
//  Game instructions view controller
//

import UIKit

class EnigmaViewController: BaseViewController {
    
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
    
    lazy var titleLabel: UILabel = {
        let label = createLabel(fontSize: 36, weight: .bold)
        label.text = "How to Play"
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInstructionsViews()
        createInstructions()
    }
    
    func setupInstructionsViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
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
            ("🎮 How to Play", "• Fill the gaps marked by '?'\n• Tap tiles from the bottom in order\n• Each round adds more tiles and gaps\n• One mistake ends the game"),
            ("💯 Scoring", "• Basic Mode: Gaps × 10 × Round\n• Mixed Mode: Gaps × 15 × Round + Bonus"),
            ("🎴 Game Modes", "• Basic: Single tile type (Bamboo/Character/Circle)\n• Mixed: All three types combined")
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
}

