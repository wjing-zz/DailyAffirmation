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
struct Quote: Decodable {
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
    
    // 使用didSet和UserDefaults来持久化语言选择
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(viewState == .initial ? 1 : 0) // 根据状态控制整个VStack的可见性
                
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
                .opacity(viewState == .content ? 1 : 0) // 根据状态控制整个VStack的可见性
                .animation(.easeIn(duration: 0.8), value: viewState)
            }
            .overlay(alignment: .topTrailing) {
                // 语言选择器作为叠加层，不受主视图布局影响
                if viewState == .content {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.top, geometry.safeAreaInsets.top)
                    .padding(.trailing, 20)
                    .transition(.opacity) // 切换时带有淡入淡出效果
                }
            }
            .onAppear {
                // 在视图加载时启动动画序列
                if let randomHex = colors.randomElement() {
                    self.backgroundColor = Color(hex: randomHex)
                }
                loadQuotes()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showTitle = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showPrompt = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showButton = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
