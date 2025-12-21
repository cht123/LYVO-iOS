//
//  JournalTeaser.swift
//  commit
//
//  Created by Michael Taylor on 11/30/25.
//


import SwiftUI

/// Soft paywall teaser shown post-ritual for users approaching or at journal limit
struct JournalTeaser: View {
    let onTap: () -> Void
    var entriesRemaining: Int? = nil
    @State private var isVisible = false
    
    var body: some View {
        Button(action: {
            let haptics = HapticService()
            haptics.selection()
            onTap()
        }) {
            HStack(spacing: CommitTheme.Spacing.m) {
                // Journal icon
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(CommitTheme.Colors.emerald)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text("Capture this moment")
                        .font(CommitTheme.Typography.callout)
                        .foregroundColor(CommitTheme.Colors.white)
                    
                    Text(subtitleText)
                        .font(CommitTheme.Typography.caption)
                        .foregroundColor(CommitTheme.Colors.whiteDim)
                }
                
                Spacer()
                
                // Badge - shows remaining entries or Premium
                if let remaining = entriesRemaining, remaining > 0 {
                    Text("\(remaining) left")
                        .font(CommitTheme.Typography.footnote)
                        .foregroundColor(CommitTheme.Colors.whiteMedium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(CommitTheme.Colors.white.opacity(0.1))
                        )
                } else {
                    Text("Premium")
                        .font(CommitTheme.Typography.footnote)
                        .foregroundColor(CommitTheme.Colors.emerald)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(CommitTheme.Colors.emerald.opacity(0.15))
                        )
                }
            }
            .padding(CommitTheme.Spacing.l)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                CommitTheme.Colors.emerald.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, CommitTheme.Spacing.xl)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                isVisible = true
            }
        }
    }
    
    private var subtitleText: String {
        if let remaining = entriesRemaining {
            if remaining == 0 {
                return "Unlock unlimited journaling"
            } else if remaining <= 3 {
                return "\(remaining) free entries remaining"
            }
        }
        return "Reflect deeper with journaling"
    }
}

// MARK: - Teaser Display Logic

extension JournalTeaser {
    /// Determines if the journal teaser should show based on current streak
    /// Shows on days 1, 3, 5, 7, 14, 21, 30, then every 30 days
    static func shouldShow(forStreak streak: Int) -> Bool {
        // Early days - light introduction
        let introductionDays = [1, 3, 5]
        
        // Milestone days
        let milestoneDays = [7, 14, 21, 30]
        
        // Check intro days
        if introductionDays.contains(streak) {
            return true
        }
        
        // Check milestone days
        if milestoneDays.contains(streak) {
            return true
        }
        
        // After 30, show every 30 days
        if streak > 30 && streak % 30 == 0 {
            return true
        }
        
        return false
    }
    
    /// Calculate remaining free entries for a commitment
    static func entriesRemaining(for commitmentId: UUID) -> Int {
        let freeEntryLimit = 10
        let currentCount = MicroJournalService.shared.entries(for: commitmentId).count
        return max(0, freeEntryLimit - currentCount)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            JournalTeaser(onTap: {}, entriesRemaining: 3)
            JournalTeaser(onTap: {}, entriesRemaining: 0)
            JournalTeaser(onTap: {})
        }
    }
}
