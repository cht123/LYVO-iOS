import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: CommitmentCategory
    @Environment(\.dismiss) private var dismiss
    
    private let categories: [CommitmentCategory] = CommitmentCategory.allCases.filter { $0 != .unknown }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                
                // Header
                VStack(spacing: CommitTheme.Spacing.m) {
                    Text("Choose a Category")
                        .font(CommitTheme.Typography.title2)
                        .foregroundColor(CommitTheme.Colors.white)
                    
                    Text("What kind of commitment is this?")
                        .font(CommitTheme.Typography.body)
                        .foregroundColor(CommitTheme.Colors.whiteMedium)
                }
                .padding(.top, CommitTheme.Spacing.xxxl * 1.5)
                .padding(.bottom, CommitTheme.Spacing.xxl)
                
                // Category list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: CommitTheme.Spacing.m) {
                        ForEach(categories) { category in
                            CategoryRow(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                let haptics = HapticService()
                                haptics.selection()
                                selectedCategory = category
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, CommitTheme.Spacing.xl)
                    .padding(.bottom, CommitTheme.Spacing.xxl)
                }
                
                Spacer()
            }
            .commitBackground()
            
            // Dismiss button - top left
            Button(action: {
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
            .padding(.leading, CommitTheme.Spacing.l)
            .padding(.top, CommitTheme.Spacing.l)
        }
    }
}

// MARK: - Sophisticated SF Symbol Mapping

extension CommitmentCategory {
    /// Returns a sophisticated, minimal SF Symbol for each category
    var sfSymbol: String {
        switch self {
        case .movement:
            return "figure.walk"
        case .mind:
            return "brain.head.profile"
        case .sobriety:
            return "leaf"
        case .health:
            return "heart"
        case .discipline:
            return "bolt"
        case .skill:
            return "scope"
        case .purpose:
            return "sparkle"
        case .unknown:
            return "circle.dashed"
        }
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: CommitmentCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CommitTheme.Spacing.m) {
                // SF Symbol icon - thin weight, sophisticated
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 22, weight: .thin))
                    .foregroundColor(
                        isSelected ?
                            CommitTheme.Colors.white :
                            CommitTheme.Colors.whiteMedium
                    )
                    .frame(width: 36, height: 36)
                
                // Name
                Text(category.displayName)
                    .font(CommitTheme.Typography.body)
                    .foregroundColor(
                        isSelected ?
                            CommitTheme.Colors.white :
                            CommitTheme.Colors.whiteMedium
                    )
                
                Spacer()
                
                // Selection indicator dot (on the right)
                Circle()
                    .fill(CommitTheme.Colors.white.opacity(isSelected ? 0.9 : 0.0))
                    .frame(width: 8, height: 8)
            }
            .padding(.vertical, CommitTheme.Spacing.l)
            .padding(.horizontal, CommitTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(isSelected ? 0.30 : 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                CommitTheme.Colors.white.opacity(isSelected ? 0.20 : 0.08),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: Color.black.opacity(isSelected ? 0.30 : 0.15),
                radius: isSelected ? 16 : 8,
                x: 0,
                y: isSelected ? 8 : 4
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
