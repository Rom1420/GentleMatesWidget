import Foundation

/// Provider de données factices utilisé par le POC.
///
/// Aucune I/O réseau : renvoie une liste de matchs construite en dur, avec des dates
/// relatives à "maintenant" pour que le widget ait toujours des matchs "à venir"
/// crédibles quel que soit le jour où on lance la démo. Les matchs sont étalés sur
/// la semaine, avec une journée volontairement chargée (4 matchs) pour tester la
/// densité de la vue calendrier.
struct MockMatchesProvider: MatchesProvider {

    func fetchUpcomingMatches() async throws -> [Match] {
        Match.sampleWeek
    }
}

extension Match {

    /// Jeu de matchs factices étalés sur ~7 jours (aussi utilisé par les previews).
    /// Jour +1 = journée chargée : 4 matchs, jeux variés.
    static var sampleWeek: [Match] {
        let cal = Calendar.current
        let now = Date()

        func at(_ days: Int, _ hour: Int, _ minute: Int = 0) -> Date {
            let base = cal.date(byAdding: .day, value: days, to: now) ?? now
            return cal.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
        }

        let matches = [
            // Aujourd'hui : un match en cours (badge LIVE).
            Match(id: "mock-live", game: "Valorant", team: "Gentle Mates",
                  opponent: "Team Vitality", date: at(0, 18),
                  competition: "VCT 26: EMEA Stage 2", status: .live, score: "1 - 0"),

            // Jour +1 : 4 matchs, jeux variés.
            Match(id: "mock-1", game: "Rocket League", team: "Gentle Mates",
                  opponent: "Karmine Corp", date: at(1, 14),
                  competition: "RLCS 26 — EU Open", status: .upcoming, score: nil),
            Match(id: "mock-2", game: "Valorant", team: "Gentle Mates",
                  opponent: "Fnatic", date: at(1, 16, 30),
                  competition: "VCT 26: EMEA Stage 2", status: .upcoming, score: nil),
            Match(id: "mock-3", game: "Counter-Strike 2", team: "Gentle Mates",
                  opponent: "Team Falcons", date: at(1, 19),
                  competition: "BLAST Open", status: .upcoming, score: nil),
            Match(id: "mock-4", game: "Fortnite", team: "Gentle Mates",
                  opponent: "FNCS Heat", date: at(1, 21, 30),
                  competition: "FNCS Major", status: .upcoming, score: nil),

            // Reste de la semaine : 1 match/jour, jeux variés.
            Match(id: "mock-5", game: "Teamfight Tactics", team: "Gentle Mates",
                  opponent: "Tactician's Cup", date: at(2, 17),
                  competition: "TFT EMEA", status: .upcoming, score: nil),
            Match(id: "mock-6", game: "Valorant", team: "Gentle Mates GC",
                  opponent: "G2 Gozen", date: at(3, 18),
                  competition: "Game Changers EMEA", status: .upcoming, score: nil),
            Match(id: "mock-7", game: "Rocket League", team: "Gentle Mates",
                  opponent: "Team BDS", date: at(4, 20),
                  competition: "RLCS 26 — EU Open", status: .upcoming, score: nil),
            Match(id: "mock-8", game: "Counter-Strike 2", team: "Gentle Mates",
                  opponent: "Astralis", date: at(6, 15),
                  competition: "BLAST Open", status: .upcoming, score: nil),
        ]

        return matches.sorted { $0.date < $1.date }
    }
}
