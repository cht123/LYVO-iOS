import Foundation
import SwiftUI
import Combine

/// Manages micro-journal entries across commitments
final class MicroJournalService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = MicroJournalService()
    
    // MARK: - Published State
    
    @Published private(set) var journal: MicroJournal = MicroJournal()
    
    // MARK: - Storage
    
    private let storageKey = "microJournal"
    
    // MARK: - Initialization
    
    private init() {
        loadFromDisk()
    }
    
    // MARK: - Public API
    
    /// Save a journal entry for today's commitment
    func saveTodaysEntry(_ text: String, for commitmentId: UUID) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        journal.setTodaysEntry(text, commitmentId: commitmentId)
        saveToDisk()
    }
    
    /// Get today's entry for a commitment
    func todaysEntry(for commitmentId: UUID) -> MicroJournalEntry? {
        let calendar = Calendar.current
        return journal.entries(for: commitmentId).first { 
            calendar.isDateInToday($0.date) 
        }
    }
    
    /// Get all entries for a commitment
    func entries(for commitmentId: UUID) -> [MicroJournalEntry] {
        journal.entries(for: commitmentId)
    }
    
    /// Get entries within the last 30 days (free tier)
    func visibleEntries(for commitmentId: UUID) -> [MicroJournalEntry] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return journal.entries(for: commitmentId).filter { $0.date >= thirtyDaysAgo }
    }
    
    /// Delete all entries for a commitment (when commitment is deleted)
    func deleteEntries(for commitmentId: UUID) {
        journal.entries.removeAll { $0.commitmentId == commitmentId }
        saveToDisk()
    }
    
    /// Delete a specific entry
    func deleteEntry(_ entry: MicroJournalEntry) {
        journal.entries.removeAll { $0.id == entry.id }
        saveToDisk()
    }
    
    // MARK: - Persistence
    
    private func loadFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(MicroJournal.self, from: data) else {
            return
        }
        journal = decoded
    }
    
    private func saveToDisk() {
        guard let data = try? JSONEncoder().encode(journal) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
