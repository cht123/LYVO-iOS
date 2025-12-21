import SwiftUI

struct CommitButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case ghost
    }
    
    init(
        _ title: String,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CommitTheme.Typography.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, CommitTheme.Spacing.m)
                .background(backgroundColor)
                .cornerRadius(CommitTheme.Radius.l)
                .shadow(
                    color: shadowColor,
                    radius: CommitTheme.Shadows.button.radius,
                    x: 0,
                    y: CommitTheme.Shadows.button.y
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .black
        case .secondary, .ghost:
            return CommitTheme.Colors.white
        }
    }
    
    private var backgroundColor: some View {
        Group {
            switch style {
            case .primary:
                RoundedRectangle(cornerRadius: CommitTheme.Radius.l)
                    .fill(CommitTheme.Colors.white)
            case .secondary:
                RoundedRectangle(cornerRadius: CommitTheme.Radius.l)
                    .fill(CommitTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CommitTheme.Radius.l)
                            .strokeBorder(CommitTheme.Colors.cardBorder, lineWidth: 1)
                    )
            case .ghost:
                Color.clear
            }
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return CommitTheme.Colors.glow
        case .secondary, .ghost:
            return .clear
        }
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(CommitAnimations.quick, value: configuration.isPressed)
    }
}
