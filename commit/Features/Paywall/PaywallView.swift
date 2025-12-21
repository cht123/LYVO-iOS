import SwiftUI

enum PaywallContext {
    case general
    case microJournaling
    case unlimitedArchive
    case triggerNotifications
}

/// Full-screen paywall view showing premium features and purchase options
struct PaywallView: View {
    var context: PaywallContext = .general
    @ObservedObject var paywallService = PaywallService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Button {
                        let haptics = HapticService()
                        haptics.selection()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(CommitTheme.Colors.whiteMedium)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                CommitTheme.Colors.white.opacity(0.1),
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    .padding(CommitTheme.Spacing.l)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Premium badge
                VStack(spacing: CommitTheme.Spacing.m) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(CommitTheme.Colors.emerald)
                    
                    Text("LYVO Premium")
                        .font(CommitTheme.Typography.title)
                        .foregroundColor(CommitTheme.Colors.white)
                    
                    Text("Deepen your practice")
                        .font(CommitTheme.Typography.body)
                        .foregroundColor(CommitTheme.Colors.whiteMedium)
                }
                .padding(.bottom, CommitTheme.Spacing.xxl)
                
                // Features list
                VStack(spacing: CommitTheme.Spacing.l) {
                    ForEach(PaywallService.PremiumFeature.allCases, id: \.rawValue) { feature in
                        FeatureRow(feature: feature)
                    }
                }
                .padding(.horizontal, CommitTheme.Spacing.xl)
                
                Spacer()
                
                // Purchase options
                VStack(spacing: CommitTheme.Spacing.m) {
                    // Annual plan
                    PurchaseButton(
                        title: "Annual",
                        price: "$19.99/year",
                        subtitle: "Best value",
                        isPrimary: true
                    ) {
                        handlePurchase()
                    }
                    
                    // One-time purchase
                    PurchaseButton(
                        title: "Lifetime",
                        price: "$14.99",
                        subtitle: "One-time purchase",
                        isPrimary: false
                    ) {
                        handlePurchase()
                    }
                    
                    // Restore purchases
                    Button {
                        let haptics = HapticService()
                        haptics.selection()
                        paywallService.restorePurchases()
                    } label: {
                        Text("Restore Purchases")
                            .font(CommitTheme.Typography.caption)
                            .foregroundColor(CommitTheme.Colors.whiteDim)
                    }
                    .padding(.top, CommitTheme.Spacing.s)
                }
                .padding(.horizontal, CommitTheme.Spacing.xl)
                .padding(.bottom, CommitTheme.Spacing.xxl)
            }
        }
    }
    
    private func handlePurchase() {
        let haptics = HapticService()
        haptics.success()
        // TODO: Implement actual StoreKit purchase
        // For now, just complete the purchase for testing
        #if DEBUG
        paywallService.completePurchase()
        dismiss()
        #endif
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let feature: PaywallService.PremiumFeature
    
    var body: some View {
        HStack(spacing: CommitTheme.Spacing.m) {
            Image(systemName: feature.icon)
                .font(.system(size: 20))
                .foregroundColor(CommitTheme.Colors.emerald)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.rawValue)
                    .font(CommitTheme.Typography.callout)
                    .foregroundColor(CommitTheme.Colors.white)
                
                Text(feature.description)
                    .font(CommitTheme.Typography.footnote)
                    .foregroundColor(CommitTheme.Colors.whiteDim)
            }
            
            Spacer()
        }
    }
}

// MARK: - Purchase Button

struct PurchaseButton: View {
    let title: String
    let price: String
    let subtitle: String
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CommitTheme.Typography.headline)
                        .foregroundColor(isPrimary ? CommitTheme.Colors.black : CommitTheme.Colors.white)
                    
                    Text(subtitle)
                        .font(CommitTheme.Typography.footnote)
                        .foregroundColor(isPrimary ? CommitTheme.Colors.black.opacity(0.6) : CommitTheme.Colors.whiteDim)
                }
                
                Spacer()
                
                Text(price)
                    .font(CommitTheme.Typography.headline)
                    .foregroundColor(isPrimary ? CommitTheme.Colors.black : CommitTheme.Colors.white)
            }
            .padding(CommitTheme.Spacing.l)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isPrimary ? CommitTheme.Colors.white : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isPrimary ? Color.clear : CommitTheme.Colors.white.opacity(0.2),
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
    PaywallView()
}
