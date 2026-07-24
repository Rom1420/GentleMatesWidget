import WidgetKit
import SwiftUI

/// Mode d'affichage du widget.
///
/// ⚠️ Pas d'App Intents ici : sur simulateur (et via Appetize), un widget en
/// `AppIntentConfiguration` reste bloqué sur son placeholder (la timeline n'est
/// jamais appelée). On expose donc un **widget distinct par mode** en
/// `StaticConfiguration` (voir `GentleMatesWidgetBundle`), et ce enum sélectionne
/// juste la mise en page.
enum CalendarSpan {
    case liste
    case troisJours
    case septJours

    /// Nombre de jours en mode calendrier, `nil` pour la vue liste.
    var dayCount: Int? {
        switch self {
        case .liste:      return nil
        case .troisJours: return 3
        case .septJours:  return 7
        }
    }
}

/// Entrée de timeline consommée par les vues du widget.
struct MatchEntry: TimelineEntry {
    let date: Date
    let matches: [Match]
    /// Mise en page à utiliser (liste / calendrier 3 ou 7 jours).
    let span: CalendarSpan
    /// Renseigné si le chargement des matchs a échoué (affiche un état d'erreur léger).
    let errorMessage: String?

    /// Entrée neutre pour le placeholder (rendu pendant le chargement / dans la galerie).
    static func placeholder(span: CalendarSpan) -> MatchEntry {
        MatchEntry(date: Date(), matches: samplePlaceholderMatches, span: span, errorMessage: nil)
    }

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

/// `TimelineProvider` WidgetKit classique. Le mode (`span`) est fixé à la
/// construction par le widget correspondant. Ne connaît que le protocole
/// `MatchesProvider` ; la source concrète est injectée via `ProviderFactory`.
struct MatchTimelineProvider: TimelineProvider {

    let span: CalendarSpan
    private let matchesProvider: MatchesProvider

    init(span: CalendarSpan = .liste,
         matchesProvider: MatchesProvider = ProviderFactory.makeProvider()) {
        self.span = span
        self.matchesProvider = matchesProvider
    }

    func placeholder(in context: Context) -> MatchEntry {
        .placeholder(span: span)
    }

    func getSnapshot(in context: Context, completion: @escaping (MatchEntry) -> Void) {
        Task {
            completion(await loadEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MatchEntry>) -> Void) {
        Task {
            let entry = await loadEntry()
            // Rafraîchit dans ~1h (WidgetKit reste maître du budget de refresh).
            let nextRefresh = Calendar.current.date(
                byAdding: .hour, value: 1, to: Date()
            ) ?? Date().addingTimeInterval(3600)
            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }

    private func loadEntry() async -> MatchEntry {
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
