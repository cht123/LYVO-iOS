import SwiftUI

// MARK: - Commit Design System
// The unified visual language for the Commit app

struct CommitTheme {
    
    // MARK: - Colors
    
    struct Colors {
        // Background gradient
        static let backgroundTop = Color(red: 0.02, green: 0.02, blue: 0.02)
        static let backgroundBottom = Color(red: 0.08, green: 0.08, blue: 0.08)
        
        // Accent color - emerald green for actions and highlights
        static let emerald = Color(red: 0.18, green: 0.80, blue: 0.44) // #2ECC71
        
        // White variants for text and UI elements
        static let white = Color.white
        static let whiteSoft = Color.white.opacity(0.92)
        static let whiteMedium = Color.white.opacity(0.70)
        static let whiteDim = Color.white.opacity(0.50)
        static let whiteSubtle = Color.white.opacity(0.30)
        
        // Card system
        static let cardBackground = Color.white.opacity(0.05)
        static let cardBackgroundPressed = Color.white.opacity(0.08)
        static let cardBorder = Color.white.opacity(0.12)
        static let cardBorderSelected = Color.white.opacity(0.30)
        
        // Shadows and glows
        static let shadow = Color.black.opacity(0.40)
        static let glow = Color.white.opacity(0.30)
        static let emeraldGlow = emerald.opacity(0.25)
        
        // Black variants
        static let black = Color.black
        
        // accents
        static let accent  = Color(red: 0.18, green: 0.7, blue: 0.52)
    }
    
    // MARK: - Typography
    
    struct Typography {
        
        //Streak number
        static let streakNumber = Font.system(size: 120, weight: .thin, design: .default)
        
        // Display fonts - large, bold headers
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let hero = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
        
        // Body fonts
        static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let bodyMedium = Font.system(size: 17, weight: .medium, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        
        // Small fonts
        static let caption = Font.system(size: 14, weight: .regular, design: .rounded)
        static let captionMedium = Font.system(size: 14, weight: .medium, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    
    struct Radius {
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 20
        static let xl: CGFloat = 24
        static let circle: CGFloat = 9999
    }
    
    // MARK: - Shadow Styles
    
    struct Shadows {
        static let card = Shadow(
            color: Colors.shadow,
            radius: 24,
            x: 0,
            y: 12
        )
        
        static let button = Shadow(
            color: Colors.shadow,
            radius: 16,
            x: 0,
            y: 8
        )
        
        static let glow = Shadow(
            color: Colors.glow,
            radius: 32,
            x: 0,
            y: 0
        )
        
        static let dotGlow = Shadow(
            color: Colors.glow,
            radius: 40,
            x: 0,
            y: 0
        )
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Commit Animations
// Predefined animation curves for consistent motion

struct CommitAnimations {
    
    // Primary animations
    static let smooth = Animation.easeInOut(duration: 0.35)
    static let spring = Animation.spring(response: 0.45, dampingFraction: 0.75)
    static let springBouncy = Animation.spring(response: 0.40, dampingFraction: 0.65)
    
    // Special effects
    static let breathe = Animation
        .easeInOut(duration: 3.2)
        .repeatForever(autoreverses: true)
    
    static let pulse = Animation
        .easeInOut(duration: 1.5)
        .repeatForever(autoreverses: true)
    
    // Fast interactions
    static let quick = Animation.easeOut(duration: 0.2)
    static let instant = Animation.easeInOut(duration: 0.15)
    
    // Appearance
    static let fadeIn = Animation.easeOut(duration: 0.6)
    static let fadeInSlow = Animation.easeOut(duration: 0.9)
}

// MARK: - Convenience Extensions

extension View {
    /// Apply Commit background gradient
    func commitBackground() -> some View {
        self
            .background(
                LinearGradient(
                    colors: [
                        CommitTheme.Colors.backgroundTop,
                        CommitTheme.Colors.backgroundBottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
    
    /// Apply card-style background
    func commitCardBackground() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: CommitTheme.Radius.m)
                    .fill(CommitTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CommitTheme.Radius.m)
                            .strokeBorder(CommitTheme.Colors.cardBorder, lineWidth: 1)
                    )
            )
    }
}
