import SwiftUI
import Combine

class CardGameViewModel: ObservableObject {
    @Published var cardImages: [UIImage] = []
    @Published var currentCardIndex: Int = 0
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published var bestScore: TimeInterval?
    
    @Published var displayedImage: Image?
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
    
    func loadImages() {
        for i in 1...100 {
            let imageName = "torifuda\(i)"
            if let uiImage = UIImage(named: imageName) {
                cardImages.append(uiImage)
            } else {
                print("Image \(imageName) not found")
            }
        }
        cardImages.shuffle()
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
        cardImages.shuffle()
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
        if currentCardIndex < cardImages.count {
            var uiImage = cardImages[currentCardIndex]
            // Randomly rotate image by 180 degrees
            if randomRotation {
                if Bool.random() {
                    if let cgImage = uiImage.cgImage {
                        uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
                    }
                }
            }
            
            displayedImage = Image(uiImage: uiImage)
            // Update cards left label
            let cardsLeft = cardImages.count - currentCardIndex
            cardsLeftLabel = "残り: \(cardsLeft)枚"
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
            if elapsedTime < bestScore! {
                message = """
                クリア!
                時間: \(String(format: "%.2f", elapsedTime))秒
                ベストスコア更新！！
                """
            } else {
                message = """
                クリア!
                時間: \(String(format: "%.2f", elapsedTime))秒
                もう一回挑戦だ！
                """
            }
            displayedImage = nil
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
            currentCardIndex += 1
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
            timerLabel = String(format: "経過時間: %.2f秒", elapsedTime)
        }
    }
}

struct CardGameView: View {
    @ObservedObject var viewModel = CardGameViewModel()
    @State private var showSettings = false
    @AppStorage("cardLayout") private var cardLayout: String = "Single"

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
                    
                } else {
                    // Game Screen Background Color or Image
//                    Color.white
//                        .edgesIgnoringSafeArea(.all)
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
            // Apply navigation modifiers to NavigationView
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: CardGameViewModel())
            }
        }
    }

    var singleCardView: some View {
        Group {
            if let image = viewModel.displayedImage {
                image
                    .resizable()
                    .scaledToFit()
                    .gesture(
                        TapGesture()
                            .onEnded {
                                viewModel.handleTap()
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 0 {
                                    viewModel.handleSwipe()
                                }
                            }
                    )
                    .padding()
            } else {
                EmptyView()
            }
        }
    }
}

struct CardGameView_Previews: PreviewProvider {
    static var previews: some View {
        CardGameView()
    }
}
