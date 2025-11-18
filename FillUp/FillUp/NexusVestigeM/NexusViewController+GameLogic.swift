//
//  NexusViewController+GameLogic.swift
//  FillUp
//
//  Game logic extension for NexusViewController
//

import UIKit

extension NexusViewController {
    
    func commenceNewRound() {
        selectedTiles.removeAll()
        
        // Calculate sequence length and aperture count based on round
        if currentRound == 1 {
            sequenceLength = 3
            apertureCount = 1
        } else {
            sequenceLength = min(3 + currentRound, 9)
            apertureCount = min(1 + (currentRound / 2), 4)
        }
        
        // Generate random sequence
        let startValue = Int.random(in: 1...(10 - sequenceLength))
        targetSequence = Array(startValue...(startValue + sequenceLength - 1))
        
        // Select random aperture positions
        apertureIndices = Array(0..<sequenceLength)
            .shuffled()
            .prefix(apertureCount)
            .sorted()
        
        renderTargetTiles()
        renderOptionTiles()
        
        updateLabels()
    }
    
    func renderTargetTiles() {
        // Remove existing tiles
        targetTileViews.forEach { $0.removeFromSuperview() }
        targetTileViews.removeAll()
        
        let containerWidth = targetContainerView.bounds.width
        let tileWidth: CGFloat = min(80, (containerWidth - 40) / CGFloat(sequenceLength) - 10)
        let tileHeight: CGFloat = 100
        let spacing: CGFloat = 10
        let totalWidth = CGFloat(sequenceLength) * tileWidth + CGFloat(sequenceLength - 1) * spacing
        let startX = (containerWidth - totalWidth) / 2
        
        for (index, value) in targetSequence.enumerated() {
            let isAperture = apertureIndices.contains(index)
            let image = isAperture ? nil : tileCategory.retrieveImage(for: value)
            
            let tileView = EphemeralTileView(value: value, image: image, isAperture: isAperture)
            targetContainerView.addSubview(tileView)
            targetTileViews.append(tileView)
            
            let xPosition = startX + CGFloat(index) * (tileWidth + spacing)
            
            tileView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tileView.centerYAnchor.constraint(equalTo: targetContainerView.centerYAnchor),
                tileView.leadingAnchor.constraint(equalTo: targetContainerView.leadingAnchor, constant: xPosition),
                tileView.widthAnchor.constraint(equalToConstant: tileWidth),
                tileView.heightAnchor.constraint(equalToConstant: tileHeight)
            ])
            
            // Force layout update
            targetContainerView.layoutIfNeeded()
            
            if isAperture {
                tileView.pulsateAnimation()
            }
            
            // Entrance animation
            tileView.alpha = 0
            tileView.transform = CGAffineTransform(translationX: 0, y: -50)
            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.1, options: .curveEaseOut, animations: {
                tileView.alpha = 1
                tileView.transform = .identity
            })
        }
    }
    
    func renderOptionTiles() {
        // Remove existing tiles
        optionTileViews.forEach { $0.removeFromSuperview() }
        optionTileViews.removeAll()
        
        // Generate options including correct answers and distractors
        var options: [Int] = []
        for index in apertureIndices {
            options.append(targetSequence[index])
        }
        
        // Add distractors to make total 6 tiles (will display in 2 rows)
        let totalTiles = 6
        let distractorCount = totalTiles - options.count
        var availableValues = Array(1...9).filter { value in
            !options.contains(value)
        }
        
        for _ in 0..<distractorCount {
            if let randomValue = availableValues.randomElement() {
                options.append(randomValue)
                availableValues.removeAll { $0 == randomValue }
            }
        }
        
        options.shuffle()
        
        let containerWidth = optionsContainerView.bounds.width
        let containerHeight = optionsContainerView.bounds.height
        
        // Calculate tile size based on container width
        let tilesPerRow = 3
        let horizontalSpacing: CGFloat = 15
        let verticalSpacing: CGFloat = 10
        let availableWidth = containerWidth - 40 // 20 padding on each side
        let tileWidth = (availableWidth - CGFloat(tilesPerRow - 1) * horizontalSpacing) / CGFloat(tilesPerRow)
        let tileHeight: CGFloat = min(tileWidth * 1.3, 70) // Aspect ratio
        
        for (index, value) in options.enumerated() {
            let row = index / tilesPerRow
            let col = index % tilesPerRow
            
            let image = tileCategory.retrieveImage(for: value)
            let tileView = EphemeralTileView(value: value, image: image, isAperture: false)
            optionsContainerView.addSubview(tileView)
            optionTileViews.append(tileView)
            
            // Calculate row width for centering
            let tilesInThisRow = min(tilesPerRow, options.count - row * tilesPerRow)
            let rowWidth = CGFloat(tilesInThisRow) * tileWidth + CGFloat(tilesInThisRow - 1) * horizontalSpacing
            let rowStartX = (containerWidth - rowWidth) / 2
            
            let xPosition = rowStartX + CGFloat(col) * (tileWidth + horizontalSpacing)
            let totalHeight = 2 * tileHeight + verticalSpacing
            let startY = (containerHeight - totalHeight) / 2
            let yPosition = startY + CGFloat(row) * (tileHeight + verticalSpacing)
            
            tileView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tileView.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: xPosition),
                tileView.topAnchor.constraint(equalTo: optionsContainerView.topAnchor, constant: yPosition),
                tileView.widthAnchor.constraint(equalToConstant: tileWidth),
                tileView.heightAnchor.constraint(equalToConstant: tileHeight)
            ])
            
            // Force layout update
            optionsContainerView.layoutIfNeeded()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTileTapped(_:)))
            tileView.addGestureRecognizer(tapGesture)
            tileView.isUserInteractionEnabled = true
            
            // Entrance animation
            tileView.alpha = 0
            tileView.transform = CGAffineTransform(translationX: 0, y: 50)
            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.08, options: .curveEaseOut, animations: {
                tileView.alpha = 1
                tileView.transform = .identity
            })
        }
    }
    
    @objc func optionTileTapped(_ gesture: UITapGestureRecognizer) {
        guard let tileView = gesture.view as? EphemeralTileView else { return }
        
        // Find next empty aperture
        guard let nextApertureIndex = apertureIndices.first(where: { !selectedTiles.keys.contains($0) }) else {
            return
        }
        
        // Highlight animation
        tileView.luminousHighlight()
        
        // Store selection
        selectedTiles[nextApertureIndex] = tileView.tileValue
        
        // Animate tile movement towards the corresponding target tile center
        let targetTileView = targetTileViews[nextApertureIndex]
        
        guard let movingTile = createMovingTile(from: tileView) else {
            updateTargetTile(targetTileView, with: tileView)
            return
        }
        
        tileView.alpha = 0.3
        tileView.isUserInteractionEnabled = false
        
        let destinationCenter = destinationPoint(for: targetTileView)
        
        animateMovingTile(movingTile, to: destinationCenter) {
            movingTile.removeFromSuperview()
            self.updateTargetTile(targetTileView, with: tileView)
            
            // Check if all apertures are filled
            if self.selectedTiles.count == self.apertureIndices.count {
                self.evaluateResult()
            }
        }
    }
    
    func evaluateResult() {
        var isCorrect = true
        
        for index in apertureIndices {
            if selectedTiles[index] != targetSequence[index] {
                isCorrect = false
                break
            }
        }
        
        if isCorrect {
            demonstrateSuccess()
        } else {
            demonstrateFailure()
        }
    }
    
    func demonstrateSuccess() {
        let pointsEarned = apertureCount * 10 * currentRound
        currentScore += pointsEarned
        
        // Success animation
        let successLabel = UILabel()
        successLabel.text = "Perfect! +\(pointsEarned)"
        successLabel.font = UIFont.boldSystemFont(ofSize: 36)
        successLabel.textColor = .systemGreen
        successLabel.textAlignment = .center
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successLabel)
        
        NSLayoutConstraint.activate([
            successLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        successLabel.alpha = 0
        successLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.5, animations: {
            successLabel.alpha = 1
            successLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5, animations: {
                successLabel.alpha = 0
                successLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                successLabel.removeFromSuperview()
                self.currentRound += 1
                self.commenceNewRound()
            }
        }
        
        // Tile celebration animation
        for tileView in targetTileViews {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .repeat], animations: {
                tileView.transform = CGAffineTransform(rotationAngle: .pi / 16)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                tileView.layer.removeAllAnimations()
                tileView.transform = .identity
            }
        }
    }
    
    func demonstrateFailure() {
        // Stop timer and save game record
        stopTimer()
        VestigeDataManager.shared.archiveRecord(score: currentScore, rounds: currentRound, tileType: tileCategory.rawValue, duration: elapsedTime)
        
        let failureLabel = UILabel()
        failureLabel.text = "Game Over\nFinal Score: \(currentScore)"
        failureLabel.numberOfLines = 0
        failureLabel.font = UIFont.boldSystemFont(ofSize: 32)
        failureLabel.textColor = .systemRed
        failureLabel.textAlignment = .center
        failureLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(failureLabel)
        
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("Try Again", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        retryButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        retryButton.layer.cornerRadius = 12
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retryGame), for: .touchUpInside)
        view.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            failureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            failureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            retryButton.topAnchor.constraint(equalTo: failureLabel.bottomAnchor, constant: 30),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 200),
            retryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        failureLabel.alpha = 0
        retryButton.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            failureLabel.alpha = 1
            retryButton.alpha = 1
        })
        
        // Shake animation for incorrect tiles
        for index in apertureIndices {
            let tileView = targetTileViews[index]
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.5
            animation.values = [-10, 10, -8, 8, -5, 5, 0]
            tileView.layer.add(animation, forKey: "shake")
        }
    }
    
    @objc func retryGame() {
        currentScore = 0
        currentRound = 1
        hasStartedGame = false
        elapsedTime = 0.0
        
        // Remove game over UI
        view.subviews.forEach { subview in
            if subview is UILabel && (subview as? UILabel)?.text?.contains("Game Over") == true {
                subview.removeFromSuperview()
            }
            if subview is UIButton && (subview as? UIButton)?.titleLabel?.text == "Try Again" {
                subview.removeFromSuperview()
            }
        }
        
        // Wait for next layout cycle
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        if targetContainerView.bounds.width > 0 {
            hasStartedGame = true
            startTimer()
            commenceNewRound()
        }
    }
    
    func createMovingTile(from tileView: EphemeralTileView) -> EphemeralTileView? {
        guard let containerView = tileView.superview else { return nil }
        let movingTile = EphemeralTileView(value: tileView.tileValue, image: tileView.imageView.image, isAperture: false)
        movingTile.translatesAutoresizingMaskIntoConstraints = true
        movingTile.bounds.size = tileView.bounds.size
        movingTile.center = containerView.convert(tileView.center, to: view)
        view.addSubview(movingTile)
        return movingTile
    }
    
    func destinationPoint(for targetTileView: EphemeralTileView) -> CGPoint {
        guard let superview = targetTileView.superview else {
            return topAreaFallbackPoint()
        }
        return superview.convert(targetTileView.center, to: view)
    }
    
    func topAreaFallbackPoint() -> CGPoint {
        return targetContainerView.convert(CGPoint(x: targetContainerView.bounds.midX,
                                                   y: targetContainerView.bounds.midY),
                                           to: view)
    }
    
    func animateMovingTile(_ movingTile: EphemeralTileView, to destination: CGPoint, completion: @escaping () -> Void) {
        movingTile.transform = .identity
        UIView.animate(withDuration: 0.55,
                       delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.4,
                       options: [.curveEaseInOut],
                       animations: {
            movingTile.center = destination
        }, completion: { _ in
            completion()
        })
    }
    
    func updateTargetTile(_ targetTileView: EphemeralTileView, with sourceTile: EphemeralTileView) {
        UIView.transition(with: targetTileView,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
            targetTileView.imageView.image = sourceTile.imageView.image
            targetTileView.backgroundColor = .clear
            targetTileView.valueLabel.isHidden = true
        })
        targetTileView.removePulsateAnimation()
    }
    
    func updateLabels() {
        scoreLabel.text = "Score: \(currentScore)"
        roundLabel.text = "Round: \(currentRound)"
    }
}

