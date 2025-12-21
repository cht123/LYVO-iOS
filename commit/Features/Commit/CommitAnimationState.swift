import SwiftUI
import Combine

/// Manages the animation state for the commitment dot interaction
final class CommitAnimationState: ObservableObject {
    
    // MARK: - Animation States
    
    @Published var isCommitted: Bool = false
    @Published var showStreak: Bool = false
    @Published var showConfirmation: Bool = false
    @Published var breatheEffect: Bool = false
    @Published var contentFaded: Bool = false
    
    // MARK: - Animation Control
    
    @MainActor
    func reset() {
        isCommitted = false
        showStreak = false
        showConfirmation = false
        breatheEffect = false
        contentFaded = false
    }
    
    @MainActor
    func startInitialAnimation() {
        // Fade in content
        withAnimation(CommitAnimations.fadeIn.delay(0.1)) {
            contentFaded = true
        }
        
        // Start breathing effect
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            breatheEffect = true
        }
    }
    
    @MainActor
    func showCommittedState(withStreak: Bool = true) {
        isCommitted = true
        
        // Briefly delay for the tap animation
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            withAnimation(CommitAnimations.fadeIn) {
                showStreak = withStreak
            }
            
            // Show confirmation message
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            withAnimation(CommitAnimations.fadeIn) {
                showConfirmation = true
            }
        }
    }
    
    @MainActor
    func performCommitAnimation(completion: @escaping () -> Void) {
        // Trigger commit animation sequence
        withAnimation(CommitAnimations.springBouncy) {
            isCommitted = true
        }
        
        // Call completion after brief delay
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            completion()
        }
    }
}
