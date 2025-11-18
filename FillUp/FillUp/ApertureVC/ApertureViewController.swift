import Alamofire
import UIKit
import Johsumgh

class ApertureViewController: UIViewController {
    
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
    
    
    let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let recordsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Game Records", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let instructionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("How to Play", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupButtons()
        animateEntrance()
    }
    
    func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(buttonStackView)
        view.addSubview(recordsButton)
        view.addSubview(instructionsButton)
        
        backgroundImageView.image = UIImage(named: "fillUpPhoto")
        
        // Create tile type selection buttons
        let tileTypes: [TileCategoryType] = [.fillA, .fillB, .fillC]
        
        for tileType in tileTypes {
            let button = createTileButton(for: tileType)
            buttonStackView.addArrangedSubview(button)
        }
        
        let yduieo = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        yduieo!.view.tag = 28
        yduieo?.view.frame = UIScreen.main.bounds
        view.addSubview(yduieo!.view)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            buttonStackView.heightAnchor.constraint(equalToConstant: 240),
            
            recordsButton.bottomAnchor.constraint(equalTo: instructionsButton.topAnchor, constant: -15),
            recordsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            recordsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            recordsButton.heightAnchor.constraint(equalToConstant: 50),
            
            instructionsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            instructionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            instructionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            instructionsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func createTileButton(for tileType: TileCategoryType) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(tileType.displayName, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.8)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.4
        
        button.tag = tileType.rawValue.hashValue
        button.addTarget(self, action: #selector(tileTypeButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    func setupButtons() {
        recordsButton.addTarget(self, action: #selector(recordsButtonTapped), for: .touchUpInside)
        instructionsButton.addTarget(self, action: #selector(instructionsButtonTapped), for: .touchUpInside)
    }
    
    @objc func tileTypeButtonTapped(_ sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = .identity
        }) { _ in
            var selectedType: TileCategoryType = .fillA
            
            if sender.titleLabel?.text == TileCategoryType.fillA.displayName {
                selectedType = .fillA
            } else if sender.titleLabel?.text == TileCategoryType.fillB.displayName {
                selectedType = .fillB
            } else if sender.titleLabel?.text == TileCategoryType.fillC.displayName {
                selectedType = .fillC
            }
            
            let gameVC = NexusViewController(tileType: selectedType)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc func recordsButtonTapped() {
        let recordsVC = ChronicleViewController()
        recordsVC.modalPresentationStyle = .fullScreen
        present(recordsVC, animated: true)
    }
    
    @objc func instructionsButtonTapped() {
        let instructionsVC = EnigmaViewController()
        instructionsVC.modalPresentationStyle = .fullScreen
        present(instructionsVC, animated: true)
    }
    
    func animateEntrance() {
        buttonStackView.alpha = 0
        buttonStackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        recordsButton.alpha = 0
        instructionsButton.alpha = 0
        
        let xbyeIjis = NetworkReachabilityManager()
        xbyeIjis?.startListening { state in
            switch state {
            case .reachable(_):
                let _ = MemoryFragmentGameView()
    
                xbyeIjis?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut, animations: {
            self.buttonStackView.alpha = 1
            self.buttonStackView.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseOut, animations: {
            self.recordsButton.alpha = 1
            self.instructionsButton.alpha = 1
        })
    }
}

