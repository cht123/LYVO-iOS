import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var service: CommitmentService
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showingNewCommitmentSheet = false
    @State private var showingArchiveSheet = false
    
    var body: some View {
        ZStack {
            // Show onboarding on first launch
            if !hasSeenOnboarding {
                OnboardingView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasSeenOnboarding = true
                    }
                })
            } else {
                // Main content
                Group {
                    if let commitment = service.activeCommitment {
                        ActiveCommitmentView(service: service)
                    } else {
                        EmptyStateView(
                            onCreateCommitment: { showingNewCommitmentSheet = true },
                            onShowArchive: { showingArchiveSheet = true }
                        )
                    }
                }
                .animation(CommitAnimations.smooth, value: service.activeCommitment?.id)
            }
        }
        .commitBackground()
        .sheet(isPresented: $showingNewCommitmentSheet) {
            NewCommitmentView()
        }
        .sheet(isPresented: $showingArchiveSheet) {
            ArchiveView()
        }
    }
}
