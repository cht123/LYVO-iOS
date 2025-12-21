import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject private var service: CommitmentService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCommitment: ArchivedCommitment?
    @State private var commitmentToDelete: ArchivedCommitment?
    @State private var showDeleteConfirmation = false
    @State private var showPaywall = false
    @ObservedObject private var paywallService = PaywallService.shared
    
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
                        .shadow(
                            color: Color.black.opacity(0.20),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel("Close")
                .accessibilityHint("Returns to main screen")
                
                
                
                Spacer()
                
                Text("Archive")
                    .font(CommitTheme.Typography.title2)
                    .foregroundColor(CommitTheme.Colors.white)
                
                Spacer()
                
                // Spacer to balance close button
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, CommitTheme.Spacing.l)
            .padding(.top, CommitTheme.Spacing.l)
            
            if service.visibleArchivedCommitments.isEmpty {
                // Empty state
                VStack(spacing: CommitTheme.Spacing.l) {
                    Spacer()
                    
                    Image(systemName: "archivebox")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(CommitTheme.Colors.whiteDim)
                    
                    Text("No archived commitments yet")
                        .font(CommitTheme.Typography.headline)
                        .foregroundColor(CommitTheme.Colors.whiteMedium)
                    
                    Text("Completed commitments will appear here")
                        .font(CommitTheme.Typography.callout)
                        .foregroundColor(CommitTheme.Colors.whiteDim)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CommitTheme.Spacing.xxl)
                    
                    Spacer()
                }
            } else {
                // Archive list
                ScrollView {
                    VStack(spacing: CommitTheme.Spacing.m) {
                        ForEach(service.visibleArchivedCommitments) { archived in
                            ArchivedCommitmentCard(
                                archived: archived,
                                onTap: {
                                    let haptics = HapticService()
                                    haptics.selection()
                                    selectedCommitment = archived
                                    
                                },
                                onDelete: {
                                    commitmentToDelete = archived
                                    showDeleteConfirmation = true
                                }
                            )
                        }
                        if service.hiddenArchiveCount > 0 {
                            ArchivePaywallCard(
                                hiddenCount: service.hiddenArchiveCount,
                                onTap: {
                                    showPaywall = true
                                }
                            )
                            .padding(.top, CommitTheme.Spacing.s)
                        }
                    }
                    .padding(.horizontal, CommitTheme.Spacing.l)
                    .padding(.vertical, CommitTheme.Spacing.l)
                }
            }
        }
        .commitBackground()
        .sheet(item: $selectedCommitment) { commitment in
            JournalListView(
                commitmentId: commitment.id,
                commitmentTitle: commitment.title
            )
        }
        .alert("Delete Commitment", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                commitmentToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let commitment = commitmentToDelete {
                    service.deleteArchivedCommitment(commitment)
                }
                commitmentToDelete = nil
            }
        } message: {
            Text("This will permanently delete this commitment and all associated journal entries. This cannot be undone.")
        }
    }
}

// MARK: - Archived Commitment Card

struct ArchivedCommitmentCard: View {
    let archived: ArchivedCommitment
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @ObservedObject private var journalService = MicroJournalService.shared
    
    /// Check if this commitment has any journal entries
    private var hasJournalEntries: Bool {
        !journalService.entries(for: archived.id).isEmpty
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: CommitTheme.Spacing.m) {
                
                // Header with category and completion type
                HStack {
                    Text(archived.category.emoji)
                        .font(.system(size: 24))
                    
                    // Journal indicator
                    if hasJournalEntries {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14))
                            .foregroundColor(CommitTheme.Colors.emerald)
                    }
                    
                    Spacer()
                    
                    CompletionBadge(type: archived.completionType)
                }
                
                // Title
                Text(archived.title)
                    .font(CommitTheme.Typography.headline)
                    .foregroundColor(CommitTheme.Colors.white)
                    .multilineTextAlignment(.leading)
                
                // Identity statement
                if let identity = archived.identityStatement {
                    Text(identity)
                        .font(CommitTheme.Typography.callout)
                        .foregroundColor(CommitTheme.Colors.whiteMedium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Stats
                HStack(spacing: CommitTheme.Spacing.l) {
                    StatLabel(
                        icon: "flame.fill",
                        value: "\(archived.longestStreak)",
                        label: "Best Streak"
                    )
                    
                    StatLabel(
                        icon: "checkmark.circle.fill",
                        value: "\(archived.totalCommittedDays)",
                        label: "Days"
                    )
                }
                .padding(.top, CommitTheme.Spacing.xs)
                
                // Dates
                Text(dateRangeString)
                    .font(CommitTheme.Typography.footnote)
                    .foregroundColor(CommitTheme.Colors.whiteDim)
                    .padding(.top, CommitTheme.Spacing.xs)
            }
            .padding(CommitTheme.Spacing.m)
            .commitCardBackground()
        }
        .buttonStyle(ScaleButtonStyle())
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            if hasJournalEntries {
                Button {
                    onTap()
                } label: {
                    Label("View Journal", systemImage: "square.and.pencil")
                }
            }
        }
    }
    
    private var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let start = formatter.string(from: archived.startDate)
        let end = formatter.string(from: archived.endDate)
        return "\(start) – \(end)"
    }
}

// MARK: - Completion Badge

struct CompletionBadge: View {
    let type: CompletionType
    
    var body: some View {
        Text(type.displayName)
            .font(CommitTheme.Typography.footnote)
            .foregroundColor(color)
            .padding(.horizontal, CommitTheme.Spacing.xs)
            .padding(.vertical, CommitTheme.Spacing.xxs)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
    
    private var color: Color {
        switch type {
        case .finished:
            return CommitTheme.Colors.emerald
        case .reset:
            return Color.yellow
        case .abandoned:
            return Color.red.opacity(0.8)
        }
    }
}

// MARK: - Stat Label

struct StatLabel: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: CommitTheme.Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(CommitTheme.Colors.emerald)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(CommitTheme.Typography.captionMedium)
                    .foregroundColor(CommitTheme.Colors.white)
                
                Text(label)
                    .font(CommitTheme.Typography.footnote)
                    .foregroundColor(CommitTheme.Colors.whiteDim)
            }
        }
    }
}
