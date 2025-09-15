import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedLanguage: Language // 接收 ContentView 传递的语言状态
    
    @State private var selectedTime: Date = {
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            return savedTime
        }
        return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(LocalizedText.setReminderTime.localizedString(for: selectedLanguage))
                    .font(.title2)
                    .fontWeight(.bold)
                
                DatePicker(LocalizedText.setReminderTime.localizedString(for: selectedLanguage), selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                Button(LocalizedText.saveReminder.localizedString(for: selectedLanguage)) {
                    saveReminder()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                // test button
                Button("Reset App Data (for testing)") {
                    resetUserDefaults()
                }
                .padding()
                .foregroundColor(.red)
                
                Spacer()
            }
            .padding()
            .navigationTitle(LocalizedText.settingsTitle.localizedString(for: selectedLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedText.done.localizedString(for: selectedLanguage)) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func saveReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permission granted!")
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                
                let content = UNMutableNotificationContent()
                content.title = LocalizedText.dailyAffirmationTitle.localizedString(for: selectedLanguage)
                content.body = LocalizedText.dailyAffirmationPrompt.localizedString(for: selectedLanguage)
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error adding notification: \(error)")
                    } else {
                        print("Daily reminder scheduled successfully!")
                        UserDefaults.standard.set(selectedTime, forKey: "reminderTime")
                    }
                }
            } else if let error = error {
                print("Permission denied: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview Provider
struct SettingsView_Previews: PreviewProvider {
    @State static var selectedLanguage: Language = .chinese
    
    static var previews: some View {
        SettingsView(selectedLanguage: $selectedLanguage)
    }
}

