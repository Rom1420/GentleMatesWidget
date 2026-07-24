import Foundation

/// Provider de données factices utilisé par le POC.
///
/// Aucune I/O réseau : renvoie une liste de matchs construite en dur, avec des dates
/// relatives à "maintenant" pour que le widget ait toujours des matchs "à venir"
/// crédibles quel que soit le jour où on lance la démo. Les matchs sont étalés sur
/// la semaine pour alimenter aussi la vue calendrier (3 / 7 jours).
struct MockMatchesProvider: MatchesProvider {

    func fetchUpcomingMatches() async throws -> [Match] {
        Match.sampleWeek
    }
}

extension Match {

    /// Jeu de matchs factices étalés sur ~7 jours (aussi utilisé par les previews).
    static var sampleWeek: [Match] {
        let cal = Calendar.current
        let now = Date()

        func at(_ days: Int, _ hour: Int, _ minute: Int = 0) -> Date {
            let base = cal.date(byAdding: .day, value: days, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
        }

        let matches = [
            Match(id: "mock-1", game: "Valorant", team: "Gentle Mates",
                  opponent: "Team Vitality", date: at(0, 20),
                  competition: "VCT 26: EMEA Stage 2", status: .upcoming, score: nil),

            Match(id: "mock-2", game: "Rocket League", team: "Gentle Mates",
                  opponent: "Karmine Corp", date: at(1, 18, 30),
                  competition: "RLCS 26 — EU Open", status: .upcoming, score: nil),
            Match(id: "mock-3", game: "Counter-Strike 2", team: "Gentle Mates",
                  opponent: "Team Falcons", date: at(1, 21),
                  competition: "BLAST Open", status: .upcoming, score: nil),
            Match(id: "mock-4", game: "Valorant", team: "Gentle Mates",
                  opponent: "Fnatic", date: at(1, 15),
                  competition: "VCT 26: EMEA Stage 2", status: .upcoming, score: nil),

            Match(id: "mock-5", game: "Valorant", team: "Gentle Mates GC",
                  opponent: "G2 Gozen", date: at(2, 17),
                  competition: "Game Changers EMEA", status: .upcoming, score: nil),

            Match(id: "mock-6", game: "Fortnite", team: "Gentle Mates",
                  opponent: "FNCS Heat", date: at(3, 19, 30),
                  competition: "FNCS Major", status: .upcoming, score: nil),

            Match(id: "mock-7", game: "Teamfight Tactics", team: "Gentle Mates",
                  opponent: "Tactician's Cup", date: at(4, 16),
                  competition: "TFT EMEA", status: .upcoming, score: nil),

            Match(id: "mock-8", game: "Rocket League", team: "Gentle Mates",
                  opponent: "Team BDS", date: at(6, 14),
                  competition: "RLCS 26 — EU Open", status: .upcoming, score: nil),
        ]

        return matches.sorted { $0.date < $1.date }
    }
}
