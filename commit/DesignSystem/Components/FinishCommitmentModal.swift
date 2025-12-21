//
//  FinishCommitmentModal.swift
//  commit
//
//  Created by Michael Taylor on 11/20/25.
//


import SwiftUI

struct FinishCommitmentModal: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.60)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            // Modal card
            VStack(spacing: CommitTheme.Spacing.xl) {
                
                // Title
                Text("Complete this commitment?")
                    .font(CommitTheme.Typography.title2)
                    .foregroundColor(CommitTheme.Colors.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, CommitTheme.Spacing.xl)
                
                // Subtitle
                Text("You can review it anytime in your archive")
                    .font(CommitTheme.Typography.body)
                    .foregroundColor(CommitTheme.Colors.whiteMedium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CommitTheme.Spacing.l)
                
                // Buttons
                VStack(spacing: CommitTheme.Spacing.m) {
                    // Yes button
                    Button(action: onConfirm) {
                        Text("Yes, Complete")
                            .font(CommitTheme.Typography.body)
                            .foregroundColor(CommitTheme.Colors.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(
                                                CommitTheme.Colors.white.opacity(0.20),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // No button
                    Button(action: onCancel) {
                        Text("Not Yet")
                            .font(CommitTheme.Typography.body)
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(
                                                CommitTheme.Colors.white.opacity(0.08),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, CommitTheme.Spacing.xl)
                .padding(.bottom, CommitTheme.Spacing.xl)
            }
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                CommitTheme.Colors.white.opacity(0.12),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(0.40),
                        radius: 32,
                        x: 0,
                        y: 16
                    )
            )
            .padding(.horizontal, CommitTheme.Spacing.xl)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        FinishCommitmentModal(
            onConfirm: { print("Confirmed") },
            onCancel: { print("Cancelled") }
        )
    }
}
