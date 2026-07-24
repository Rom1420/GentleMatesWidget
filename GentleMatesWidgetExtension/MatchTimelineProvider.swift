import WidgetKit
import SwiftUI

/// Entrée de timeline consommée par les vues du widget.
struct MatchEntry: TimelineEntry {
    let date: Date
    let matches: [Match]
    /// Mode d'affichage choisi par l'utilisateur (liste / calendrier 3 ou 7 jours).
    let span: CalendarSpan
    /// Renseigné si le chargement des matchs a échoué (affiche un état d'erreur léger).
    let errorMessage: String?

    static let placeholder = MatchEntry(
        date: Date(),
        matches: MatchEntry.samplePlaceholderMatches,
        span: .liste,
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

/// TimelineProvider WidgetKit basé sur AppIntents : reçoit la configuration
/// (mode d'affichage) choisie via "Modifier le widget".
/// Ne connaît que le protocole `MatchesProvider` ; la source concrète est
/// injectée via `ProviderFactory`.
struct MatchTimelineProvider: AppIntentTimelineProvider {

    private let matchesProvider: MatchesProvider

    init(matchesProvider: MatchesProvider = ProviderFactory.makeProvider()) {
        self.matchesProvider = matchesProvider
    }

    func placeholder(in context: Context) -> MatchEntry {
        .placeholder
    }

    func snapshot(for configuration: MatchWidgetConfigIntent, in context: Context) async -> MatchEntry {
        await loadEntry(span: configuration.span)
    }

    func timeline(for configuration: MatchWidgetConfigIntent, in context: Context) async -> Timeline<MatchEntry> {
        let entry = await loadEntry(span: configuration.span)
        // Rafraîchit dans ~1h (WidgetKit reste maître du budget de refresh).
        let nextRefresh = Calendar.current.date(
            byAdding: .hour, value: 1, to: Date()
        ) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    private func loadEntry(span: CalendarSpan) async -> MatchEntry {
        do {
            let matches = try await matchesProvider.fetchUpcomingMatches()
            // On garde les matchs à venir (les vues trient/limitent selon leur mode :
            // la liste montre les 3 prochains, le calendrier regroupe par jour).
            let upcoming = matches
                .filter { $0.status != .finished }
                .sorted { $0.date < $1.date }
            return MatchEntry(date: Date(), matches: Array(upcoming.prefix(12)), span: span, errorMessage: nil)
        } catch {
            return MatchEntry(date: Date(), matches: [], span: span, errorMessage: "Matchs indisponibles")
        }
    }
}
