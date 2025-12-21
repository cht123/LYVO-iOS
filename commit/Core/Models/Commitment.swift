import Foundation

struct Commitment: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var identityStatement: String?
    var category: CommitmentCategory
    let startDate: Date
    var reminderTime: DateComponents
    var stats: CommitmentStats
    var history: [CommitDay]
    
    init(
        id: UUID = UUID(),
        title: String,
        identityStatement: String? = nil,
        category: CommitmentCategory,
        startDate: Date = Date(),
        reminderTime: DateComponents,
        stats: CommitmentStats = CommitmentStats(),
        history: [CommitDay] = []
    ) {
        self.id = id
        self.title = title
        self.identityStatement = identityStatement
        self.category = category
        self.startDate = startDate
        self.reminderTime = reminderTime
        self.stats = stats
        self.history = history
    }
}
