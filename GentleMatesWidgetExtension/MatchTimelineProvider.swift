import WidgetKit
import SwiftUI

/// Entrée de timeline consommée par les vues du widget.
struct MatchEntry: TimelineEntry {
    let date: Date
    let matches: [Match]
    /// Renseigné si le chargement des matchs a échoué (affiche un état d'erreur léger).
    let errorMessage: String?

    static let placeholder = MatchEntry(
        date: Date(),
        matches: MatchEntry.samplePlaceholderMatches,
        errorMessage: nil
    )

    /// Données neutres pour le placeholder (rendu pendant le chargement / dans la galerie).
    private static var samplePlaceholderMatches: [Match] {
        let now = Date()
        return [
            Match(id: "ph-1", game: "Valorant", team: "Gentle Mates",
                  opponent: "—", date: now.addingTimeInterval(3600),
                  competition: "—", status: .upcoming, score: nil),
            Match(id: "ph-2", game: "Rocket League", team: "Gentle Mates",
                  opponent: "—", date: now.addingTimeInterval(7200),
                  competition: "—", status: .upcoming, score: nil),
        ]
    }
}

/// TimelineProvider WidgetKit. Ne connaît que le protocole `MatchesProvider` ;
/// la source concrète est injectée via `ProviderFactory`.
struct MatchTimelineProvider: TimelineProvider {

    private let matchesProvider: MatchesProvider

    init(matchesProvider: MatchesProvider = ProviderFactory.makeProvider()) {
        self.matchesProvider = matchesProvider
    }

    func placeholder(in context: Context) -> MatchEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MatchEntry) -> Void) {
        Task {
            let entry = await loadEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MatchEntry>) -> Void) {
        Task {
            let entry = await loadEntry()
            // Rafraîchit dans ~1h (WidgetKit reste maître du budget de refresh).
            let nextRefresh = Calendar.current.date(
                byAdding: .hour, value: 1, to: Date()
            ) ?? Date().addingTimeInterval(3600)
            let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
            completion(timeline)
        }
    }

    private func loadEntry() async -> MatchEntry {
        do {
            let matches = try await matchesProvider.fetchUpcomingMatches()
            // On n'affiche que les matchs à venir, limités à 3 (périmètre V1).
            let upcoming = matches
                .filter { $0.status != .finished }
                .sorted { $0.date < $1.date }
            return MatchEntry(date: Date(), matches: Array(upcoming.prefix(3)), errorMessage: nil)
        } catch {
            return MatchEntry(date: Date(), matches: [], errorMessage: "Matchs indisponibles")
        }
    }
}
