import SwiftUI

struct CommitDotView: View {
    let size: CGFloat
    let streak: Int?
    @ObservedObject var animationState: CommitAnimationState
    let onTap: () -> Void
    
    init(
        size: CGFloat = 180,
        streak: Int? = nil,
        animationState: CommitAnimationState,
        onTap: @escaping () -> Void
    ) {
        self.size = size
        self.streak = streak
        self.animationState = animationState
        self.onTap = onTap
    }
    
    var body: some View {
        ZStack {
            // Outer glow halo that breathes
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            CommitTheme.Colors.white.opacity(0.12),
                            CommitTheme.Colors.white.opacity(0.02),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.6, height: size * 1.6)
                .blur(radius: 40)
                .scaleEffect(animationState.breatheEffect ? 1.15 : 0.92)
                .opacity(animationState.breatheEffect ? 0.8 : 0.4)
                .animation(CommitAnimations.breathe, value: animationState.breatheEffect)
            
            // Main dot circle
            Circle()
                .fill(CommitTheme.Colors.white)
                .frame(width: size, height: size)
                .shadow(
                    color: CommitTheme.Colors.glow,
                    radius: 20,
                    x: 0,
                    y: 0
                )
                .shadow(
                    color: CommitTheme.Colors.glow.opacity(0.5),
                    radius: 40,
                    x: 0,
                    y: 0
                )
                .scaleEffect(animationState.isCommitted ? 1.08 : 1.0)
                .animation(CommitAnimations.springBouncy, value: animationState.isCommitted)
                .onTapGesture {
                    onTap()
                }
            
            // Streak number overlay - BEAUTIFUL & SUBTLE
            if let streak = streak, animationState.showStreak {
                Text("\(streak)")
                    .font(.system(size: 52, weight: .light, design: .default))
                    .foregroundColor(.black.opacity(0.35))
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
