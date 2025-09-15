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
}

// MARK: - ViewState Enum for screen control
enum ViewState {
    case initial
    case content
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

struct ContentView: View {
    let colors = ["#c1cbd7", "#afb0b2", "#939391", "#bfbfbf", "#e0e5df"]
    
    @State private var backgroundColor: Color = Color(hex: "#c1cbd7")
    @State private var currentQuote: Quote?
    
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
    
    func loadQuotes() {
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                self.currentQuote = quotes.randomElement()
            } catch {
                print("Error loading or decoding JSON: \(error)")
                self.currentQuote = Quote(chinese: "加载失败", english: "Failed to load")
            }
        } else {
            print("Could not find quotes.json in main bundle.")
            self.currentQuote = Quote(chinese: "文件未找到", english: "File not found")
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
                    self.viewState = .content
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
    }
    
    func startInitialAnimation() {
        self.viewState = .initial
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text(LocalizedText.dailyAffirmationTitle.localizedString(for: selectedLanguage))
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .scaleEffect(showTitle ? 1.0 : 0.8)
                        .opacity(showTitle ? 1 : 0)
                        .animation(.easeOut(duration: 0.8), value: showTitle)
                    
                    Text(LocalizedText.dailyAffirmationPrompt.localizedString(for: selectedLanguage))
                        .font(.title3)
                        .scaleEffect(showPrompt ? 1.0 : 0.8)
                        .opacity(showPrompt ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: showPrompt)
                    
                    Button(action: {
                        loadQuotes()
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
                            .font(.title)
                            .fontWeight(.bold)
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
                
                VStack(spacing: 15) {
                    if let quote = currentQuote {
                        switch selectedLanguage {
                        case .chinese:
                            Text(quote.chinese)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                        case .english:
                            Text(quote.english)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                        case .bilingual:
                            VStack(spacing: 15) {
                                Text(quote.chinese)
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(quote.english)
                                    .font(.headline)
                                    .padding(.top, 5)
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text(LocalizedText.loading.localizedString(for: selectedLanguage))
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                    }
                }
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .shadow(radius: 10)
                .opacity(viewState == .content ? 1 : 0)
                .animation(.easeIn(duration: 0.8), value: viewState)
            }
            .overlay(alignment: .topTrailing) {
                HStack {
                    // 语言选择器
                    if viewState == .content {
                        Picker(LocalizedText.dailyAffirmationTitle.english, selection: $selectedLanguage) {
                            ForEach(Language.allCases, id: \.self) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.top, geometry.safeAreaInsets.top)
                    }
                    
                    // 设置按钮
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(.top, geometry.safeAreaInsets.top)
                    }
                    .padding(.trailing, 20)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(selectedLanguage: $selectedLanguage)
            }
            .onAppear {
                if let randomHex = colors.randomElement() {
                    self.backgroundColor = Color(hex: randomHex)
                }
                getDailyAffirmation()
            }
        }
    }
}

func resetUserDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        defaults.removeObject(forKey: key)
    }
    print("UserDefaults has been reset.")
}

#Preview {
    ContentView()
}
