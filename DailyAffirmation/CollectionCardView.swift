import SwiftUI

struct CollectionCardView: View {
    let savedCard: SavedCard
    @Binding var selectedLanguage: Language
    
    @State private var cardRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text(cardRotation == 0 ? LocalizedText.universeReplyReceived.localizedString(for: selectedLanguage) : LocalizedText.universeReceivedCard.localizedString(for: selectedLanguage))
                .customFont(size: 24, weight: .heavy)
            
            ZStack {
                // 原始卡片 (反面)
                CardContent(quote: savedCard.quote, universeReply: nil, language: selectedLanguage)
                    .background(Color(hex: "#e0e5df"))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .rotation3DEffect(.degrees(cardRotation + 180), axis: (x: 0, y: 1, z: 0))
                    .opacity(cardRotation > 90 ? 1 : 0)
                
                // 宇宙回信卡片 (正面)
                if savedCard.universeReply != nil {
                    CardContent(quote: nil, universeReply: savedCard.universeReply, language: selectedLanguage)
                        .background(Color.yellow)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
                        .opacity(cardRotation <= 90 ? 1 : 0)
                } else {
                    CardContent(quote: savedCard.quote, universeReply: nil, language: selectedLanguage)
                        .background(Color(hex: "#e0e5df"))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
            }
            .frame(width: 300, height: 200)
            .onTapGesture {
                if savedCard.universeReply != nil {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        cardRotation = cardRotation == 0 ? 180 : 0
                    }
                }
            }
        }
        .navigationTitle(LocalizedText.collectionTitle.localizedString(for: selectedLanguage))
        .customFont(size: 20, weight: .heavy)
        .navigationBarTitleDisplayMode(.inline)
    }
}
