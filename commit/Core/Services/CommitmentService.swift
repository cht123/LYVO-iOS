import Foundation
import SwiftUI
import Combine

/// Single source of truth for commitment state, business logic, and persistence
final class CommitmentService: ObservableObject {
    
    // MARK: - Published State
    
    @Published private(set) var activeCommitment: Commitment?
    @Published private(set) var archivedCommitments: [ArchivedCommitment] = []
    @Published private var isCommitting = false
    
    
    // MARK: - Dependencies
    
    private let haptics = HapticService()
    private let notifications = NotificationService.shared
    
    // MARK: - Storage Keys
    
    private let activeKey = "activeCommitment"
    private let archiveKey = "archivedCommitments"
    
    // MARK: - Initialization
    
    init() {
        loadFromDisk()
        
        // Reschedule notifications if there's an active commitment
        // This ensures notifications persist even if iOS clears them
        Task { @MainActor in
            await rescheduleNotificationsIfNeeded()
        }
    }
    
    // MARK: - Notification Management
    
    /// Reschedule notifications for active commitment
    /// Called on app launch to ensure notifications are always active
    @MainActor
    private func rescheduleNotificationsIfNeeded() async {
        guard let commitment = activeCommitment else { return }
        
        // Check if notifications are authorized and enabled
        await notifications.checkAuthorizationStatus()
        
        if notifications.isAuthorized && notifications.notificationsEnabled {
            print("🔄 Rescheduling notifications for active commitment")
            let isPremium = PaywallService.shared.hasAccess(to: .triggerTimeNotifications)
            notifications.scheduleAllReminders(
                title: commitment.title,
                isPremium: isPremium
            )
        }
    }
    
    // MARK: - Computed Properties
    
    var hasActiveCommitment: Bool {
        activeCommitment != nil
    }
    
    var hasCommittedToday: Bool {
        activeCommitment?.stats.hasCommittedToday ?? false
    }
    
    var currentStreak: Int {
        activeCommitment?.stats.currentStreak ?? 0
    }
    
    /// Free tier: Only show last 30 days of archived commitments
    var visibleArchivedCommitments: [ArchivedCommitment] {
        let all = allArchivedCommitments
        if PaywallService.shared.hasAccess(to: .unlimitedArchive) {
            return all
        }
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return all.filter { $0.endDate >= cutoff }
    }
    
    /// Count of archived commitments hidden behind paywall
    var hiddenArchiveCount: Int {
        allArchivedCommitments.count - visibleArchivedCommitments.count
    }
    
    /// All archived commitments (for premium users)
    var allArchivedCommitments: [ArchivedCommitment] {
        return archivedCommitments
    }
    
 
    // MARK: - Commitment Creation
    
    @MainActor
    func createCommitment(
        title: String,
        identityStatement: String?,
        category: CommitmentCategory,
        reminderTime: DateComponents
    ) {
        let commitment = Commitment(
            title: title,
            identityStatement: identityStatement,
            category: category,
            reminderTime: reminderTime
        )
        
        activeCommitment = commitment
        saveToDisk()
        
        // Convert DateComponents to Date and update NotificationService preferred time
        let calendar = Calendar.current
        if let hour = reminderTime.hour, let minute = reminderTime.minute {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            if let reminderDate = calendar.date(from: components) {
                print("📅 Setting preferred notification time to \(hour):\(String(format: "%02d", minute))")
                // Update NotificationService with the chosen time
                notifications.preferredTime = reminderDate
            }
        }
        
        // Schedule notification - this will request authorization if needed
        Task {
            print("🔔 Starting notification setup...")
            // Request authorization first
            if !notifications.isAuthorized {
                print("🔐 Requesting notification authorization...")
                let granted = await notifications.requestAuthorization()
                if granted {
                    print("✅ Authorization granted")
                    // Enable notifications and schedule
                    notifications.notificationsEnabled = true
                    let isPremium = PaywallService.shared.hasAccess(to: .triggerTimeNotifications)
                    notifications.scheduleAllReminders(title: title, isPremium: isPremium)
                } else {
                    print("❌ Authorization denied")
                }
            } else {
                print("✅ Already authorized")
                // Already authorized, just enable and schedule
                notifications.notificationsEnabled = true
                let isPremium = PaywallService.shared.hasAccess(to: .triggerTimeNotifications)
                notifications.scheduleAllReminders(title: title, isPremium: isPremium)
            }
        }
        
        // Success haptic
        haptics.success()
    }
    
    // MARK: - Daily Commit Action
    
    @MainActor
    func commitToday() {
        guard !isCommitting else { return }
        guard var commitment = activeCommitment else { return }
        guard !commitment.stats.hasCommittedToday else { return }
        
        isCommitting = true
        defer { isCommitting = false }
        
        let today = Date().startOfDay
        
        // Prevent duplicate entries
        guard !commitment.history.contains(where: { $0.date.startOfDay == today }) else {
            return
        }
        
        // Add history entry
        let entry = CommitDay(date: today, didCommit: true)
        commitment.history.append(entry)
        
        // Update streak logic
        if let lastCommit = commitment.stats.lastCommitDate,
           lastCommit.isYesterday {
            commitment.stats.currentStreak += 1
        } else {
            commitment.stats.currentStreak = 1
        }
        
        // Update stats
        commitment.stats.totalCommittedDays += 1
        commitment.stats.longestStreak = max(
            commitment.stats.longestStreak,
            commitment.stats.currentStreak
        )
        commitment.stats.lastCommitDate = today
        
        // Save and haptic feedback
        activeCommitment = commitment
        saveToDisk()
        haptics.impact(.medium)
    }
    
    // MARK: - Commitment Completion
    
    @MainActor
    func finishCommitment() {
        guard let commitment = activeCommitment else { return }
        archiveCommitment(commitment, type: .finished)
        haptics.success()
    }
    
    @MainActor
    func resetCommitment() {
        guard let commitment = activeCommitment else { return }
        archiveCommitment(commitment, type: .reset)
        haptics.warning()
    }
    
    @MainActor
    func abandonCommitment() {
        guard let commitment = activeCommitment else { return }
        archiveCommitment(commitment, type: .abandoned)
        haptics.warning()
    }
    
    private func archiveCommitment(_ commitment: Commitment, type: CompletionType) {
        let archived = ArchivedCommitment.from(commitment, completionType: type)
        archivedCommitments.insert(archived, at: 0)
        activeCommitment = nil
        notifications.cancelAllReminders()
        saveToDisk()
    }
    
    // MARK: - Archive Management
    
    /// Delete an archived commitment and its associated journal entries
    @MainActor
    func deleteArchivedCommitment(_ archived: ArchivedCommitment) {
        archivedCommitments.removeAll { $0.id == archived.id }
        
        // Also delete associated journal entries
        MicroJournalService.shared.deleteEntries(for: archived.id)
        
        saveToDisk()
        haptics.warning()
    }
    
    /// Delete archived commitment by ID
    @MainActor
    func deleteArchivedCommitment(id: UUID) {
        if let archived = archivedCommitments.first(where: { $0.id == id }) {
            deleteArchivedCommitment(archived)
        }
    }
    
    // MARK: - Persistence
    
    private func loadFromDisk() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        // Load active commitment
        if let data = defaults.data(forKey: activeKey),
           let decoded = try? decoder.decode(Commitment.self, from: data) {
            activeCommitment = decoded
        }
        
        // Load archived commitments
        if let data = defaults.data(forKey: archiveKey),
           let decoded = try? decoder.decode([ArchivedCommitment].self, from: data) {
            archivedCommitments = decoded
        }
    }
    
    private func saveToDisk() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        // Save active commitment
        if let commitment = activeCommitment,
           let data = try? encoder.encode(commitment) {
            defaults.set(data, forKey: activeKey)
        } else {
            defaults.removeObject(forKey: activeKey)
        }
        
        // Save archived commitments
        if let data = try? encoder.encode(archivedCommitments) {
            defaults.set(data, forKey: archiveKey)
        }
    }
}


