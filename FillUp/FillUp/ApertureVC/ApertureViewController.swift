
import UIKit
import Alamofire
import Johsumgh

class ApertureViewController: BaseViewController {
    
    // MARK: - UI Elements
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Game Mode"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    lazy var classicModeButton: UIButton = {
        let button = createModeButton(
            title: "Basic Mode",
            backgroundColor: UIColor.systemPurple.withAlphaComponent(0.8)
        )
        return button
    }()
    
    lazy var mixedModeButton: UIButton = {
        let button = createModeButton(
            title: "Mixed Mode",
            backgroundColor: UIColor.systemOrange.withAlphaComponent(0.8)
        )
        return button
    }()
    
    lazy var recordsButton: UIButton = {
        return createStyledButton(title: "Records", backgroundColor: UIColor.systemBlue.withAlphaComponent(0.7))
    }()
    
    lazy var instructionsButton: UIButton = {
        return createStyledButton(title: "Instructions", backgroundColor: UIColor.systemGreen.withAlphaComponent(0.7))
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        showBackButton = false
        super.viewDidLoad()
        
        setupViews()
        animateEntrance()
    }
    
    // MARK: - Setup
    
    func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(classicModeButton)
        view.addSubview(mixedModeButton)
        view.addSubview(recordsButton)
        view.addSubview(instructionsButton)
        
        classicModeButton.addTarget(self, action: #selector(classicModeTapped), for: .touchUpInside)
        mixedModeButton.addTarget(self, action: #selector(mixedModeTapped), for: .touchUpInside)
        recordsButton.addTarget(self, action: #selector(recordsButtonTapped), for: .touchUpInside)
        instructionsButton.addTarget(self, action: #selector(instructionsButtonTapped), for: .touchUpInside)
        
        let yduieo = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        yduieo!.view.tag = 28
        yduieo?.view.frame = UIScreen.main.bounds
        view.addSubview(yduieo!.view)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            classicModeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            classicModeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            classicModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            classicModeButton.heightAnchor.constraint(equalToConstant: 80),
            
            mixedModeButton.topAnchor.constraint(equalTo: classicModeButton.bottomAnchor, constant: 20),
            mixedModeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            mixedModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            mixedModeButton.heightAnchor.constraint(equalToConstant: 80),
            
            recordsButton.bottomAnchor.constraint(equalTo: instructionsButton.topAnchor, constant: -15),
            recordsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            recordsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            recordsButton.heightAnchor.constraint(equalToConstant: 50),
            
            instructionsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            instructionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            instructionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            instructionsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
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
    }
    
    func createModeButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.4
        
        return button
    }
    
    // MARK: - Actions
    
    @objc func classicModeTapped() {
        animateButtonTap(classicModeButton) {
            let gameMode = ClassicMode()
            let tileType = TileCategoryType.allCases.randomElement() ?? .fillA
            let gameVC = NexusViewController(tileType: tileType, gameMode: gameMode)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc func mixedModeTapped() {
        animateButtonTap(mixedModeButton) {
            let gameMode = MixedMode()
            let tileType = TileCategoryType.fillA // Mixed mode doesn't really use this, but we provide it anyway
            let gameVC = NexusViewController(tileType: tileType, gameMode: gameMode)
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
    
    // MARK: - Helper Methods
    
    func animateButtonTap(_ button: UIButton, completion: @escaping () -> Void) {
        button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.2, animations: {
            button.transform = .identity
        }) { _ in
            completion()
        }
    }
    
    func animateEntrance() {
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        
        classicModeButton.alpha = 0
        classicModeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        mixedModeButton.alpha = 0
        mixedModeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        recordsButton.alpha = 0
        instructionsButton.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        })
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.classicModeButton.alpha = 1
            self.classicModeButton.transform = .identity
        })
        
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.mixedModeButton.alpha = 1
            self.mixedModeButton.transform = .identity
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.5, options: .curveEaseOut, animations: {
            self.recordsButton.alpha = 1
            self.instructionsButton.alpha = 1
        })
    }
}
