import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedLanguage: Language
    var resetAction: () -> Void
    
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
                .background(Color.black) // 修改为黑色
                .foregroundColor(.white)
                .cornerRadius(10)
                
                // 重置按钮
                Button(LocalizedText.resetAppData.localizedString(for: selectedLanguage)) {
                    resetAction()
                    dismiss()
                }
                .padding()
                .background(Color.black) // 修改为黑色
                .foregroundColor(.white)
                .cornerRadius(10)
                
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
                    .tint(.black) // 改变导航栏按钮的颜色
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
        SettingsView(selectedLanguage: $selectedLanguage, resetAction: {})
    }
}
