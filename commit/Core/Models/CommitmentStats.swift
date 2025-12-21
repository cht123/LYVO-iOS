import Foundation

struct CommitmentStats: Codable, Equatable {
    var currentStreak: Int
    var longestStreak: Int
    var totalCommittedDays: Int
    var lastCommitDate: Date?
    
    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalCommittedDays: Int = 0,
        lastCommitDate: Date? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalCommittedDays = totalCommittedDays
        self.lastCommitDate = lastCommitDate
    }
    
    /// Check if user has committed today
    var hasCommittedToday: Bool {
        guard let lastCommit = lastCommitDate else { return false }
        return Calendar.current.isDateInToday(lastCommit)
    }
}
