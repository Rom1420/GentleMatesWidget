import Foundation

/// Provider de données factices utilisé par le POC.
///
/// Aucune I/O réseau : renvoie une liste de matchs construite en dur, avec des dates
/// relatives à "maintenant" pour que le widget ait toujours des matchs "à venir"
/// crédibles quel que soit le jour où on lance la démo.
struct MockMatchesProvider: MatchesProvider {

    func fetchUpcomingMatches() async throws -> [Match] {
        let now = Date()
        let calendar = Calendar.current

        func date(inDays days: Int, hour: Int, minute: Int = 0) -> Date {
            let base = calendar.date(byAdding: .day, value: days, to: now) ?? now
            return calendar.date(
                bySettingHour: hour, minute: minute, second: 0, of: base
            ) ?? base
        }

        let matches = [
            Match(
                id: "mock-1",
                game: "Valorant",
                team: "Gentle Mates",
                opponent: "Team Vitality",
                date: date(inDays: 1, hour: 18),
                competition: "VCT 26: EMEA Stage 2",
                status: .upcoming,
                score: nil
            ),
            Match(
                id: "mock-2",
                game: "Rocket League",
                team: "Gentle Mates",
                opponent: "Karmine Corp",
                date: date(inDays: 2, hour: 20, minute: 30),
                competition: "RLCS 26 — EU Open Qualifier",
                status: .upcoming,
                score: nil
            ),
            Match(
                id: "mock-3",
                game: "Valorant",
                team: "Gentle Mates GC",
                opponent: "G2 Gozen",
                date: date(inDays: 4, hour: 17),
                competition: "Game Changers EMEA",
                status: .upcoming,
                score: nil
            ),
        ]

        return matches.sorted { $0.date < $1.date }
    }
}
