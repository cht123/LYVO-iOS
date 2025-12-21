import Foundation
import Combine

enum CommitmentCategory: String, Codable, CaseIterable, Identifiable {
    case movement
    case mind
    case sobriety
    case health
    case discipline
    case skill
    case purpose
    case unknown
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .unknown:
            return "Choose Category"
        default:
            return rawValue.capitalized
        }
    }
    
    var emoji: String {
        switch self {
        case .movement: return "🏃"
        case .mind: return "🧠"
        case .sobriety: return "🌿"
        case .health: return "💚"
        case .discipline: return "⚡️"
        case .skill: return "🎯"
        case .purpose: return "✨"
        case .unknown: return "❓"
        }
    }
}

enum CompletionType: String, Codable {
    case finished
    case reset
    case abandoned
    
    var displayName: String {
        switch self {
        case .finished: return "Completed"
        case .reset: return "Reset"
        case .abandoned: return "Abandoned"
        }
    }
}
