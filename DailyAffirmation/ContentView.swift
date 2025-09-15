import SwiftUI

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
struct Quote: Decodable, Encodable { // 增加了Encodable以便存储到UserDefaults
    let chinese: String
    let english: String
}

// MARK: - ViewState Enum for screen control
enum ViewState {
    case initial
    case content
}

struct ContentView: View {
    // 你提供的颜色列表
    let colors = ["#c1cbd7", "#afb0b2", "#939391", "#bfbfbf", "#e0e5df"]
    
    // 状态变量
    @State private var backgroundColor: Color = Color(hex: "#c1cbd7")
    @State private var currentQuote: Quote?
    
    @State private var selectedLanguage: Language = {
        if let savedLanguageRawValue = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let savedLanguage = Language(rawValue: savedLanguageRawValue) {
            return savedLanguage
        }
        return .chinese // 默认语言
    }() {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        }
    }
    
    // 新增状态变量来控制视图的显示阶段
    @State private var viewState: ViewState = .initial
    @State private var showTitle: Bool = false
    @State private var showPrompt: Bool = false
    @State private var showButton: Bool = false
    
    // 一个函数用来从JSON文件加载数据
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
    
    // 新增函数来加载或生成每日一念
    func getDailyAffirmation() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDrawDate = UserDefaults.standard.object(forKey: "lastDrawDate") as? Date {
            let lastDrawDay = Calendar.current.startOfDay(for: lastDrawDate)
            
            if today == lastDrawDay {
                // 如果是同一天，加载已保存的语录
                if let savedQuoteData = UserDefaults.standard.data(forKey: "dailyQuote"),
                   let savedQuote = try? JSONDecoder().decode(Quote.self, from: savedQuoteData) {
                    self.currentQuote = savedQuote
                    self.viewState = .content
                }
            } else {
                // 如果是新的一天，执行动画序列
                startInitialAnimation()
            }
        } else {
            // 如果从未抽取过，执行动画序列
            startInitialAnimation()
        }
    }
    
    // 新增函数来保存今天的语录和日期
    func saveDailyAffirmation() {
        guard let quote = currentQuote else { return }
        if let encoded = try? JSONEncoder().encode(quote) {
            UserDefaults.standard.set(encoded, forKey: "dailyQuote")
            UserDefaults.standard.set(Date(), forKey: "lastDrawDate")
        }
    }
    
    // 启动初始动画
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
                // 背景层
                backgroundColor
                    .ignoresSafeArea()
                
                // 初始屏幕
                VStack(spacing: 30) {
                    Text("每日一念")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .scaleEffect(showTitle ? 1.0 : 0.8)
                        .opacity(showTitle ? 1 : 0)
                        .animation(.easeOut(duration: 0.8), value: showTitle)
                    
                    Text("深呼吸，抽出今日一念")
                        .font(.title3)
                        .scaleEffect(showPrompt ? 1.0 : 0.8)
                        .opacity(showPrompt ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: showPrompt)
                    
                    Button(action: {
                        loadQuotes() // 在抽取时加载新的语录
                        saveDailyAffirmation() // 保存新抽取的语录
                        
                        // 按钮点击后，隐藏初始屏幕，并显示内容
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
                        Text("抽")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(Color.black.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .opacity(showButton ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: showButton)
                    .disabled(viewState != .initial) // 只有在初始状态下按钮才可点击
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(viewState == .initial ? 1 : 0)
                
                // 主要内容屏幕
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
                        Text("加载中...")
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
                if viewState == .content {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.top, geometry.safeAreaInsets.top)
                    .padding(.trailing, 20)
                    .transition(.opacity)
                }
            }
            .onAppear {
                if let randomHex = colors.randomElement() {
                    self.backgroundColor = Color(hex: randomHex)
                }
                getDailyAffirmation() // 在视图出现时，决定加载或生成新的语录
            }
        }
    }
}

#Preview {
    ContentView()
}
