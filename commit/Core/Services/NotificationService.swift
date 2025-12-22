import UserNotifications
import Foundation
import SwiftUI
import Combine

/// Represents a single reminder time slot
struct ReminderSlot: Codable, Identifiable, Equatable {
    let id: String  // "primary", "morning", "midday", "evening"
    var time: Date
    var isEnabled: Bool
    var label: String
    
    static func defaultSlots() -> [ReminderSlot] {
        let calendar = Calendar.current
        
        // Morning: 7:00 AM
        var morningComponents = DateComponents()
        morningComponents.hour = 7
        morningComponents.minute = 0
        let morningTime = calendar.date(from: morningComponents) ?? Date()
        
        // Midday: 12:00 PM
        var middayComponents = DateComponents()
        middayComponents.hour = 12
        middayComponents.minute = 0
        let middayTime = calendar.date(from: middayComponents) ?? Date()
        
        // Evening: 7:00 PM
        var eveningComponents = DateComponents()
        eveningComponents.hour = 19
        eveningComponents.minute = 0
        let eveningTime = calendar.date(from: eveningComponents) ?? Date()
        
        return [
            ReminderSlot(id: "morning", time: morningTime, isEnabled: true, label: "Morning"),
            ReminderSlot(id: "midday", time: middayTime, isEnabled: false, label: "Midday"),
            ReminderSlot(id: "evening", time: eveningTime, isEnabled: false, label: "Evening")
        ]
    }
}

/// Manages local notifications for daily commitment reminders
@MainActor
final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationService()
    
    // MARK: - Published State
    
    @Published var isAuthorized: Bool = false
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    /// Primary reminder time (free tier)
    @Published var preferredTime: Date {
        didSet {
            UserDefaults.standard.set(preferredTime, forKey: "preferredNotificationTime")
        }
    }
    
    /// Additional reminder slots (premium tier)
    @Published var reminderSlots: [ReminderSlot] {
        didSet {
            saveReminderSlots()
        }
    }
    
    // MARK: - Private Properties
    
    private let center = UNUserNotificationCenter.current()
    private let notificationIdentifier = "dailyCommitReminder"
    private let reminderSlotsKey = "reminderSlots"
    
    // MARK: - Initialization
    
    private override init() {
        // Load saved preferences
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        // Default to 9:00 AM if no saved time
        if let savedTime = UserDefaults.standard.object(forKey: "preferredNotificationTime") as? Date {
            self.preferredTime = savedTime
        } else {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            self.preferredTime = Calendar.current.date(from: components) ?? Date()
        }
        
        // Load reminder slots or use defaults
        if let data = UserDefaults.standard.data(forKey: reminderSlotsKey),
           let slots = try? JSONDecoder().decode([ReminderSlot].self, from: data) {
            self.reminderSlots = slots
        } else {
            self.reminderSlots = ReminderSlot.defaultSlots()
        }
        
        super.init()
        
        // Set self as delegate to handle foreground notifications
        center.delegate = self
        
        // Check initial authorization status
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Persistence
    
    private func saveReminderSlots() {
        if let data = try? JSONEncoder().encode(reminderSlots) {
            UserDefaults.standard.set(data, forKey: reminderSlotsKey)
        }
    }
    
    // MARK: - Slot Management
    
    func updateSlot(id: String, time: Date? = nil, isEnabled: Bool? = nil) {
        guard let index = reminderSlots.firstIndex(where: { $0.id == id }) else { return }
        
        if let time = time {
            reminderSlots[index].time = time
        }
        if let isEnabled = isEnabled {
            reminderSlots[index].isEnabled = isEnabled
        }
    }
    
    func slot(for id: String) -> ReminderSlot? {
        reminderSlots.first { $0.id == id }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notifications when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification tap
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Clear badge when notification is tapped
        Task { @MainActor in
            self.center.setBadgeCount(0)
        }
        completionHandler()
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus()
            return granted
        } catch {
            #if DEBUG
            print("Error requesting notification authorization: \(error)")
            #endif
            return false
        }
    }
    
    // MARK: - Schedule Single Reminder (Free Tier)
    
    func scheduleReminder(at time: DateComponents, title: String) {
        guard notificationsEnabled else { return }
        
        Task {
            // Ensure authorization
            if !isAuthorized {
                let granted = await requestAuthorization()
                guard granted else {
                    notificationsEnabled = false
                    return
                }
            }
            
            // Cancel existing reminders
            cancelAllReminders()
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = "Time to Commit"
            content.body = title
            content.sound = .default
            content.badge = 1
            
            // Create trigger (repeats daily)
            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            
            // Create request
            let request = UNNotificationRequest(
                identifier: notificationIdentifier,
                content: content,
                trigger: trigger
            )
            
            // Schedule
            do {
                try await center.add(request)
                #if DEBUG
                print("✓ Notification scheduled for \(time.hour ?? 9):\(String(format: "%02d", time.minute ?? 0))")

                // Log pending notifications for debugging
                let pending = await center.pendingNotificationRequests()
                print("📋 Pending notifications: \(pending.count)")
                for notification in pending {
                    print("   - \(notification.identifier): \(notification.trigger?.description ?? "no trigger")")
                }
                #endif
            } catch {
                #if DEBUG
                print("Failed to schedule reminder: \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    /// Schedule notification using user's preferred time from settings
    func scheduleWithPreferredTime(title: String) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: preferredTime)
        let minute = calendar.component(.minute, from: preferredTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        scheduleReminder(at: dateComponents, title: title)
    }
    
    // MARK: - Schedule Multiple Reminders (Premium Tier)
    
    /// Schedule all enabled reminder slots (for premium users)
    func scheduleAllReminders(title: String, isPremium: Bool) {
        guard notificationsEnabled else { return }
        
        Task {
            // Ensure authorization
            if !isAuthorized {
                let granted = await requestAuthorization()
                guard granted else {
                    notificationsEnabled = false
                    return
                }
            }
            
            // Cancel existing reminders
            cancelAllReminders()
            
            // Always schedule primary reminder
            await scheduleNotification(
                identifier: "\(notificationIdentifier)-primary",
                time: preferredTime,
                title: title
            )
            
            // Schedule additional slots if premium
            if isPremium {
                for slot in reminderSlots where slot.isEnabled {
                    await scheduleNotification(
                        identifier: "\(notificationIdentifier)-\(slot.id)",
                        time: slot.time,
                        title: title
                    )
                }
            }
            
            // Log scheduled notifications
            #if DEBUG
            let pending = await center.pendingNotificationRequests()
            print("📋 Scheduled \(pending.count) reminder(s)")
            for notification in pending {
                if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                    let hour = trigger.dateComponents.hour ?? 0
                    let minute = trigger.dateComponents.minute ?? 0
                    print("   - \(notification.identifier): \(hour):\(String(format: "%02d", minute))")
                }
            }
            #endif
        }
    }
    
    /// Schedule a single notification
    private func scheduleNotification(identifier: String, time: Date, title: String) async {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Commit"
        content.body = title
        content.sound = .default
        content.badge = 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
        } catch {
            #if DEBUG
            print("Failed to schedule reminder \(identifier): \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Cancel Reminders
    
    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        center.setBadgeCount(0)
    }
    
    // MARK: - Settings Navigation
    
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Debug Helpers
    
    #if DEBUG
    /// Force trigger a test notification for debugging
    func debugTriggerTestNotification() {
        Task {
            let content = UNMutableNotificationContent()
            content.title = "Test Notification"
            content.body = "This is a test notification"
            content.sound = .default
            
            // Trigger in 5 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "test-\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await center.add(request)
                print("🧪 Test notification scheduled for 5 seconds from now")
            } catch {
                print("Failed to schedule test notification: \(error)")
            }
        }
    }
    
    /// Print pending notifications for debugging
    func debugPrintPendingNotifications() {
        Task {
            let pending = await center.pendingNotificationRequests()
            print("📋 Pending notifications (\(pending.count)):")
            for notification in pending {
                if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                    print("   - \(notification.identifier): \(trigger.dateComponents)")
                } else {
                    print("   - \(notification.identifier): \(notification.trigger?.description ?? "no trigger")")
                }
            }
        }
    }
    #endif
}

