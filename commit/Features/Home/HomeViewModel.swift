import SwiftUI
import Combine

/// ViewModel for the home screen
@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var showingNewCommitmentSheet = false
    @Published var showingArchiveSheet = false
    
    // Reference to the service
    private let service: CommitmentService
    
    init(service: CommitmentService) {
        self.service = service
    }
    
    // MARK: - Actions
    
    func showNewCommitmentFlow() {
        showingNewCommitmentSheet = true
    }
    
    func showArchive() {
        showingArchiveSheet = true
    }
}
