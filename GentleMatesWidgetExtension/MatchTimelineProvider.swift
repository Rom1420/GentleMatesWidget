import WidgetKit
import SwiftUI

/// Entrée de timeline consommée par la vue calendrier.
struct MatchEntry: TimelineEntry {
    let date: Date
    let matches: [Match]
    /// Renseigné si le chargement des matchs a échoué (affiche un état d'erreur léger).
    let errorMessage: String?

    /// Entrée neutre pour le placeholder (rendu pendant le chargement / dans la galerie).
    static var placeholder: MatchEntry {
        MatchEntry(date: Date(), matches: Match.sampleWeek, errorMessage: nil)
    }
}

/// `TimelineProvider` WidgetKit classique (pas d'App Intents : un widget en
/// `AppIntentConfiguration` reste bloqué sur son placeholder en simulateur/Appetize).
/// Ne connaît que le protocole `MatchesProvider` ; la source concrète est injectée
/// via `ProviderFactory`. Le nombre de jours affichés dépend de la taille du widget
/// (voir `MatchWidgetView`), pas du provider.
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
            // Matchs non terminés (à venir + en cours), triés par date.
            let visible = matches
                .filter { $0.status != .finished }
                .sorted { $0.date < $1.date }
            return MatchEntry(date: Date(), matches: Array(visible.prefix(12)), errorMessage: nil)
        } catch {
            return MatchEntry(date: Date(), matches: [], errorMessage: "Matchs indisponibles")
        }
    }
}
