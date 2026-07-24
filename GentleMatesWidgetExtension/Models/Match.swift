import Foundation

/// Contrat de données du widget. Volontairement stable : une fois le widget branché
/// dessus, on ne change plus la forme sans revoir le mapping des providers.
struct Match: Identifiable, Codable, Hashable {
    let id: String
    let game: String        // ex: "Valorant", "Rocket League"
    let team: String        // "Gentle Mates" ou nom de la sous-équipe (ex: "Gentle Mates GC")
    let opponent: String
    let date: Date
    let competition: String // ex: "VCT 26: EMEA Stage 2"
    let status: MatchStatus // upcoming / live / finished
    let score: String?      // nil si pas encore joué
}

enum MatchStatus: String, Codable {
    case upcoming, live, finished
}
