import SwiftUI

@main
struct CommitApp: App {
    @StateObject private var commitmentService = CommitmentService()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(commitmentService)
        }
    }
}
