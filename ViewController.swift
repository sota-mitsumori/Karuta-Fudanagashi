import UIKit

class ViewController: UIViewController {

    var cardImages: [UIImage] = []
    var currentCardIndex: Int = 0
    var startTime: Date?
    var endTime: Date?
    var bestScore: TimeInterval?
    
    var imageView: UIImageView!
    var startButton: UIButton!
    var endButton: UIButton!
    var messageLabel: UILabel!
    var timerLabel: UILabel!
    var cardsLeftLabel: UILabel!
    
    var gameTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load card images
        for i in 1...100 {
            let imageName = "torifuda\(i)"
            if let image = UIImage(named: imageName) {
                cardImages.append(image)
            } else {
                print("Image \(imageName) not found")
            }
        }
        
        // Shuffle the cards
        cardImages.shuffle()
        
        // Initialize UI components
        setupUI()
        
        // Load best score
        loadBestScore()
    }
    
    func setupUI() {
        // Set up imageView
        imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        
        // Set start image
        imageView.image = UIImage(named: "finish_photo")
        
        // Set up startButton
        startButton = UIButton(type: .system)
        startButton.setTitle("Start", for: .normal)
        
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        startButton.frame = CGRect(x: self.view.bounds.midX - 100, y: self.view.bounds.midY + 20, width: 200, height: 50)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        self.view.addSubview(startButton)
        // Add border to startButton
        startButton.layer.borderWidth = 2.0
        startButton.layer.borderColor = UIColor.black.cgColor
        startButton.layer.cornerRadius = 10.0
        self.view.addSubview(startButton)
        
        // Set up messageLabel
        messageLabel = UILabel()
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 24)
        messageLabel.numberOfLines = 0
        messageLabel.frame = CGRect(x: 0, y: self.view.bounds.midY - 50, width: self.view.bounds.width, height: 100)
        self.view.addSubview(messageLabel)
        messageLabel.isHidden = true
        
        // Set up timerLabel
        timerLabel = UILabel()
        timerLabel.textAlignment = .right
        timerLabel.font = UIFont.systemFont(ofSize: 24)
        timerLabel.frame = CGRect(x: self.view.bounds.width - 170, y: 50, width: 150, height: 30)
        self.view.addSubview(timerLabel)
        
        // Hide timerLabel initially
        timerLabel.isHidden = true
        
        // Set up cardsLeftLabel
        cardsLeftLabel = UILabel()
        cardsLeftLabel.textAlignment = .left
        cardsLeftLabel.font = UIFont.systemFont(ofSize: 24)
        cardsLeftLabel.frame = CGRect(x: 20, y: 50, width: 200, height: 30)
        cardsLeftLabel.isHidden = true
        self.view.addSubview(cardsLeftLabel)
        
        // Set up endButton (New)
        endButton = UIButton(type: .system)
        endButton.setTitle("End", for: .normal)
        endButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        endButton.translatesAutoresizingMaskIntoConstraints = false
        endButton.addTarget(self, action: #selector(endButtonTapped), for: .touchUpInside)
        // Add border to endButton
        endButton.layer.borderWidth = 2.0
        endButton.layer.borderColor = UIColor.black.cgColor
        endButton.layer.cornerRadius = 10.0
        self.view.addSubview(endButton)
        endButton.isHidden = true // Hide initially
        
        // Constraints for messageLabel
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
            messageLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
        
        // Constraints for endButton
        NSLayoutConstraint.activate([
            endButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            endButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            endButton.widthAnchor.constraint(equalToConstant: 200),
            endButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        // Set up gestures
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .right // Swipe right to go to next card
        self.view.addGestureRecognizer(swipeGesture)
        
        // Set up tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func startButtonTapped() {
        // Start the game
        startTime = Date()
        currentCardIndex = 0
        endTime = nil
        timerLabel.isHidden = false
        startButton.isHidden = true
        messageLabel.isHidden = true
        cardsLeftLabel.isHidden = false
        endButton.isHidden = true
        // Shuffle the cards
        cardImages.shuffle()
        showCurrentCard()
        // Start timer to update timerLabel
        startTimer()
    }
    
    @objc func endButtonTapped() {
        // Return to start screen
        startButton.setTitle("Start", for: .normal)
        startButton.isHidden = false
        messageLabel.isHidden = true
        imageView.image = UIImage(named: "finish_photo")
        endButton.isHidden = true
    }
    
    func showCurrentCard() {
        if currentCardIndex < cardImages.count {
            var image = cardImages[currentCardIndex]
            // Randomly rotate image by 180 degrees
            if Bool.random() {
                if let cgImage = image.cgImage {
                    image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .down)
                }
            }
            imageView.image = image
            // Update cards left label
            let cardsLeft = cardImages.count - currentCardIndex
            cardsLeftLabel.text = "Cards Left: \(cardsLeft)"
        } else {
            // Game over
            endTime = Date()
            showFinishScreen()
        }
    }
    
    func showFinishScreen() {
        // Calculate elapsed time
        if let startTime = startTime, let endTime = endTime {
            let elapsedTime = endTime.timeIntervalSince(startTime)
            // Check if best score
            if bestScore == nil || elapsedTime < bestScore! {
                bestScore = elapsedTime
                saveBestScore()
            }
            
            // Display finish image
            imageView.image = UIImage(named: "finish_photo")
            // Display message
            messageLabel.text = "Finished!\nTime: \(String(format: "%.2f", elapsedTime)) s\nBest Score: \(String(format: "%.2f", bestScore!)) s"
            messageLabel.isHidden = false
            // Show start button again to restart
            startButton.isHidden = false
            startButton.setTitle("Restart", for: .normal)
            // Hide timer label and cards left label
            timerLabel.isHidden = true
            cardsLeftLabel.isHidden = true
            endButton.isHidden = false
            // Stop timer
            stopTimer()
        }
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if startTime != nil && endTime == nil {
            currentCardIndex += 1
            showCurrentCard()
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if startTime != nil && endTime == nil {
            currentCardIndex += 1
            showCurrentCard()
        }
    }
    
    func startTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    @objc func updateTimerLabel() {
        if let startTime = startTime {
            let elapsedTime = Date().timeIntervalSince(startTime)
            timerLabel.text = String(format: "Time: %.2f s", elapsedTime)
        }
    }
    
    func loadBestScore() {
        let defaults = UserDefaults.standard
        bestScore = defaults.value(forKey: "bestScore") as? TimeInterval
    }

    func saveBestScore() {
        let defaults = UserDefaults.standard
        if let bestScore = bestScore {
            defaults.set(bestScore, forKey: "bestScore")
        }
    }
}
