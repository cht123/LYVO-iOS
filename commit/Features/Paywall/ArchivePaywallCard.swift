//
//  ArchivePaywallCard.swift
//  commit
//
//  Created by Michael Taylor on 12/12/25.
//


import SwiftUI

/// Card shown at bottom of archive when older entries are hidden (free tier)
struct ArchivePaywallCard: View {
    let hiddenCount: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            let haptics = HapticService()
            haptics.selection()
            onTap()
        }) {
            HStack(spacing: CommitTheme.Spacing.m) {
                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CommitTheme.Colors.emerald)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(CommitTheme.Colors.emerald.opacity(0.15))
                    )
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(hiddenCount) earlier \(hiddenCount == 1 ? "commitment" : "commitments")")
                        .font(CommitTheme.Typography.callout)
                        .foregroundColor(CommitTheme.Colors.white)
                    
                    Text("Unlock your complete history")
                        .font(CommitTheme.Typography.caption)
                        .foregroundColor(CommitTheme.Colors.whiteDim)
                }
                
                Spacer()
                
                // Premium badge
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
            .padding(CommitTheme.Spacing.l)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.03))
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
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ArchivePaywallCard(hiddenCount: 12, onTap: {})
            ArchivePaywallCard(hiddenCount: 1, onTap: {})
        }
        .padding()
    }
}