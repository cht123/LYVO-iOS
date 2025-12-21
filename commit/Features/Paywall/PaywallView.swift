import SwiftUI
import StoreKit

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
                    .disabled(paywallService.isLoading)
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
                    if let annual = paywallService.storeKit.annualProduct {
                        PurchaseButton(
                            title: "Annual",
                            price: annual.formattedPrice,
                            subtitle: "Best value",
                            isPrimary: true,
                            isLoading: paywallService.isLoading
                        ) {
                            purchaseProduct(annual)
                        }
                    } else {
                        PurchaseButton(
                            title: "Annual",
                            price: "$19.99/year",
                            subtitle: "Best value",
                            isPrimary: true,
                            isLoading: paywallService.storeKit.isLoading
                        ) { }
                        .disabled(true)
                    }

                    // Lifetime purchase
                    if let lifetime = paywallService.storeKit.lifetimeProduct {
                        PurchaseButton(
                            title: "Lifetime",
                            price: lifetime.formattedPrice,
                            subtitle: "One-time purchase",
                            isPrimary: false,
                            isLoading: paywallService.isLoading
                        ) {
                            purchaseProduct(lifetime)
                        }
                    } else {
                        PurchaseButton(
                            title: "Lifetime",
                            price: "$14.99",
                            subtitle: "One-time purchase",
                            isPrimary: false,
                            isLoading: paywallService.storeKit.isLoading
                        ) { }
                        .disabled(true)
                    }

                    // Restore purchases
                    Button {
                        restorePurchases()
                    } label: {
                        if paywallService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: CommitTheme.Colors.whiteDim))
                                .scaleEffect(0.8)
                        } else {
                            Text("Restore Purchases")
                                .font(CommitTheme.Typography.caption)
                                .foregroundColor(CommitTheme.Colors.whiteDim)
                        }
                    }
                    .disabled(paywallService.isLoading)
                    .padding(.top, CommitTheme.Spacing.s)
                }
                .padding(.horizontal, CommitTheme.Spacing.xl)
                .padding(.bottom, CommitTheme.Spacing.xxl)
            }

            // Loading overlay
            if paywallService.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: CommitTheme.Colors.emerald))
                    .scaleEffect(1.5)
            }

            // Success toast
            if paywallService.showRestoreSuccess {
                VStack {
                    Spacer()

                    HStack(spacing: CommitTheme.Spacing.s) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(CommitTheme.Colors.emerald)
                        Text("Purchases restored")
                            .font(CommitTheme.Typography.callout)
                            .foregroundColor(CommitTheme.Colors.white)
                    }
                    .padding(CommitTheme.Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(CommitTheme.Colors.emerald.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, CommitTheme.Spacing.xxl * 2)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: paywallService.showRestoreSuccess)
            }
        }
        .alert("Error", isPresented: .constant(paywallService.errorMessage != nil)) {
            Button("OK") {
                paywallService.clearError()
            }
        } message: {
            if let error = paywallService.errorMessage {
                Text(error)
            }
        }
        .onChange(of: paywallService.isPremium) { _, isPremium in
            if isPremium {
                let haptics = HapticService()
                haptics.success()
                dismiss()
            }
        }
    }

    private func purchaseProduct(_ product: Product) {
        let haptics = HapticService()
        haptics.selection()

        Task {
            let success = await paywallService.purchase(product)
            if success {
                haptics.success()
            }
        }
    }

    private func restorePurchases() {
        let haptics = HapticService()
        haptics.selection()

        Task {
            let success = await paywallService.restorePurchases()
            if success {
                haptics.success()
            } else if paywallService.errorMessage == nil {
                // No error but no purchases found
                paywallService.clearError()
            }
        }
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
    var isLoading: Bool = false
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

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(
                            tint: isPrimary ? CommitTheme.Colors.black : CommitTheme.Colors.white
                        ))
                        .scaleEffect(0.8)
                } else {
                    Text(price)
                        .font(CommitTheme.Typography.headline)
                        .foregroundColor(isPrimary ? CommitTheme.Colors.black : CommitTheme.Colors.white)
                }
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
        .disabled(isLoading)
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}
