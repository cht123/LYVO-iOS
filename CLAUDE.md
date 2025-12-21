# LYVO - Commitment Tracking App

## Working Guidelines
- Always ask clarifying questions before implementing significant features
- Preserve the sacred, intentional nature of the app over aggressive monetization
- Keep the aesthetic premium and Apple Design Award-worthy
- Update CLAUDE.md before every git commit

## Project Overview
LYVO is a premium iOS commitment tracking app that takes a fundamentally different approach to habit formation. Rather than streaks, metrics, or gamification, LYVO emphasizes identity formation through daily 15-second reflection rituals. The core philosophy: "showing up" consistently to become who you want to be.

**Key Differentiators:**
- Single commitment focus (not multiple habits)
- 15-second reflection ritual, not task completion
- Identity formation over performance measurement
- Minimalist, premium aesthetic

## Tech Stack
- **Language:** Swift
- **UI Framework:** SwiftUI
- **Data:** UserDefaults (local-first, no cloud sync)
- **IAP:** StoreKit 2
- **Minimum iOS:** 17.0
- **Architecture:** MVVM with EnvironmentObject services

## Project Structure
```
LYVO/
├── App/
│   └── LYVOApp.swift                   # App entry point
├── Core/
│   ├── Models/
│   │   ├── Commitment.swift            # Active commitment model
│   │   ├── ArchivedCommitment.swift    # Archived commitment model
│   │   ├── CommitDay.swift             # Daily completion record
│   │   ├── CommitmentStats.swift       # Statistics model
│   │   └── JournalEntry.swift          # Micro-journal entries
│   ├── Services/
│   │   ├── CommitmentService.swift     # Core business logic & persistence
│   │   ├── NotificationService.swift   # Daily reminders
│   │   ├── HapticService.swift         # Haptic feedback
│   │   ├── PaywallService.swift        # Premium access management
│   │   └── StoreKitService.swift       # StoreKit 2 implementation
│   └── Extensions/
│       └── Date+Extensions.swift
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift              # Root container
│   │   ├── ActiveCommitmentView.swift  # Main ritual screen
│   │   └── EmptyStateView.swift        # No commitment state
│   ├── Commit/
│   │   ├── CommitDotView.swift         # Breathing dot component
│   │   └── CommitAnimationState.swift  # Animation coordination
│   ├── Creation/
│   │   ├── NewCommitmentView.swift     # Commitment creation
│   │   └── CategoryPickerView.swift    # Category selection
│   ├── Archive/
│   │   ├── ArchiveView.swift           # Archived commitments list
│   │   └── ArchivePaywallCard.swift    # Premium upsell for old entries
│   ├── Journal/
│   │   ├── JournalModalView.swift      # Micro-journaling modal
│   │   ├── JournalTeaser.swift         # Post-ritual soft paywall
│   │   └── JournalHistoryView.swift    # Journal entries list
│   ├── Onboarding/
│   │   └── OnboardingView.swift        # First-launch experience
│   ├── Settings/
│   │   └── SettingsView.swift          # App settings
│   └── Paywall/
│       └── PaywallView.swift           # Premium purchase screen
├── DesignSystem/
│   ├── CommitTheme.swift               # Colors, Typography, Spacing
│   └── Components/
│       ├── CommitButton.swift
│       ├── ScaleButtonStyle.swift
│       └── BreathingDot.swift
└── Resources/
    ├── Assets.xcassets
    ├── Sounds/                         # Custom ritual sounds
    └── LYVO_Products.storekit          # Local IAP testing
```

## Key Features

### Core (Free)
1. **Daily Ritual** - 15-second reflection with glowing dot animation
2. **Streak Tracking** - Days shown up (hidden until dot is pressed each day)
3. **Single Commitment** - Focus on one identity transformation
4. **Daily Reminder** - Single notification at user's preferred time
5. **30-Day Archive** - Rolling window of past commitments

### Premium ($19.99/year or $14.99 lifetime)
1. **Micro-Journaling** - 40-60 character reflection after ritual
2. **Unlimited Archive** - Full commitment history
3. **Multiple Reminders** - Morning, midday, evening trigger times

## Design System

### Theme
- **Background:** Dark gradient (#0A0A0A → #1A1A1A)
- **Accent:** Emerald (#2ECC71)
- **Text:** White hierarchy (white, whiteSoft, whiteMedium, whiteDim)
- **Typography:** SF Pro Rounded with clear hierarchy

### CommitTheme Usage
```swift
CommitTheme.Colors.emerald          // Primary accent
CommitTheme.Colors.white            // Primary text
CommitTheme.Colors.whiteMedium      // Secondary text
CommitTheme.Typography.title        // Large headings
CommitTheme.Typography.body         // Body text
CommitTheme.Spacing.l               // Standard spacing (16pt)
```

### Animation
- Breathing dot: 3.2s duration, spring animation
- Reflection ritual: 15 seconds with glow/pulse
- All transitions: `CommitAnimations.smooth`

## Ritual Flow
1. User opens app → sees commitment with breathing dot
2. Tap dot → 15-second reflection animation begins
3. "Reflect on your commitment" text appears
4. Animation ends → dot returns to normal
5. "You showed up today" fades in
6. Streak increments
7. (Premium) Journal teaser appears after ~1 second

## Paywall Strategy

**Philosophy:** Restrained, contextual triggers at natural engagement moments.

**Current Triggers:**
| Trigger | When | Context |
|---------|------|---------|
| Settings → Upgrade | Manual tap | `.general` |
| Additional Reminders | Locked feature tap | `.triggerNotifications` |
| Journal Teaser | Post-ritual on days 1,3,5,7,14,21,30... | `.microJournaling` |
| Archive Limit | Scroll past 30-day window | `.unlimitedArchive` |

**Never do:** Post-onboarding paywall. The first commitment moment is sacred.

## StoreKit 2 Configuration

**Product IDs:**
```swift
lyvo_premium_annual     // $19.99/year auto-renewable
lyvo_premium_lifetime   // $14.99 non-consumable
```

**Local Testing:**
1. Xcode → Edit Scheme → Run → Options
2. Set StoreKit Configuration to `LYVO_Products.storekit`

## Notification System
- Single daily reminder at user-preferred time
- Reschedules when commitment changes
- Uses `UNUserNotificationCenter`
- Premium: Multiple trigger times throughout day

## Debug Tools

```swift
#if DEBUG
// In PaywallService.swift
static let DEBUG_BYPASS_PAYWALL = true  // Bypass paywall in debug

// In SettingsView - Developer section (DEBUG builds only)
// - Premium toggle for testing
// - Reset onboarding
// - Clear all data
#endif
```

## Known Issues & Fixes Applied
- Eliminated double observation pattern (no more `@Published var store`)
- Fixed notification not firing on day 2
- Streak number hidden until ritual completed each day
- "You showed up" text resets at midnight
- Archive deletion also removes journal entries

## Git Conventions
- Commit messages: imperative mood, concise summary
- Include emoji: 🤖 Generated with Claude Code
- Co-authored-by: Claude <noreply@anthropic.com>

## Current State
- Phase 1 complete: Free version fully functional
- StoreKit 2 integrated with real product IDs
- Onboarding flow complete with behavioral psychology foundations
- Website built for App Store requirements (Privacy Policy, Terms, Support)
- Ready for App Store submission

## Upcoming (Phase 2, 2-3 months post-launch)
- Widgets for home screen
- Enhanced analytics/insights
- iCloud sync consideration
- Apple Watch companion
