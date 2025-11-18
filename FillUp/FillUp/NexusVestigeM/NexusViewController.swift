//
//  NexusViewController.swift
//  FillUp
//
//  Main game view controller
//

import UIKit

class NexusViewController: BaseViewController {
    
    var tileCategory: TileCategoryType // Changed to var for switching
    let gameMode: GameMode
    
    var currentScore: Int = 0
    var currentRound: Int = 1
    var sequenceLength: Int = 3
    var apertureCount: Int = 1
    var mistakeCount: Int = 0
    
    var targetSequence: [TileInfo] = []
    var apertureIndices: [Int] = []
    var selectedTiles: [Int: TileInfo] = [:] // aperture index -> selected tile
    
    lazy var scoreLabel: UILabel = createLabel(fontSize: 24, weight: .bold)
    lazy var roundLabel: UILabel = createLabel(fontSize: 20, weight: .medium)
    lazy var timerLabel: UILabel = createLabel(fontSize: 18, weight: .medium)
    lazy var hintLabel: UILabel = createLabel(fontSize: 16, weight: .medium)
    lazy var targetContainerView: UIView = createContainerView()
    lazy var optionsContainerView: UIView = createContainerView()
    
    lazy var switchTileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎴", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.8)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.isHidden = true // Will show only in Basic Mode
        return button
    }()
    
    var targetTileViews: [EphemeralTileView] = []
    var optionTileViews: [EphemeralTileView] = []
    var hasStartedGame: Bool = false
    
    var gameTimer: Timer?
    var elapsedTime: Double = 0.0
    
    init(tileType: TileCategoryType, gameMode: GameMode = ClassicMode()) {
        self.tileCategory = tileType
        self.gameMode = gameMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasStartedGame && targetContainerView.bounds.width > 0 {
            hasStartedGame = true
            startTimer()
            commenceNewRound()
        }
    }
    
    func setupGameViews() {
        scoreLabel.text = "Score: 0"
        roundLabel.text = "Round: 1"
        timerLabel.text = "Time: 0.0s"
        hintLabel.text = "Tap tiles to fill the gaps"
        
        view.addSubview(scoreLabel)
        view.addSubview(roundLabel)
        view.addSubview(timerLabel)
        view.addSubview(targetContainerView)
        view.addSubview(hintLabel)
        view.addSubview(optionsContainerView)
        view.addSubview(switchTileButton)
        
        // Only show switch button in Basic Mode (non-mixed)
        if !gameMode.usesMixedTiles {
            switchTileButton.isHidden = false
            switchTileButton.addTarget(self, action: #selector(switchTileTypeTapped), for: .touchUpInside)
        }
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            roundLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            roundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 5),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            switchTileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            switchTileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            switchTileButton.widthAnchor.constraint(equalToConstant: 44),
            switchTileButton.heightAnchor.constraint(equalToConstant: 44),
            
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
    
    @objc func switchTileTypeTapped() {
        // Cycle through tile types
        switch tileCategory {
        case .fillA:
            tileCategory = .fillB
        case .fillB:
            tileCategory = .fillC
        case .fillC:
            tileCategory = .fillA
        }
        
        // Animate button
        switchTileButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.2, animations: {
            self.switchTileButton.transform = .identity
        })
        
        // Regenerate current round with new tile type
        commenceNewRound()
    }
    
    override func backButtonTapped() {
        stopTimer()
        super.backButtonTapped()
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

