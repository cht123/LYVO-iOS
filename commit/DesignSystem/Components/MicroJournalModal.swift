import SwiftUI

/// Modal that appears after the daily commitment ritual to capture a brief reflection
struct MicroJournalModal: View {
    let commitmentId: UUID
    let onSave: (String) -> Void
    let onDismiss: () -> Void
    
    @State private var journalText: String = ""
    @FocusState private var isFocused: Bool
    
    private let maxCharacters = MicroJournalEntry.maxCharacters
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithHaptic()
                }
            
            // Modal content
            VStack(spacing: CommitTheme.Spacing.l) {
                // Header
                Text("Capture this moment")
                    .font(CommitTheme.Typography.headline)
                    .foregroundColor(CommitTheme.Colors.white)
                
                // Character count indicator
                Text("\(journalText.count)/\(maxCharacters)")
                    .font(CommitTheme.Typography.footnote)
                    .foregroundColor(characterCountColor)
                
                // Text input
                TextField("How do you feel?", text: $journalText, axis: .vertical)
                    .font(CommitTheme.Typography.body)
                    .foregroundColor(CommitTheme.Colors.white)
                    .lineLimit(2...3)
                    .focused($isFocused)
                    .onChange(of: journalText) { _, newValue in
                        if newValue.count > maxCharacters {
                            journalText = String(newValue.prefix(maxCharacters))
                        }
                    }
                    .padding(CommitTheme.Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        CommitTheme.Colors.white.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                    )
                
                // Action buttons
                HStack(spacing: CommitTheme.Spacing.m) {
                    // Skip button
                    Button {
                        dismissWithHaptic()
                    } label: {
                        Text("Skip")
                            .font(CommitTheme.Typography.callout)
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, CommitTheme.Spacing.m)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                CommitTheme.Colors.white.opacity(0.1),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Save button
                    Button {
                        saveWithHaptic()
                    } label: {
                        Text("Save")
                            .font(CommitTheme.Typography.callout)
                            .foregroundColor(canSave ? CommitTheme.Colors.black : CommitTheme.Colors.whiteDim)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, CommitTheme.Spacing.m)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(canSave ? CommitTheme.Colors.white : Color.white.opacity(0.2))
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(!canSave)
                }
            }
            .padding(CommitTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                CommitTheme.Colors.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 10)
            .padding(.horizontal, CommitTheme.Spacing.xl)
        }
        .onAppear {
            // Auto-focus after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canSave: Bool {
        !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var characterCountColor: Color {
        if journalText.count >= maxCharacters {
            return Color.red.opacity(0.8)
        } else if journalText.count >= maxCharacters - 10 {
            return Color.yellow.opacity(0.8)
        }
        return CommitTheme.Colors.whiteDim
    }
    
    // MARK: - Actions
    
    private func saveWithHaptic() {
        let haptics = HapticService()
        haptics.success()
        onSave(journalText)
    }
    
    private func dismissWithHaptic() {
        let haptics = HapticService()
        haptics.selection()
        onDismiss()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MicroJournalModal(
            commitmentId: UUID(),
            onSave: { text in print("Saved: \(text)") },
            onDismiss: { print("Dismissed") }
        )
    }
}
