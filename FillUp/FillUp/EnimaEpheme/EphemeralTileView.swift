//
//  EphemeralTileView.swift
//  FillUp
//
//  Mahjong tile view component
//

import UIKit

class EphemeralTileView: UIView {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    var tileValue: Int = 0
    var isAperture: Bool = false // Is this a gap/empty slot
    
    init(value: Int, image: UIImage?, isAperture: Bool = false) {
        super.init(frame: .zero)
        self.tileValue = value
        self.isAperture = isAperture
        
        setupViews()
        
        if isAperture {
            configureAsAperture()
        } else {
            imageView.image = image
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Add corner radius to image
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        // Add shadow effect
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
    }
    
    func configureAsAperture() {
        backgroundColor = UIColor.white.withAlphaComponent(0.3)
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        layer.cornerRadius = 8
        
        valueLabel.text = "?"
        valueLabel.isHidden = false
        valueLabel.font = UIFont.boldSystemFont(ofSize: 32)
    }
    
    func luminousHighlight() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.layer.shadowOpacity = 0.6
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.transform = .identity
                self.layer.shadowOpacity = 0.3
            }
        }
    }
    
    func pulsateAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 1.15
        animation.duration = 0.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "pulsate")
    }
    
    func removePulsateAnimation() {
        layer.removeAnimation(forKey: "pulsate")
    }
}

