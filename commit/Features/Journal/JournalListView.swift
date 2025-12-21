import SwiftUI

/// View showing all micro-journal entries for a commitment
struct JournalListView: View {
    let commitmentId: UUID
    let commitmentTitle: String
    @ObservedObject private var journalService = MicroJournalService.shared
    @ObservedObject private var paywallService = PaywallService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    let haptics = HapticService()
                    haptics.selection()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .thin))
                        .foregroundColor(CommitTheme.Colors.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.20))
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            CommitTheme.Colors.white.opacity(0.08),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .shadow(color: Color.black.opacity(0.20), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                
                Spacer()
                
                Text("Journal")
                    .font(CommitTheme.Typography.title2)
                    .foregroundColor(CommitTheme.Colors.white)
                
                Spacer()
                
                // Spacer to balance close button
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, CommitTheme.Spacing.l)
            .padding(.top, CommitTheme.Spacing.l)
            
            // Commitment title
            Text(commitmentTitle)
                .font(CommitTheme.Typography.callout)
                .foregroundColor(CommitTheme.Colors.whiteMedium)
                .padding(.top, CommitTheme.Spacing.s)
            
            if entries.isEmpty {
                // Empty state
                VStack(spacing: CommitTheme.Spacing.l) {
                    Spacer()
                    
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(CommitTheme.Colors.whiteDim)
                    
                    Text("No journal entries yet")
                        .font(CommitTheme.Typography.headline)
                        .foregroundColor(CommitTheme.Colors.whiteMedium)
                    
                    Text("After each daily ritual, capture your thoughts in a brief reflection")
                        .font(CommitTheme.Typography.callout)
                        .foregroundColor(CommitTheme.Colors.whiteDim)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CommitTheme.Spacing.xxl)
                    
                    Spacer()
                }
            } else {
                // Journal entries list
                ScrollView {
                    VStack(spacing: CommitTheme.Spacing.m) {
                        ForEach(entries) { entry in
                            JournalEntryCard(entry: entry)
                        }
                    }
                    .padding(.horizontal, CommitTheme.Spacing.l)
                    .padding(.vertical, CommitTheme.Spacing.l)
                }
            }
        }
        .commitBackground()
    }
    
    private var entries: [MicroJournalEntry] {
        if paywallService.hasAccess(to: .unlimitedArchive) {
            return journalService.entries(for: commitmentId)
        } else {
            return journalService.visibleEntries(for: commitmentId)
        }
    }
}

// MARK: - Journal Entry Card

struct JournalEntryCard: View {
    let entry: MicroJournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: CommitTheme.Spacing.s) {
            // Date
            Text(formattedDate)
                .font(CommitTheme.Typography.footnote)
                .foregroundColor(CommitTheme.Colors.whiteDim)
            
            // Entry text
            Text(entry.text)
                .font(CommitTheme.Typography.body)
                .foregroundColor(CommitTheme.Colors.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CommitTheme.Spacing.m)
        .commitCardBackground()
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
}
