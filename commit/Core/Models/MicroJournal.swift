import Foundation

/// A single micro-journal entry attached to a daily commitment
struct MicroJournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let text: String
    let commitmentId: UUID
    
    /// Maximum characters allowed (enforced at UI level)
    static let maxCharacters = 140
    static let minCharacters = 1
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        text: String,
        commitmentId: UUID
    ) {
        self.id = id
        self.date = date
        // Enforce character limit at model level as safety
        self.text = String(text.prefix(Self.maxCharacters))
        self.commitmentId = commitmentId
    }
}

/// Collection of journal entries for a commitment
struct MicroJournal: Codable, Equatable {
    var entries: [MicroJournalEntry]
    
    init(entries: [MicroJournalEntry] = []) {
        self.entries = entries
    }
    
    /// Get entry for a specific date
    func entry(for date: Date) -> MicroJournalEntry? {
        let calendar = Calendar.current
        return entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    /// Get today's entry
    var todaysEntry: MicroJournalEntry? {
        entry(for: Date())
    }
    
    /// Add or update entry for today
    mutating func setTodaysEntry(_ text: String, commitmentId: UUID) {
        // Remove existing entry for today if any
        let calendar = Calendar.current
        entries.removeAll { calendar.isDateInToday($0.date) && $0.commitmentId == commitmentId }
        // Add new entry
        let entry = MicroJournalEntry(text: text, commitmentId: commitmentId)
        entries.append(entry)
        
        // Sort by date descending (newest first)
        entries.sort { $0.date > $1.date }
    }
    
    /// Get all entries for a commitment
    func entries(for commitmentId: UUID) -> [MicroJournalEntry] {
        entries.filter { $0.commitmentId == commitmentId }
    }
}
