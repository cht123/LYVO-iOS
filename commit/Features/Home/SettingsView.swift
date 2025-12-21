import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var commitmentService: CommitmentService
    @StateObject private var notificationService = NotificationService.shared
    @ObservedObject private var paywallService = PaywallService.shared
    @State private var showingPermissionAlert = false
    @State private var showPaywall = false
    @State private var paywallContext: PaywallContext = .general
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: CommitTheme.Spacing.l) {
                    // Header
                    VStack(alignment: .leading, spacing: CommitTheme.Spacing.xs) {
                        Text("Daily Reminder")
                            .font(CommitTheme.Typography.title2)
                            .foregroundColor(CommitTheme.Colors.white)
                        
                        Text("Get reminded to show up for your commitment")
                            .font(CommitTheme.Typography.callout)
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, CommitTheme.Spacing.l)
                    
                    // Enable/Disable Toggle Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Reminder")
                                .font(CommitTheme.Typography.bodyMedium)
                                .foregroundColor(CommitTheme.Colors.white)
                            
                            Text("Receive a notification each day")
                                .font(CommitTheme.Typography.caption)
                                .foregroundColor(CommitTheme.Colors.whiteDim)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationService.notificationsEnabled)
                            .tint(CommitTheme.Colors.emerald)
                            .onChange(of: notificationService.notificationsEnabled) { _, newValue in
                                handleToggleChange(newValue)
                            }
                    }
                    .padding(CommitTheme.Spacing.l)
                    .commitCardBackground()
                    .shadow(
                        color: CommitTheme.Colors.shadow,
                        radius: 20,
                        y: 10
                    )
                    
                    // Time Picker Card (only shown when enabled)
                    if notificationService.notificationsEnabled && notificationService.isAuthorized {
                        VStack(alignment: .leading, spacing: CommitTheme.Spacing.m) {
                            Text("Reminder Time")
                                .font(CommitTheme.Typography.bodyMedium)
                                .foregroundColor(CommitTheme.Colors.white)
                            
                            DatePicker(
                                "",
                                selection: $notificationService.preferredTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .onChange(of: notificationService.preferredTime) { _, _ in
                                // Reschedule notification with new time if there's an active commitment
                                Task {
                                    await rescheduleNotification()
                                }
                            }
                        }
                        .padding(CommitTheme.Spacing.l)
                        .commitCardBackground()
                        .shadow(
                            color: CommitTheme.Colors.shadow,
                            radius: 20,
                            y: 10
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        
                        // Additional Reminders (Premium Feature)
                        additionalRemindersSection
                    }
                    
                    // Premium Section
                    VStack(alignment: .leading, spacing: CommitTheme.Spacing.m) {
                        Text("Premium")
                            .font(CommitTheme.Typography.title2)
                            .foregroundColor(CommitTheme.Colors.white)
                        
                        if paywallService.isPremium {
                            // Premium active state
                            VStack(spacing: CommitTheme.Spacing.m) {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(CommitTheme.Colors.emerald)
                                    Text("Premium Active")
                                        .font(CommitTheme.Typography.bodyMedium)
                                        .foregroundColor(CommitTheme.Colors.white)
                                    Spacer()
                                }
                                .padding(CommitTheme.Spacing.l)
                                .commitCardBackground()
                                
                                // Manage Subscription button (for subscriptions)
                                Button {
                                    let haptics = HapticService()
                                    haptics.selection()
                                    openSubscriptionManagement()
                                } label: {
                                    HStack {
                                        Image(systemName: "gear")
                                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                                        Text("Manage Subscription")
                                            .font(CommitTheme.Typography.bodyMedium)
                                            .foregroundColor(CommitTheme.Colors.white)
                                        Spacer()
                                        Image(systemName: "arrow.up.forward")
                                            .font(.system(size: 12))
                                            .foregroundColor(CommitTheme.Colors.whiteDim)
                                    }
                                    .padding(CommitTheme.Spacing.l)
                                    .commitCardBackground()
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        } else {
                            Button {
                                let haptics = HapticService()
                                haptics.selection()
                                showPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(CommitTheme.Colors.emerald)
                                    Text("Upgrade to Premium")
                                        .font(CommitTheme.Typography.bodyMedium)
                                        .foregroundColor(CommitTheme.Colors.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(CommitTheme.Colors.whiteDim)
                                }
                                .padding(CommitTheme.Spacing.l)
                                .commitCardBackground()
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.top, CommitTheme.Spacing.l)
                    
                    // Debug Section (only in DEBUG builds)
                    #if DEBUG
                    debugSection
                    #endif
                    
                    Spacer()
                }
                .padding(CommitTheme.Spacing.l)
            }
            .commitBackground()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Give haptic feedback
                           let haptics = HapticService()
                           haptics.selection()
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(CommitTheme.Typography.bodyMedium)
                            .foregroundColor(CommitTheme.Colors.emerald)
                    }
                }
            }
        }
        .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
            Button("Cancel", role: .cancel) {
                notificationService.notificationsEnabled = false
            }
            Button("Open Settings") {
                notificationService.openSystemSettings()
            }
        } message: {
            Text("To receive daily reminders, please enable notifications in Settings.")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(context: paywallContext)
        }
        .onAppear {
            // Sync notification settings on appear
            Task {
                await notificationService.checkAuthorizationStatus()
            }
        }
    }
    
    // MARK: - Debug Section
    
    #if DEBUG
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: CommitTheme.Spacing.m) {
            Text("Debug")
                .font(CommitTheme.Typography.title2)
                .foregroundColor(CommitTheme.Colors.white)
            
            Text("Paywall bypass: \(PaywallService.DEBUG_BYPASS_PAYWALL ? "ON" : "OFF")")
                .font(CommitTheme.Typography.caption)
                .foregroundColor(CommitTheme.Colors.whiteDim)
            
            // Toggle Premium Status
            Button {
                let haptics = HapticService()
                haptics.impact(.light)
                paywallService.debugTogglePremium()
            } label: {
                HStack {
                    Image(systemName: paywallService.isPremium ? "crown.fill" : "crown")
                        .foregroundColor(paywallService.isPremium ? CommitTheme.Colors.emerald : CommitTheme.Colors.whiteDim)
                    Text("Toggle Premium: \(paywallService.isPremium ? "ON" : "OFF")")
                        .font(CommitTheme.Typography.bodyMedium)
                        .foregroundColor(CommitTheme.Colors.white)
                    Spacer()
                }
                .padding(CommitTheme.Spacing.m)
                .commitCardBackground()
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Test Notification
            Button {
                let haptics = HapticService()
                haptics.impact(.light)
                notificationService.debugTriggerTestNotification()
            } label: {
                HStack {
                    Image(systemName: "bell.badge")
                        .foregroundColor(CommitTheme.Colors.emerald)
                    Text("Trigger Test Notification (5s)")
                        .font(CommitTheme.Typography.bodyMedium)
                        .foregroundColor(CommitTheme.Colors.white)
                    Spacer()
                }
                .padding(CommitTheme.Spacing.m)
                .commitCardBackground()
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Print Pending Notifications
            Button {
                let haptics = HapticService()
                haptics.impact(.light)
                notificationService.debugPrintPendingNotifications()
            } label: {
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(CommitTheme.Colors.emerald)
                    Text("Print Pending Notifications")
                        .font(CommitTheme.Typography.bodyMedium)
                        .foregroundColor(CommitTheme.Colors.white)
                    Spacer()
                }
                .padding(CommitTheme.Spacing.m)
                .commitCardBackground()
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, CommitTheme.Spacing.l)
    }
    #endif
    
    // MARK: - Additional Reminders Section (Premium)
    
    private var additionalRemindersSection: some View {
        VStack(alignment: .leading, spacing: CommitTheme.Spacing.m) {
            // Header with premium badge
            HStack {
                Text("Additional Reminders")
                    .font(CommitTheme.Typography.bodyMedium)
                    .foregroundColor(CommitTheme.Colors.white)
                
                Spacer()
                
                if !paywallService.hasAccess(to: .triggerTimeNotifications) {
                    Text("Premium")
                        .font(CommitTheme.Typography.caption)
                        .foregroundColor(CommitTheme.Colors.emerald)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(CommitTheme.Colors.emerald.opacity(0.2))
                        )
                }
            }
            
            Text("Set multiple daily reminders for challenging moments")
                .font(CommitTheme.Typography.caption)
                .foregroundColor(CommitTheme.Colors.whiteDim)
            
            if paywallService.hasAccess(to: .triggerTimeNotifications) {
                // Premium: Show reminder slots
                VStack(spacing: CommitTheme.Spacing.s) {
                    ForEach($notificationService.reminderSlots) { $slot in
                        ReminderSlotRow(
                            slot: $slot,
                            onChanged: {
                                Task {
                                    await rescheduleAllNotifications()
                                }
                            }
                        )
                    }
                }
            } else {
                // Non-premium: Show upgrade prompt
                Button {
                    let haptics = HapticService()
                    haptics.selection()
                    paywallContext = .triggerNotifications
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(CommitTheme.Colors.emerald)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Unlock Additional Reminders")
                                .font(CommitTheme.Typography.callout)
                                .foregroundColor(CommitTheme.Colors.white)
                            
                            Text("Morning, midday, and evening")
                                .font(CommitTheme.Typography.caption)
                                .foregroundColor(CommitTheme.Colors.whiteDim)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(CommitTheme.Colors.whiteDim)
                    }
                    .padding(CommitTheme.Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(CommitTheme.Colors.emerald.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(CommitTheme.Colors.emerald.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(CommitTheme.Spacing.l)
        .commitCardBackground()
        .shadow(
            color: CommitTheme.Colors.shadow,
            radius: 20,
            y: 10
        )
    }
    
    // MARK: - Helpers
    
    private func handleToggleChange(_ enabled: Bool) {
        if enabled && !notificationService.isAuthorized {
            Task {
                let granted = await notificationService.requestAuthorization()
                if !granted {
                    showingPermissionAlert = true
                } else {
                    // Schedule notification after authorization granted
                    await rescheduleAllNotifications()
                }
            }
        } else if enabled {
            // If already authorized, just reschedule
            Task {
                await rescheduleAllNotifications()
            }
        }
    }
    
    private func rescheduleNotification() async {
        await rescheduleAllNotifications()
    }
    
    private func rescheduleAllNotifications() async {
        // Get active commitment from service
        if let commitment = commitmentService.activeCommitment {
            notificationService.scheduleAllReminders(
                title: commitment.title,
                isPremium: paywallService.hasAccess(to: .triggerTimeNotifications)
            )
        }
    }
    
    private func openSubscriptionManagement() {
        // Open iOS subscription management
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Reminder Slot Row

struct ReminderSlotRow: View {
    @Binding var slot: ReminderSlot
    let onChanged: () -> Void
    
    @State private var showTimePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(slot.isEnabled ? CommitTheme.Colors.emerald : CommitTheme.Colors.whiteDim)
                    .frame(width: 24)
                
                // Label and time
                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.label)
                        .font(CommitTheme.Typography.callout)
                        .foregroundColor(CommitTheme.Colors.white)
                    
                    if slot.isEnabled {
                        Text(formattedTime)
                            .font(CommitTheme.Typography.caption)
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                    }
                }
                
                Spacer()
                
                // Time picker button (when enabled)
                if slot.isEnabled {
                    Button {
                        let haptics = HapticService()
                        haptics.selection()
                        showTimePicker.toggle()
                    } label: {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                    }
                    .padding(.trailing, CommitTheme.Spacing.s)
                }
                
                // Toggle
                Toggle("", isOn: $slot.isEnabled)
                    .tint(CommitTheme.Colors.emerald)
                    .labelsHidden()
                    .onChange(of: slot.isEnabled) { _, _ in
                        let haptics = HapticService()
                        haptics.selection()
                        onChanged()
                    }
            }
            .padding(.vertical, CommitTheme.Spacing.s)
            
            // Inline time picker
            if showTimePicker && slot.isEnabled {
                DatePicker(
                    "",
                    selection: $slot.time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .frame(height: 120)
                .onChange(of: slot.time) { _, _ in
                    onChanged()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .padding(.horizontal, CommitTheme.Spacing.s)
        .padding(.vertical, CommitTheme.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.03))
        )
        .animation(.easeInOut(duration: 0.2), value: showTimePicker)
    }
    
    private var iconName: String {
        switch slot.id {
        case "morning": return "sunrise.fill"
        case "midday": return "sun.max.fill"
        case "evening": return "sunset.fill"
        default: return "bell.fill"
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: slot.time)
    }
}

#Preview {
    SettingsView()
}

