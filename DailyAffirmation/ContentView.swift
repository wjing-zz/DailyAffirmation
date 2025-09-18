import SwiftUI
import UserNotifications

// MARK: - Color Extension for Hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Language Enum
enum Language: String, CaseIterable {
    case chinese = "中文"
    case english = "English"
    case bilingual = "双语"
}

// MARK: - Quote Struct
struct Quote: Decodable, Encodable {
    let chinese: String
    let english: String
    var sentToUniverse: Bool? = false
}

// MARK: - UniverseReply Struct
struct UniverseReply: Decodable, Encodable {
    let chinese: String
    let english: String
}

// MARK: - ViewState Enum for screen control
enum ViewState {
    case initial
    case content
    case universeReceived
}

// MARK: - LocalizedText Enum
enum LocalizedText {
    case dailyAffirmationTitle
    case dailyAffirmationPrompt
    case drawButton
    case loading
    case settingsTitle
    case setReminderTime
    case saveReminder
    case done
    case sendToUniverse
    case universeReceivedMessage
    case universeReceivedCard
    case universeReplyReceived
    case resetAppData
    case fileNotFound
    case failedToLoad
    case saveToCollection
    case collectionTitle
    case maxCollectionReminder
    case collectionIsEmpty
    
    var chinese: String {
        switch self {
        case .dailyAffirmationTitle: return "每日一念"
        case .dailyAffirmationPrompt: return "深呼吸，抽出今日一念"
        case .drawButton: return "抽"
        case .loading: return "加载中..."
        case .settingsTitle: return "提醒设置"
        case .setReminderTime: return "设置每日提醒时间"
        case .saveReminder: return "保存提醒"
        case .done: return "完成"
        case .sendToUniverse: return "发送给宇宙"
        case .universeReceivedMessage: return "宇宙已收到，祝你拥有愉快的一天。"
        case .universeReceivedCard: return "宇宙收到今日卡片："
        case .universeReplyReceived: return "宇宙回信："
        case .resetAppData: return "重置应用数据（仅测试用）"
        case .fileNotFound: return "文件未找到"
        case .failedToLoad: return "加载失败"
        case .saveToCollection: return "收藏"
        case .collectionTitle: return "我的收藏"
        case .maxCollectionReminder: return "你已收藏 %d 张卡片，本地存储最多支持保存 1000 张。"
        case .collectionIsEmpty: return "收藏夹是空的，去抽卡吧！"
        }
    }
    
    var english: String {
        switch self {
        case .dailyAffirmationTitle: return "Daily Affirmation"
        case .dailyAffirmationPrompt: return "Take a deep breath and draw your daily affirmation"
        case .drawButton: return "Draw"
        case .loading: return "Loading..."
        case .settingsTitle: return "Reminder Settings"
        case .setReminderTime: return "Set Daily Reminder Time"
        case .saveReminder: return "Save Reminder"
        case .done: return "Done"
        case .sendToUniverse: return "Send to Universe"
        case .universeReceivedMessage: return "Universe received! Have a wonderful day."
        case .universeReceivedCard: return "Universe received today's card:"
        case .universeReplyReceived: return "Universe Reply:"
        case .resetAppData: return "Reset App Data (for testing)"
        case .fileNotFound: return "File not found"
        case .failedToLoad: return "Failed to load"
        case .saveToCollection: return "Save to Collection"
        case .collectionTitle: return "My Collection"
        case .maxCollectionReminder: return "You have collected %d cards. The local storage supports up to 1000 cards."
        case .collectionIsEmpty: return "Collection is empty. Go draw a card!"
        }
    }
    
    func localizedString(for language: Language) -> String {
        switch language {
        case .chinese, .bilingual: return self.chinese
        case .english: return self.english
        }
    }
    
    func bilingualString() -> (String, String) {
        return (self.chinese, self.english)
    }
}

// 提取卡片内容的子视图，以便重用
struct CardContent: View {
    var quote: Quote?
    var universeReply: UniverseReply?
    var language: Language
    
    var body: some View {
        VStack(spacing: 15) {
            if let reply = universeReply {
                switch language {
                case .chinese:
                    Text(reply.chinese)
                        .customFont(size: 24, weight: .heavy)
                        .padding(.horizontal)
                case .english:
                    Text(reply.english)
                        .customFont(size: 24, weight: .heavy)
                        .padding(.horizontal)
                case .bilingual:
                    VStack(spacing: 15) {
                        Text(reply.chinese)
                            .customFont(size: 24, weight: .heavy)
                        Text(reply.english)
                            .customFont(size: 20)
                            .padding(.top, 5)
                    }
                    .padding(.horizontal)
                }
            } else if let quote = quote {
                switch language {
                case .chinese:
                    Text(quote.chinese)
                        .customFont(size: 24, weight: .heavy)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                case .english:
                    Text(quote.english)
                        .customFont(size: 24, weight: .heavy)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                case .bilingual:
                    VStack(spacing: 15) {
                        Text(quote.chinese)
                            .customFont(size: 24, weight: .heavy)
                            .fontWeight(.bold)
                        Text(quote.english)
                            .customFont(size: 20)
                            .padding(.top, 5)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
        .frame(width: 300, height: 200)
    }
}

struct ContentView: View {
//    let colors = ["#c1cbd7", "#afb0b2", "#939391", "#bfbfbf", "#e0e5df"]
    
    // 渐变颜色，固定下来，不再是随机色
    let backgroundColor1 = Color(hex: "#b5c4b1")
    let backgroundColor2 = Color(hex: "#e0e5df")
    let backgroundEndColor = Color(hex: "#fcfffc")
    
    @State private var backgroundColor: Color = Color(hex: "#c1cbd7")
    @State private var currentQuote: Quote?
    @State private var universeReply: UniverseReply?
    @State private var isSaved: Bool = false
    
    @State private var selectedLanguage: Language = {
        if let savedLanguageRawValue = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let savedLanguage = Language(rawValue: savedLanguageRawValue) {
            return savedLanguage
        }
        return .chinese
    }() {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        }
    }
    
    @State private var viewState: ViewState = .initial
    @State private var showTitle: Bool = false
    @State private var showPrompt: Bool = false
    @State private var showButton: Bool = false
    @State private var showSettings: Bool = false
    @State private var showCollection: Bool = false
    
    @State private var cardOpacity: Double = 1.0
    @State private var cardOffset: CGSize = .zero
    @State private var cardScale: CGFloat = 1.0
    
    @State private var cardRotation: Double = 0
    @State private var showReplyCard: Bool = true
    
    func loadQuotes() {
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                self.currentQuote = quotes.randomElement()
            } catch {
                print("Error loading or decoding quotes.json: \(error)")
                self.currentQuote = Quote(chinese: LocalizedText.failedToLoad.chinese, english: LocalizedText.failedToLoad.english)
            }
        } else {
            print("Could not find quotes.json in main bundle.")
            self.currentQuote = Quote(chinese: LocalizedText.fileNotFound.chinese, english: LocalizedText.fileNotFound.english)
        }
    }
    
    func loadUniverseReply() -> UniverseReply? {
        if let url = Bundle.main.url(forResource: "universe_replies", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let replies = try JSONDecoder().decode([UniverseReply].self, from: data)
                return replies.randomElement()
            } catch {
                print("Error loading or decoding universe_replies.json: \(error)")
                return nil
            }
        } else {
            print("Could not find universe_replies.json in main bundle.")
            return nil
        }
    }
    
    func getDailyAffirmation() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDrawDate = UserDefaults.standard.object(forKey: "lastDrawDate") as? Date {
            let lastDrawDay = Calendar.current.startOfDay(for: lastDrawDate)
            
            if today == lastDrawDay {
                if let savedQuoteData = UserDefaults.standard.data(forKey: "dailyQuote"),
                   let savedQuote = try? JSONDecoder().decode(Quote.self, from: savedQuoteData) {
                    self.currentQuote = savedQuote
                    
                    if savedQuote.sentToUniverse ?? false {
                        self.viewState = .universeReceived
                        if let savedReplyData = UserDefaults.standard.data(forKey: "universeReply"),
                           let savedReply = try? JSONDecoder().decode(UniverseReply.self, from: savedReplyData) {
                            self.universeReply = savedReply
                            self.cardRotation = 0
                        } else {
                            self.cardRotation = 0
                        }
                    } else {
                        self.viewState = .content
                    }
                    isSaved = checkIfCardIsSaved(quote: savedQuote)
                } else {
                    startInitialAnimation()
                }
            } else {
                startInitialAnimation()
            }
        } else {
            startInitialAnimation()
        }
    }
    
    func saveDailyAffirmation() {
        guard let quote = currentQuote else { return }
        if let encoded = try? JSONEncoder().encode(quote) {
            UserDefaults.standard.set(encoded, forKey: "dailyQuote")
            UserDefaults.standard.set(Date(), forKey: "lastDrawDate")
        }
        
        if let reply = universeReply, let encodedReply = try? JSONEncoder().encode(reply) {
            UserDefaults.standard.set(encodedReply, forKey: "universeReply")
        }
    }
    
    func startInitialAnimation() {
        self.viewState = .initial
        self.cardOpacity = 1.0
        self.cardOffset = .zero
        self.cardScale = 1.0
        self.universeReply = nil
        self.cardRotation = 0
        // MARK: - Change [2/4]: Reset flip state
        self.showReplyCard = true
        self.isSaved = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showTitle = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showPrompt = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showButton = true }
        }
    }
    
    func resetUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        print("UserDefaults has been reset.")
        currentQuote = nil
        startInitialAnimation()
    }
    
    private func saveCurrentCard() {
        guard let quote = currentQuote else { return }
        
        if let savedData = UserDefaults.standard.data(forKey: "savedCards"),
           var savedCards = try? JSONDecoder().decode([SavedCard].self, from: savedData) {
            
            // 检查是否已经收藏过
            if !savedCards.contains(where: { $0.quote.chinese == quote.chinese }) {
                let newCard = SavedCard(date: Date(), quote: quote, universeReply: universeReply)
                savedCards.append(newCard)
                if let encoded = try? JSONEncoder().encode(savedCards) {
                    UserDefaults.standard.set(encoded, forKey: "savedCards")
                    isSaved = true
                }
            }
        } else {
            // 第一次收藏
            let newCard = SavedCard(date: Date(), quote: quote, universeReply: universeReply)
            if let encoded = try? JSONEncoder().encode([newCard]) {
                UserDefaults.standard.set(encoded, forKey: "savedCards")
                isSaved = true
            }
        }
    }
    
    private func checkIfCardIsSaved(quote: Quote) -> Bool {
        if let savedData = UserDefaults.standard.data(forKey: "savedCards"),
           let savedCards = try? JSONDecoder().decode([SavedCard].self, from: savedData) {
            return savedCards.contains(where: { $0.quote.chinese == quote.chinese })
        }
        return false
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // MARK: - 背景渐变
                    RadialGradient(
                        gradient: Gradient(colors: [backgroundColor1, backgroundEndColor]),
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: 500
                    )
                    .ignoresSafeArea()
                    
                    RadialGradient(
                        gradient: Gradient(colors: [backgroundColor2, backgroundEndColor]),
                        center: .bottomTrailing,
                        startRadius: 10,
                        endRadius: 500
                    )
                    .ignoresSafeArea()
                    
                    // MARK: - 初始屏幕
                    VStack(spacing: 30) {
                        Text(LocalizedText.dailyAffirmationTitle.localizedString(for: selectedLanguage))
                            .customFont(size: 36, weight: .heavy)
                            .scaleEffect(showTitle ? 1.0 : 0.8)
                            .opacity(showTitle ? 1 : 0)
                            .animation(.easeOut(duration: 0.8), value: showTitle)
                        
                        Text(LocalizedText.dailyAffirmationPrompt.localizedString(for: selectedLanguage))
                            .customFont(size: 20)
                            .scaleEffect(showPrompt ? 1.0 : 0.8)
                            .opacity(showPrompt ? 1 : 0)
                            .animation(.easeOut(duration: 0.8).delay(0.4), value: showPrompt)
                        
                        Button(action: {
                            loadQuotes()
                            currentQuote?.sentToUniverse = false
                            saveDailyAffirmation()
                            
                            withAnimation(.easeOut(duration: 0.4)) {
                                showTitle = false
                                showPrompt = false
                                showButton = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.easeOut(duration: 0.8)) {
                                    viewState = .content
                                }
                            }
                        }) {
                            Text(LocalizedText.drawButton.localizedString(for: selectedLanguage))
                                .customFont(size: 24, weight: .heavy)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 100)
                                .background(Color.black.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .opacity(showButton ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.8), value: showButton)
                        .disabled(viewState != .initial)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(viewState == .initial ? 1 : 0)
                    
                    // MARK: - 主要内容屏幕
                    if viewState == .content {
                        VStack(spacing: 20) {
                            VStack(spacing: 15) {
                                if let quote = currentQuote {
                                    switch selectedLanguage {
                                    case .chinese:
                                        Text(quote.chinese)
                                            .customFont(size: 24, weight: .heavy)
                                            .padding(.horizontal)
                                    case .english:
                                        Text(quote.english)
                                            .customFont(size: 24, weight: .heavy)
                                            .padding(.horizontal)
                                    case .bilingual:
                                        VStack(spacing: 15) {
                                            Text(quote.chinese)
                                                .customFont(size: 24, weight: .heavy)
                                            Text(quote.english)
                                                .customFont(size: 20)
                                                .padding(.top, 5)
                                        }
                                        .padding(.horizontal)
                                    }
                                } else {
                                    Text(LocalizedText.loading.localizedString(for: selectedLanguage))
                                        .customFont(size: 24)
                                        .fontWeight(.heavy)
                                        .padding(.horizontal)
                                }
                            }
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                            .background(Color.white.opacity(cardOpacity))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .offset(cardOffset)
                            .scaleEffect(cardScale)
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.8)) {
                                    cardOffset = CGSize(width: 0, height: -geometry.size.height * 0.7)
                                    cardOpacity = 0.0
                                    cardScale = 0.5
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    currentQuote?.sentToUniverse = true
                                    
                                    if Int.random(in: 1...100) <= 20 {
                                        self.universeReply = loadUniverseReply()
                                    }
                                    saveDailyAffirmation()
                                    isSaved = checkIfCardIsSaved(quote: currentQuote!)
                                    
                                    withAnimation(.easeIn(duration: 0.8)) {
                                        viewState = .universeReceived
                                    }
                                }
                            }) {
                                Text(LocalizedText.sendToUniverse.chinese)
                                    .customFont(size: 20)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color(hex: "#7b8b6f"))
                            }
                            .transition(.opacity)
                        }
                        .opacity(viewState == .content ? 1 : 0)
                        .animation(.easeIn(duration: 0.8), value: viewState)
                    }
                    
                    // MARK: - 宇宙已收到页面 (可翻转卡片)
                    if viewState == .universeReceived {
                        VStack(spacing: 20) {
                            Text(showReplyCard && universeReply != nil ? LocalizedText.universeReplyReceived.chinese : LocalizedText.universeReceivedCard.chinese)
                                .customFont(size: 24, weight: .heavy)
                            
                            ZStack {
                                // 原始卡片 (反面)
                                CardContent(quote: currentQuote, language: selectedLanguage)
                                    .background(Color(hex: "#e0e5df"))
                                    // .cornerRadius(15)
                                    .shadow(radius: 5)
                                    .rotation3DEffect(.degrees(cardRotation + 180), axis: (x: 0, y: 1, z: 0))
                                    .opacity(cardRotation > 90 ? 1 : 0)
                                
                                // 宇宙回信卡片 (正面)
                                if universeReply != nil {
                                    CardContent(universeReply: universeReply, language: selectedLanguage)
                                        .background(Color.yellow)
                                        .cornerRadius(15)
                                        .shadow(radius: 5)
                                        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
                                        .opacity(cardRotation <= 90 ? 1 : 0)
                                } else {
                                    CardContent(quote: currentQuote, language: selectedLanguage)
                                        .background(Color(hex: "#e0e5df"))
                                        .cornerRadius(15)
                                        .shadow(radius: 5)
                                }
                            }
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                            .onTapGesture {
                                if universeReply != nil {
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        cardRotation = cardRotation == 0 ? 180 : 0
                                    showReplyCard.toggle()
                                    }
                                }
                            }
                            
                            Text(LocalizedText.universeReceivedMessage.chinese)
                                .customFont(size: 20)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                            
                            Button(action: {
                                saveCurrentCard()
                            }) {
                                Image(systemName: isSaved ? "heart.fill" : "heart")
                                    .customFont(size: 24)
                                    .foregroundColor(isSaved ? .red : .gray)
                            }
                            .disabled(isSaved)
                        }
                        .opacity(viewState == .universeReceived ? 1 : 0)
                        .animation(.easeIn(duration: 0.8), value: viewState)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            // if viewState == .content || viewState == .universeReceived {
                            //     Picker("", selection: $selectedLanguage) {
                            //         ForEach(Language.allCases, id: \.self) { language in
                            //             Text(language.rawValue).tag(language)
                            //                 .customFont(size: 16)
                            //         }
                            //     }
                            //     .pickerStyle(.menu)
                            // }
                            
                            Button(action: {
                                showCollection.toggle()
                            }) {
                                Image(systemName: "heart.rectangle.fill")
                                    .customFont(size: 20)
                                    .foregroundColor(.black)
                            }
                            .padding(.trailing, 10)
                            
                            Button(action: {
                                showSettings.toggle()
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .customFont(size: 20)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(selectedLanguage: $selectedLanguage, resetAction: resetUserDefaults)
                }
                .sheet(isPresented: $showCollection) {
                    CollectionListView(selectedLanguage: $selectedLanguage)
                }
                .onAppear {
                    getDailyAffirmation()
                }
            }
        }
    }
}


#Preview {
    ContentView()
}

#Preview {
    ContentView()
}
