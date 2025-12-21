import Foundation

struct ArchivedCommitment: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let identityStatement: String?
    let category: CommitmentCategory
    let startDate: Date
    let endDate: Date
    let totalCommittedDays: Int
    let longestStreak: Int
    let completionType: CompletionType
    
    init(
        id: UUID = UUID(),
        title: String,
        identityStatement: String? = nil,
        category: CommitmentCategory,
        startDate: Date,
        endDate: Date = Date(),
        totalCommittedDays: Int,
        longestStreak: Int,
        completionType: CompletionType
    ) {
        self.id = id
        self.title = title
        self.identityStatement = identityStatement
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.totalCommittedDays = totalCommittedDays
        self.longestStreak = longestStreak
        self.completionType = completionType
    }
    
    /// Create from active commitment
    static func from(_ commitment: Commitment, completionType: CompletionType) -> ArchivedCommitment {
        ArchivedCommitment(
            id: commitment.id,
            title: commitment.title,
            identityStatement: commitment.identityStatement,
            category: commitment.category,
            startDate: commitment.startDate,
            endDate: Date(),
            totalCommittedDays: commitment.stats.totalCommittedDays,
            longestStreak: commitment.stats.longestStreak,
            completionType: completionType
        )
    }
}
