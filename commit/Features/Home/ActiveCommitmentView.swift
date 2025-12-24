import SwiftUI
import AVFoundation

struct ActiveCommitmentView: View {
    @ObservedObject var service: CommitmentService
    @StateObject private var animationState = CommitAnimationState()
    @ObservedObject private var paywallService = PaywallService.shared
    @ObservedObject private var journalService = MicroJournalService.shared
    
    // Reflection animation states
    @State private var isReflecting = false
    @State private var showReflectionText = false
    @State private var showConfirmationText = false
    @State private var showingArchive = false
    @State private var showFinishModal = false
    @State private var showingSettings = false
    @State private var reflectionProgress: CGFloat = 0
    @State private var showCompletionFlash = false
    @State private var showParticles = false
    @State private var showAlreadyCommittedRipple = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var showJournalTeaser = false
    @State private var paywallContext: PaywallContext = .general
    @State private var showOptionsMenu = false
    
    
    // Micro-journaling states
    @State private var showJournalModal = false
    @State private var showingJournalList = false
    @State private var showPaywall = false

    // Post-ritual retap state
    @State private var hasRetappedToday = false
    
    // Make commitment optional to prevent crash
    var commitment: Commitment? {
        service.activeCommitment
    }
    
    /// Check if this is the user's first ritual (never committed before)
    private var isFirstRitual: Bool {
        guard let commitment = commitment else { return true }
        return service.currentStreak == 0 && !service.hasCommittedToday
    }
    
    /// Check if hint should show (first ritual and not currently reflecting)
    private var shouldShowHint: Bool {
        isFirstRitual && !isReflecting && !showConfirmationText
    }
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Title
                if let commitment = commitment {
                    Text(commitment.title)
                        .font(CommitTheme.Typography.title)
                        .foregroundColor(CommitTheme.Colors.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CommitTheme.Spacing.xl)
                        .opacity(animationState.contentFaded ? 1 : 0)
                    
                    // Identity statement
                    if let identity = commitment.identityStatement {
                        Text(identity)
                            .font(CommitTheme.Typography.body)
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CommitTheme.Spacing.xl)
                            .padding(.top, CommitTheme.Spacing.m)
                            .opacity(animationState.contentFaded ? 1 : 0)
                    }
                }
                
                Spacer()
                
                // The commit dot with beautiful reflection animation
                ZStack {
                    // Outer subtle glow - only during reflection
                    if isReflecting {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        CommitTheme.Colors.white.opacity(0.25),
                                        CommitTheme.Colors.white.opacity(0.15),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                            .scaleEffect(isReflecting ? 1.3 : 0.7)
                            .opacity(isReflecting ? 1.0 : 0.0)
                            .animation(
                                .easeInOut(duration: 2.5)
                                    .repeatForever(autoreverses: true),
                                value: isReflecting
                            )
                    }
                    
                    // Completion flash - brief white ring flash at 100%
                    if showCompletionFlash {
                        Circle()
                            .stroke(CommitTheme.Colors.white, lineWidth: 3)
                            .frame(width: 225, height: 225)
                            .scaleEffect(showCompletionFlash ? 1.15 : 1.0)
                            .opacity(showCompletionFlash ? 0 : 1)
                    }
                    
                    // Emanating particles - subtle dots radiating out
                    if showParticles {
                        CompletionParticles()
                    }
                    
                    // Already committed ripple effect
                    
                        Circle()
                            .stroke(CommitTheme.Colors.accent.opacity(0.5), lineWidth: 2)
                            .frame(width: 225, height: 225)
                            .scaleEffect(showAlreadyCommittedRipple ? 2.0 : 1.0)
                            .opacity(showAlreadyCommittedRipple ? 0.8 : 0.0)
                            .animation(.easeOut(duration: 0.6), value: showAlreadyCommittedRipple)
                    
                    
                    // Progress ring during reflection
                    if isReflecting {
                        Circle()
                            .trim(from: 0, to: reflectionProgress)
                            .stroke(
                                CommitTheme.Colors.white.opacity(0.4),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round)
                            )
                            .frame(width: 225, height: 225)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    // The actual commit dot (with streak counter inside)
                    CommitDotView(
                        streak: service.currentStreak,
                        animationState: animationState,
                        onTap: handleCommitTap
                    )
                    .scaleEffect(isReflecting ? 1.12 : 0.98)
                    .opacity(isReflecting ? 0.85 : 1.0)
                    .animation(
                        .easeInOut(duration: 2.5)
                            .repeatForever(autoreverses: true),
                        value: isReflecting
                    )
                }
                .padding(.vertical, CommitTheme.Spacing.xl)
                
                // Text messages with transitions
                ZStack {
                    // First-time hint text
                    if shouldShowHint {
                        Text("Tap to begin your ritual")
                            .font(CommitTheme.Typography.callout)
                            .foregroundColor(CommitTheme.Colors.whiteDim)
                            .transition(.opacity)
                    }
                    
                    // Reflection text
                    if showReflectionText {
                        Text("Reflect on your commitment")
                            .font(CommitTheme.Typography.callout)
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                            .transition(.opacity)
                    }
                    
                    // Confirmation text - crossfade between messages
                    if showConfirmationText {
                        ZStack {
                            Text("See you tomorrow")
                                .opacity(hasRetappedToday ? 0 : 1)

                            Text("Return tomorrow to renew your commitment")
                                .opacity(hasRetappedToday ? 1 : 0)
                        }
                        .font(CommitTheme.Typography.callout)
                        .foregroundColor(CommitTheme.Colors.whiteMedium)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.6), value: hasRetappedToday)
                    }
                }
                .frame(height: 24)
                .animation(.easeInOut(duration: 1.0), value: shouldShowHint)
                .animation(.easeInOut(duration: 1.0), value: showReflectionText)
                .animation(.easeInOut(duration: 1.0), value: showConfirmationText)
                
                if showJournalTeaser, let commitment = commitment {
                    JournalTeaser(
                        onTap: {
                            showJournalTeaser = false
                            paywallContext = .microJournaling
                            showPaywall = true
                        },
                        entriesRemaining: JournalTeaser.entriesRemaining(for: commitment.id)
                    )
                    .padding(.top, CommitTheme.Spacing.l)
                    .transition(.opacity)
                }
                Spacer()
                
                // Bottom spacer to maintain layout (removed Finish button)
                Spacer()
                    .frame(height: CommitTheme.Spacing.xxl)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Settings button in top-left
            VStack {
                HStack {
                    Button {
                        let haptics = HapticService()
                        haptics.selection()
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.20))
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                CommitTheme.Colors.white.opacity(0.08),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.20), radius: 12, x: 0, y: 6)
                    }
                    .padding(CommitTheme.Spacing.l)
                    .opacity(animationState.contentFaded ? 1 : 0)
                    
                    Spacer()
                    
                    // Journal button - only show if premium or has entries
                    if paywallService.hasAccess(to: .microJournaling) || hasJournalEntries {
                        Button {
                            let haptics = HapticService()
                            haptics.selection()
                            showingJournalList = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(CommitTheme.Colors.whiteMedium)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.20))
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    CommitTheme.Colors.white.opacity(0.08),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.20), radius: 12, x: 0, y: 6)
                        }
                        .opacity(animationState.contentFaded ? 1 : 0)
                    }
                    
                    // Options menu (Archive + Finish) in top-right
                    Menu {
                        Button {
                            let haptics = HapticService()
                            haptics.selection()
                            showingArchive = true
                        } label: {
                            Label("View Archive", systemImage: "archivebox")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            let haptics = HapticService()
                            haptics.warning()
                            showFinishModal = true
                        } label: {
                            Label("Finish Commitment", systemImage: "checkmark.circle")
                        }
                    } label: {
                        CommitArchiveIcon()
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.20))
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                CommitTheme.Colors.white.opacity(0.08),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.20), radius: 12, x: 0, y: 6)
                    }
                    .padding(.trailing, CommitTheme.Spacing.l)
                    .opacity(animationState.contentFaded ? 1 : 0)
                }
                
                Spacer()
            }
        }
        .overlay {
            if showFinishModal {
                FinishCommitmentModal(
                    onConfirm: {
                        showFinishModal = false
                        service.finishCommitment()
                    },
                    onCancel: {
                        showFinishModal = false
                    }
                )
                .animation(.easeInOut(duration: 0.3), value: showFinishModal)
            }
            
            // Micro-journal modal after ritual completion
            if showJournalModal, let commitment = commitment {
                MicroJournalModal(
                    commitmentId: commitment.id,
                    onSave: { text in
                        saveJournalEntry(text)
                    },
                    onDismiss: {
                        showJournalModal = false
                    }
                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showJournalModal)
            }
        }
        .sheet(isPresented: $showingArchive) {
            ArchiveView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingJournalList) {
            if let commitment = commitment {
                JournalListView(
                    commitmentId: commitment.id,
                    commitmentTitle: commitment.title
                )
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(context: paywallContext)
        }
        .onAppear {
            animationState.startInitialAnimation()
            
            // Reset UI state for new day
            resetDailyState()
            
            // If already committed today, show confirmation
            if service.hasCommittedToday {
                showConfirmationText = true
                animationState.showCommittedState()
            }
        }
        .onChange(of: service.hasCommittedToday) { oldValue, newValue in
            // Handle app coming to foreground on a new day
            if oldValue && !newValue {
                resetDailyState()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                resetDailyState()
            }
        }
    }
    
    // MARK: - Reset State for New Day
    
    private func resetDailyState() {
        // Reset all ritual-related state
        isReflecting = false
        showReflectionText = false
        showConfirmationText = false
        reflectionProgress = 0
        showCompletionFlash = false
        showParticles = false
        showJournalModal = false
        showAlreadyCommittedRipple = false
        showJournalTeaser = false
        hasRetappedToday = false
        
        // Reset animation state - don't show streak until user commits today
        if !service.hasCommittedToday {
            animationState.showStreak = false
            animationState.isCommitted = false
        }
    }
    
    // MARK: - Commit Action
    
    /// Check if current commitment has any journal entries
    private var hasJournalEntries: Bool {
        guard let commitment = commitment else { return false }
        return !journalService.entries(for: commitment.id).isEmpty
    }
    
    private func handleCommitTap() {
        let haptics = HapticService()

        // If already committed, show gentle ripple feedback
        if service.hasCommittedToday {
            haptics.warning()

            // On first retap, change the confirmation text
            if !hasRetappedToday {
                hasRetappedToday = true
            }

            // Trigger the ripple animation
            showAlreadyCommittedRipple = true

            // Reset after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showAlreadyCommittedRipple = false
            }
            return
        }
        
        // Start reflection phase
        isReflecting = true
        showReflectionText = true
        reflectionProgress = 0
        
        // Animate progress ring over 15 seconds
        withAnimation(.linear(duration: 15.0)) {
            reflectionProgress = 1.0
        }
        
        // Perform the actual commit (includes haptics)
        animationState.performCommitAnimation {
            service.commitToday()
        }
        
        // At 14.8 seconds, trigger completion animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 14.8) {
            // Play custom gong sound
            SoundService.shared.playCompletionGong()
            
            // Trigger completion flash
            withAnimation(.easeOut(duration: 0.3)) {
                showCompletionFlash = true
            }
            
            // Show particles
            showParticles = true
            
            // Hide flash and particles after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCompletionFlash = false
                showParticles = false
            }
        }
        
        // After 15 seconds, transition to confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            // Fade out reflection text
            withAnimation(.easeOut(duration: 1.0)) {
                showReflectionText = false
            }
            
            // After reflection text fades out, fade in confirmation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Stop breathing AS streak appears
                withAnimation(.easeOut(duration: 1.0)) {
                    isReflecting = false
                    reflectionProgress = 0
                    animationState.breatheEffect = false
                }
                
                withAnimation(.easeIn(duration: 1.0)) {
                    showConfirmationText = true
                    animationState.showCommittedState()
                }
                
                // Show micro-journal modal after 1 second delay (if premium)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showJournalModalIfAllowed()
                }
            }
        }
    }
    
    // MARK: - Micro-Journaling
    
    private func showJournalModalIfAllowed() {
        guard let commitment = commitment else { return }
        
        let entryCount = journalService.entries(for: commitment.id).count
        let freeEntryLimit = 10
        
        // Premium users always get the modal
        if paywallService.hasAccess(to: .microJournaling) {
            showJournalModal = true
            return
        }
        
        // Free users within limit get the modal
        if entryCount < freeEntryLimit {
            showJournalModal = true
        } else {
            // User has hit the limit, show teaser on specific days
            if JournalTeaser.shouldShow(forStreak: service.currentStreak) {
                showJournalTeaser = true
            }
        }
    }
    
    private func saveJournalEntry(_ text: String) {
        guard let commitment = commitment else { return }
        journalService.saveTodaysEntry(text, for: commitment.id)
        showJournalModal = false
    }
}

// MARK: - Completion Particles

struct CompletionParticles: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                ParticleDot(angle: Double(index) * 45)
                    .opacity(isAnimating ? 0 : 1)
                    .scaleEffect(isAnimating ? 2.0 : 1.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Individual Particle Dot

struct ParticleDot: View {
    let angle: Double
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(CommitTheme.Colors.white)
            .frame(width: 4, height: 4)
            .offset(x: cos(angle * .pi / 180) * (112.5 + offset),
                    y: sin(angle * .pi / 180) * (112.5 + offset))
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    offset = 40
                }
            }
    }
}
