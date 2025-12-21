import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var contentOpacity: Double = 0
    @State private var dotPulse: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer()
                    .frame(height: CommitTheme.Spacing.xxl)
                
                // Big glowing pulsing dot
                ZStack {
                    // Outer glow - slow calm pulse
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    CommitTheme.Colors.white.opacity(0.20),
                                    CommitTheme.Colors.white.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)
                        .scaleEffect(dotPulse ? 1.15 : 0.95)
                        .opacity(dotPulse ? 0.8 : 0.5)
                    
                    // Main dot
                    Circle()
                        .fill(CommitTheme.Colors.white)
                        .frame(width: 100, height: 100)
                        .shadow(
                            color: CommitTheme.Colors.white.opacity(0.4),
                            radius: 40,
                            x: 0,
                            y: 0
                        )
                        .scaleEffect(dotPulse ? 1.03 : 0.98)
                }
                .padding(.bottom, CommitTheme.Spacing.l)
                .onAppear {
                    // Slow, calm pulse - 4 seconds
                    withAnimation(
                        .easeInOut(duration: 4.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        dotPulse = true
                    }
                }
                
                // Title: commit.
                Text("commit.")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundColor(CommitTheme.Colors.white)
                    .padding(.bottom, CommitTheme.Spacing.s)
                
                // Subtitle
                Text("A simple ritual to become the person\nyou want to be.")
                    .font(CommitTheme.Typography.callout)
                    .foregroundColor(CommitTheme.Colors.whiteMedium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CommitTheme.Spacing.xl)
                    .padding(.bottom, CommitTheme.Spacing.xl)
                
                // Principles
                VStack(spacing: CommitTheme.Spacing.m) {
                    PrincipleRow(
                        icon: "person.fill",
                        title: "Identity over goals",
                        description: "Small actions shape who you're becoming"
                    )
                    
                    PrincipleRow(
                        icon: "repeat",
                        title: "Consistency compounds",
                        description: "Show up daily, build unbreakable habits"
                    )
                    
                    PrincipleRow(
                        icon: "sparkles",
                        title: "Reflection deepens change",
                        description: "15 seconds to honor your commitment"
                    )
                }
                .padding(.horizontal, CommitTheme.Spacing.l)
                .padding(.bottom, CommitTheme.Spacing.l)
                
                Spacer()
                
                // CTA Button
                Button {
                    let haptics = HapticService()
                    haptics.impact(.light)
                    onComplete()
                } label: {
                    Text("Start Your Commitment")
                        .font(CommitTheme.Typography.headline)
                        .foregroundColor(CommitTheme.Colors.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(CommitTheme.Colors.white)
                        )
                        .shadow(
                            color: CommitTheme.Colors.white.opacity(0.25),
                            radius: 20,
                            x: 0,
                            y: 8
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, CommitTheme.Spacing.l)
                .padding(.bottom, CommitTheme.Spacing.xxl)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
                contentOpacity = 1
            }
        }
    }
}

// MARK: - Principle Row

struct PrincipleRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: CommitTheme.Spacing.s) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(CommitTheme.Colors.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(CommitTheme.Colors.white.opacity(0.08))
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    CommitTheme.Colors.white.opacity(0.12),
                                    lineWidth: 0.5
                                )
                        )
                )
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CommitTheme.Typography.bodyMedium)
                    .foregroundColor(CommitTheme.Colors.white)
                
                Text(description)
                    .font(CommitTheme.Typography.caption)
                    .foregroundColor(CommitTheme.Colors.whiteMedium)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(onComplete: {})
}
