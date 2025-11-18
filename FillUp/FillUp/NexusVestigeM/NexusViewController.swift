//
//  NexusViewController.swift
//  FillUp
//
//  Main game view controller
//

import UIKit

class NexusViewController: UIViewController {
    
    let tileCategory: TileCategoryType
    
    var currentScore: Int = 0
    var currentRound: Int = 1
    var sequenceLength: Int = 3
    var apertureCount: Int = 1
    
    var targetSequence: [Int] = []
    var apertureIndices: [Int] = []
    var selectedTiles: [Int: Int] = [:] // aperture index -> selected value
    
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
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Score: 0"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    let roundLabel: UILabel = {
        let label = UILabel()
        label.text = "Round: 1"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "Time: 0.0s"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    let targetContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let optionsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Select tiles to fill the gaps"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    var targetTileViews: [EphemeralTileView] = []
    var optionTileViews: [EphemeralTileView] = []
    var hasStartedGame: Bool = false
    
    var gameTimer: Timer?
    var elapsedTime: Double = 0.0
    
    init(tileType: TileCategoryType) {
        self.tileCategory = tileType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasStartedGame && targetContainerView.bounds.width > 0 {
            hasStartedGame = true
            startTimer()
            commenceNewRound()
        }
    }
    
    func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(backButton)
        view.addSubview(scoreLabel)
        view.addSubview(roundLabel)
        view.addSubview(timerLabel)
        view.addSubview(targetContainerView)
        view.addSubview(hintLabel)
        view.addSubview(optionsContainerView)
        
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
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            roundLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            roundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 5),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            targetContainerView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 30),
            targetContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            targetContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            targetContainerView.heightAnchor.constraint(equalToConstant: 140),
            
            hintLabel.bottomAnchor.constraint(equalTo: optionsContainerView.topAnchor, constant: -12),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            optionsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            optionsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            optionsContainerView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    @objc func backButtonTapped() {
        stopTimer()
        dismiss(animated: true)
    }
    
    func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 0.1
            self?.updateTimerLabel()
        }
    }
    
    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    func updateTimerLabel() {
        timerLabel.text = String(format: "Time: %.1fs", elapsedTime)
    }
    
    deinit {
        stopTimer()
    }
}

