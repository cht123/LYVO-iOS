import SwiftUI

struct NewCommitmentView: View {
    @EnvironmentObject private var service: CommitmentService
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var identityStatement: String = "" {
        didSet {
            if identityStatement.count > 200 {
                identityStatement = String(identityStatement.prefix(200))
            }
        }
    }
    @State private var category: CommitmentCategory = .unknown
    @State private var reminderTime = Date()
    @State private var showingCategoryPicker = false
    
    var isValid: Bool {
        !title.isEmpty && category != .unknown
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: CommitTheme.Spacing.xl) {
                
                // Header
                VStack(spacing: CommitTheme.Spacing.s) {
                    Text("Your New Commitment")
                        .font(CommitTheme.Typography.title)
                        .foregroundColor(CommitTheme.Colors.white)
                    
                    Text("Make it clear. Make it yours.")
                        .font(CommitTheme.Typography.body)
                        .foregroundColor(CommitTheme.Colors.whiteMedium)
                }
                .multilineTextAlignment(.center)
                .padding(.top, CommitTheme.Spacing.xxl)
                
                // Form fields
                VStack(alignment: .leading, spacing: CommitTheme.Spacing.xl) {
                    
                    // Title field
                    VStack(alignment: .leading, spacing: CommitTheme.Spacing.xs) {
                        Text("What will you commit to?")
                            .font(CommitTheme.Typography.caption)
                            .foregroundColor(CommitTheme.Colors.whiteDim)
                        
                        CommitTextField("e.g. Walk 10 minutes", text: $title)
                    }
                    
                    // Identity statement (optional)
                    VStack(alignment: .leading, spacing: CommitTheme.Spacing.xs) {
                        Text("Why does this matter? (Optional)")
                            .font(CommitTheme.Typography.caption)
                            .foregroundColor(CommitTheme.Colors.whiteDim)
                        
                        CommitTextField("Identity statement", text: $identityStatement)
                        
                        Text("\(identityStatement.count)/200")
                            .font(CommitTheme.Typography.footnote)
                            .foregroundColor(CommitTheme.Colors.whiteDim)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Category picker
                    VStack(alignment: .leading, spacing: CommitTheme.Spacing.xs) {
                        Text("Category")
                            .font(CommitTheme.Typography.caption)
                            .foregroundColor(CommitTheme.Colors.whiteDim)
                        
                        Button {
                            showingCategoryPicker = true
                        } label: {
                            HStack {
                                if category == .unknown {
                                    Text("Choose…")
                                        .foregroundColor(CommitTheme.Colors.whiteDim)
                                        .font(CommitTheme.Typography.body)
                                } else {
                                    // SF Symbol + Name
                                    Image(systemName: category.sfSymbol)
                                        .font(.system(size: 18, weight: .thin))
                                        .foregroundColor(CommitTheme.Colors.white)
                                    
                                    Text(category.displayName)
                                        .foregroundColor(CommitTheme.Colors.white)
                                        .font(CommitTheme.Typography.body)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(CommitTheme.Colors.whiteDim)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(CommitTheme.Spacing.m)
                            .commitCardBackground()
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Reminder time
                    VStack(alignment: .leading, spacing: CommitTheme.Spacing.xs) {
                        Text("Daily Reminder")
                            .font(CommitTheme.Typography.caption)
                            .foregroundColor(CommitTheme.Colors.whiteDim)
                        
                        DatePicker(
                            "Choose time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .colorScheme(.dark)
                        .padding(CommitTheme.Spacing.m)
                        .commitCardBackground()
        
                    }
                }
                .padding(.horizontal, CommitTheme.Spacing.l)
                
                // Create button
                CommitButton("Start Commitment") {
                    createCommitment()
                }
                .padding(.horizontal, CommitTheme.Spacing.l)
                .padding(.top, CommitTheme.Spacing.l)
                .disabled(!isValid)
                .opacity(isValid ? 1.0 : 0.5)
            }
            .padding(.bottom, CommitTheme.Spacing.xxl)
        }
        .commitBackground()
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(selectedCategory: $category)
        }
    }
    
    // MARK: - Create Commitment
    
    private func createCommitment() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        
        let haptics = HapticService()
           haptics.success()
        
        service.createCommitment(
            title: title,
            identityStatement: identityStatement.isEmpty ? nil : identityStatement,
            category: category,
            reminderTime: components
        )
        
        dismiss()
    }
}
