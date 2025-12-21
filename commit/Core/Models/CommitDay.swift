import Foundation

struct CommitDay: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let didCommit: Bool
    
    init(id: UUID = UUID(), date: Date, didCommit: Bool) {
        self.id = id
        self.date = date
        self.didCommit = didCommit
    }
}
