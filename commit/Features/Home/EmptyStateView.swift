import SwiftUI

struct EmptyStateView: View {
    let onCreateCommitment: () -> Void
    let onShowArchive: () -> Void
    
    @State private var breathe = false
    @State private var displayedText = ""
    private let fullText = "What will you commit to?"
    
    var body: some View {
        ZStack {
            VStack(spacing: CommitTheme.Spacing.xxl) {
                
                Spacer()
                    .frame(height: CommitTheme.Spacing.xxxl * 2)
                
                // Breathing inactive dot
                BreathingDot()
                
                // Typewriter text
                Text(displayedText)
                    .font(CommitTheme.Typography.title2)
                    .foregroundColor(CommitTheme.Colors.whiteSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CommitTheme.Spacing.xl)
                    .frame(height: 80)
                
                Spacer()
                
                // Floating add button - BEAUTIFUL & SUBTLE
                Button(action: {
                    let haptics = HapticService()
                    haptics.impact(.light)
                    onCreateCommitment()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .thin))
                        .foregroundColor(CommitTheme.Colors.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.20))
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            CommitTheme.Colors.white.opacity(0.12),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .shadow(
                            color: Color.black.opacity(0.25),
                            radius: 16,
                            x: 0,
                            y: 8
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.bottom, CommitTheme.Spacing.xxl)
            }
            
            // Archive button - top right
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        let haptics = HapticService()
                        haptics.selection()
                        onShowArchive()
                    }) {
                        CommitArchiveIcon()
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
                    .padding(.trailing, CommitTheme.Spacing.l)
                    .padding(.top, CommitTheme.Spacing.l)
                }
                Spacer()
            }
        }
        .onAppear {
            startTypewriterEffect()
        }
    }
    
    // MARK: - Typewriter Effect
    
    private func startTypewriterEffect() {
        displayedText = ""
        let characters = Array(fullText)
        
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                displayedText.append(character)
            }
        }
    }
}

// MARK: - Breathing Dot Component

struct BreathingDot: View {
    @State private var breathe = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            CommitTheme.Colors.white.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 40)
                .scaleEffect(breathe ? 1.2 : 0.9)
                .opacity(breathe ? 0.6 : 0.3)
            
            // Dot
            Circle()
                .fill(CommitTheme.Colors.white.opacity(0.35))
                .frame(width: 140, height: 140)
                .blur(radius: 2)
                .scaleEffect(breathe ? 1.05 : 0.95)
        }
        .onAppear {
            withAnimation(CommitAnimations.breathe) {
                breathe = true
            }
        }
    }
}
