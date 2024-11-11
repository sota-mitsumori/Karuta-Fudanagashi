import SwiftUI
import Combine

class CardGameViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentCardIndex: Int = 0
    @Published var cardOffset: CGSize = .zero
    @Published var cardRotation: Double = 0
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published var bestScore: TimeInterval?
    
    @Published var previousCard: Card?
    @Published var previousCardOffset: CGSize = .zero
    @Published var previousCardRotation: Double = 0
    
    @Published var timerLabel: String = ""
    @Published var cardsLeftLabel: String = ""
    @Published var message: String = ""
    
    @Published var showStartButton: Bool = true
    @Published var showEndButton: Bool = false
    @Published var showTimerLabel: Bool = false
    @Published var showCardsLeftLabel: Bool = false
    @Published var showMessageLabel: Bool = false
    
    @AppStorage("randomRotation") private var randomRotation: Bool = true
    
    var gameTimer: AnyCancellable?
    
    init() {
        loadImages()
        loadBestScore()
    }
    
    func cardImage(at index: Int) -> Image? {
        if index < cards.count {
            let card = cards[index]
            var uiImage = card.image
            if card.isRotated {
                if let cgImage = uiImage.cgImage {
                    uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
                }
            }
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
    
    func image(for card: Card) -> Image {
        var uiImage = card.image
        if card.isRotated {
            if let cgImage = uiImage.cgImage {
                uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
            }
        }
        return Image(uiImage: uiImage)
    }
    
    
// Computed property for the current card image
    var currentCardImage: Image? {
        if currentCardIndex < cards.count {
            let card = cards[currentCardIndex]
            var uiImage = card.image
            // Apply random rotation if needed
            if card.isRotated {
                if let cgImage = uiImage.cgImage {
                    uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
                }
            }
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }

    // Computed property for the next card image
    var nextCardImage: Image? {
        let nextIndex = currentCardIndex + 1
        if nextIndex < cards.count {
            let card = cards[nextIndex]
            var uiImage = card.image
            if card.isRotated {
                if let cgImage = uiImage.cgImage {
                    uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
                }
            }
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
    
    func loadImages() {
        var loadedCards: [Card] = []
        for i in 1...100 {
            let imageName = "torifuda\(i)"
            if let uiImage = UIImage(named: imageName) {
                let isRotated = randomRotation ? Bool.random() : false
                            let card = Card(image: uiImage, isRotated: isRotated)
                            loadedCards.append(card)
            } else {
                print("Image \(imageName) not found")
            }
        }
        cards = loadedCards.shuffled()
    }
    
    func loadBestScore() {
        let defaults = UserDefaults.standard
        if let savedBestScore = defaults.object(forKey: "bestScore") as? TimeInterval {
            bestScore = savedBestScore
        } else {
            bestScore = nil
        }
    }
    
    func resetBestScore() {
        bestScore = nil
        saveBestScore()
    }
    
    func saveBestScore() {
        let defaults = UserDefaults.standard
        if let bestScore = bestScore {
            defaults.set(bestScore, forKey: "bestScore")
        } else {
            defaults.removeObject(forKey: "bestScore")
        }
    }
    
    func startButtonTapped() {
        startTime = Date()
        currentCardIndex = 0
        endTime = nil
        showTimerLabel = true
        showStartButton = false
        showMessageLabel = false
        showCardsLeftLabel = true
        showEndButton = false
        cards.shuffle()
        showCurrentCard()
        startTimer()
    }
    
    func endButtonTapped() {
        startTime = nil
        showStartButton = true
        showMessageLabel = false
//        displayedImage = Image("background")
        showEndButton = false
    }
    
    func showCurrentCard() {
        if currentCardIndex < cards.count {
            // Update cards left label
            let cardsLeft = cards.count - currentCardIndex
            let format = NSLocalizedString("cards_left_format", comment: "Format string for cards left")
            cardsLeftLabel = String.localizedStringWithFormat(format, cardsLeft)
        } else {
            endTime = Date()
            showFinishScreen()
        }
    }
    
    func showFinishScreen() {
        if let startTime = startTime, let endTime = endTime {
            let elapsedTime = endTime.timeIntervalSince(startTime)
            // Check if best score
            if bestScore == nil || bestScore == 0.00 || elapsedTime < bestScore! {
                bestScore = elapsedTime
                saveBestScore()
            }
            
            let timeString = String(format: "%.2f", elapsedTime)
            
            if elapsedTime <= bestScore! {
                message = String(localized: "game_clear_message_best", defaultValue: """
                \(String(localized: "game_clear_title"))
                \(String(format: String(localized: "time_elapsed"), timeString))
                \(String(localized: "best_score"))
                """)
            } else {
                message = String(localized: "game_clear_message_try_again", defaultValue: """
                \(String(localized: "game_clear_title"))
                \(String(format: String(localized: "time_elapsed"), timeString))
                \(String(localized: "try_again"))
                """)
            }
            showMessageLabel = true
            showStartButton = true
            showTimerLabel = false
            showCardsLeftLabel = false
            showEndButton = true
            stopTimer()
        }
    }
    
    func handleSwipe() {
        if startTime != nil && endTime == nil {
            withAnimation(nil) {
                currentCardIndex += 1
            }
            showCurrentCard()
        }
    }
    
    func handleTap() {
        if startTime != nil && endTime == nil {
            currentCardIndex += 1
            showCurrentCard()
        }
    }
    
    func startTimer() {
        stopTimer()
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateTimerLabel()
            }
    }
    
    func stopTimer() {
        gameTimer?.cancel()
        gameTimer = nil
    }
    
    func updateTimerLabel() {
        if let startTime = startTime {
            let elapsedTime = Date().timeIntervalSince(startTime)
            let format = NSLocalizedString("elapsed_time_format", comment: "Format string for elapsed time")
            timerLabel = String.localizedStringWithFormat(format, elapsedTime)
        }
    }
}

struct CardGameView: View {
    @ObservedObject var viewModel = CardGameViewModel()
    @State private var showSettings = false
    @AppStorage("cardLayout") private var cardLayout: String = "Single"
    @AppStorage("randomRotation") private var randomRotation: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.showStartButton {
                    if viewModel.showEndButton{
                        // End Screen Bacground Image
                        Image("background_finish")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width * 0.7)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 3)
                    } else {
                        // Home Screen Background Image
                        Image("background_start")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width * 0.7)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 3)
                    }
                    
                }
                VStack {
                    if !viewModel.showStartButton {
                        singleCardView
                            .padding(.top, 100)
                        Spacer()
                    }
                }
                
                // Timer and Cards Left Labels
                if viewModel.showTimerLabel {
                    VStack {
                        HStack {
                            Text(viewModel.cardsLeftLabel)
                                .font(.system(size: 24))
                                .padding(.leading, 20)
                            Spacer()
                            Text(viewModel.timerLabel)
                                .font(.system(size: 24))
                                .padding(.trailing, 20)
                        }
                        Spacer()
                    }
                }
                
                // Message Label
                if viewModel.showMessageLabel {
                    Text(viewModel.message)
                        .font(.system(size: 24))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .padding(.bottom, 100)
                        .foregroundColor(.black)
                }
                
                // Start Button
                if viewModel.showStartButton {
                    VStack {
                        Spacer()
                        if let bestScore = viewModel.bestScore {
                            Text("ベストスコア: \(String(format: "%.2f", bestScore))秒")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, geometry.size.height * 0.01)
                        } else {
                            Text("さあゲームに挑戦だ！")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, geometry.size.height * 0.01)
                        }
                        Button(action: {
                            viewModel.startButtonTapped()
                        }) {
                            Text(viewModel.startTime == nil ? "スタート" : "もう一回")
                                .font(.system(size: 30))
                                .frame(width: 200, height: 50)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.primary, lineWidth: 2)
                                )
                        }
                        .padding(.bottom, geometry.size.height * 0.14)
                    }
                }
                
                // End Button
                if viewModel.showEndButton {
                    VStack {
                        Spacer()
                        Button(action: {
                            viewModel.endButtonTapped()
                        }) {
                            Text("ホームへ")
                                .font(.system(size: 30))
                                .frame(width: 200, height: 50)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.primary, lineWidth: 2)
                                )
                        }
                        .padding(.bottom, geometry.size.height * 0.02)
                    }
                }
                
            }
            .onChange(of: randomRotation) { newValue in
                viewModel.loadImages()
            }
            // Apply navigation modifiers to NavigationView
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.cardOffset = value.translation
                let angle = atan2(value.translation.height, value.translation.width)
                viewModel.cardRotation = Double(angle * 180 / .pi) / 15
            }
            .onEnded { value in
                let dragDistance = hypot(value.translation.width, value.translation.height)
                if dragDistance > 50 {
                // Store the current card as the previous card
                    viewModel.previousCard = viewModel.cards[ viewModel.currentCardIndex]
                    viewModel.previousCardOffset = viewModel.cardOffset
                    viewModel.previousCardRotation = viewModel.cardRotation
                    withAnimation(.easeOut(duration: 0.3)) {
                        let multiplier: CGFloat = 3.0
                        viewModel.previousCardOffset = CGSize(
                            width: value.translation.width * multiplier,
                            height: value.translation.height * multiplier
                        )
                    }
                    
                    //Prepare the next card immediately
                    viewModel.handleSwipe()
                    
                    // Reset the current card's offset and rotation
                    viewModel.cardOffset = .zero
                    viewModel.cardRotation = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.previousCard = nil
                        viewModel.previousCardOffset = .zero
                        viewModel.previousCardRotation = 0
                    }
                } else {
                    withAnimation(.spring()) {
                        viewModel.cardOffset = .zero
                        viewModel.cardRotation = 0
                    }
                }
            }
    }
    
    var singleCardView: some View {
        ZStack {
            if let nextCard = viewModel.cards[safe: viewModel.currentCardIndex + 1] {
                viewModel.image(for: nextCard)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .animation(nil, value: viewModel.currentCardIndex)
            }
            // Current card with gesture and animation
            if let currentCard = viewModel.cards[safe: viewModel.currentCardIndex] {
                viewModel.image(for: currentCard)
                    .resizable()
                    .scaledToFit()
                    .offset(viewModel.cardOffset)
                    .rotationEffect(.degrees(viewModel.cardRotation))
                    .gesture(dragGesture)
                    .padding()
                    .animation(nil, value: viewModel.currentCardIndex)
                
            }
            
            // Previous card being animated off
            if let previousCard = viewModel.previousCard {
                viewModel.image(for: previousCard)
                    .resizable()
                    .scaledToFit()
                    .offset(viewModel.previousCardOffset)
                    .rotationEffect(.degrees(viewModel.previousCardRotation))
                    .padding()
                    .animation(nil, value: viewModel.previousCardOffset)
            
            }
        }
        .animation(nil, value: viewModel.currentCardIndex)
    }
}

struct Card {
    let image: UIImage
    let isRotated: Bool
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
    
    
struct CardGameView_Previews: PreviewProvider {
    static var previews: some View {
        CardGameView()
    }
}
