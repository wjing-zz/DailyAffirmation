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

struct ContentView: View {
    // 你提供的颜色列表
    let colors = ["#c1cbd7", "#afb0b2", "#939391", "#bfbfbf", "#e0e5df"]
    
    // 状态变量
    @State private var backgroundColor: Color = Color(hex: "#c1cbd7")
    @State private var currentQuote: Quote?
    @State private var selectedLanguage: Language = .chinese
    
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
                
                // 语言选择下拉菜单
                VStack {
                    HStack {
                        Spacer()
                        Picker("Language", selection: $selectedLanguage) {
                            ForEach(Language.allCases, id: \.self) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.top, geometry.safeAreaInsets.top)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
                
                // 中间白色区域和文字
                VStack(spacing: 15) {
                    if let quote = currentQuote {
                        switch selectedLanguage {
                        case .chinese:
                            Text(quote.chinese)
                                .font(.title)
                                .fontWeight(.bold)
                        case .english:
                            Text(quote.english)
                                .font(.title)
                                .fontWeight(.bold)
                        case .bilingual:
                            Text(quote.chinese)
                                .font(.title)
                                .fontWeight(.bold)
                            Text(quote.english)
                                .font(.headline)
                                .padding(.top, 5)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        Text("加载中...")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            .onAppear {
                if let randomHex = colors.randomElement() {
                    self.backgroundColor = Color(hex: randomHex)
                }
                loadQuotes()
            }
        }
    }
}

#Preview {
    ContentView()
}
