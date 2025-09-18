import SwiftUI

struct CollectionListView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLanguage: Language
    
    @State private var savedCards: [SavedCard] = []
    
    // 用于格式化日期
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    private func loadSavedCards() {
        if let savedData = UserDefaults.standard.data(forKey: "savedCards"),
           let loadedCards = try? JSONDecoder().decode([SavedCard].self, from: savedData) {
            self.savedCards = loadedCards
        } else {
            self.savedCards = []
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if savedCards.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash.fill")
                            .customFont(size: 50)
                            .foregroundColor(.gray)
                        Text(LocalizedText.collectionIsEmpty.localizedString(for: selectedLanguage))
                            .customFont(size: 20)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(savedCards.reversed()) { card in
                            NavigationLink(destination: CollectionCardView(savedCard: card, selectedLanguage: $selectedLanguage)) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(dateFormatter.string(from: card.date))
                                        .customFont(size: 16)
                                        .foregroundColor(.secondary)
                                    
                                    Text(card.quote.chinese)
                                        .customFont(size: 18, weight: .bold)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .listStyle(.inset)
                }
                
                Spacer()
                
                // 存储上限提醒
                if !savedCards.isEmpty {
                    Text(String(format: LocalizedText.maxCollectionReminder.localizedString(for: selectedLanguage), savedCards.count))
                        .customFont(size: 14)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
            .navigationTitle(LocalizedText.collectionTitle.localizedString(for: selectedLanguage))
            .customFont(size: 20, weight: .heavy)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedText.done.localizedString(for: selectedLanguage)) {
                        dismiss()
                    }
                    .customFont(size: 18)
                    .tint(.black)
                }
            }
            .onAppear {
                loadSavedCards()
            }
        }
    }
}
