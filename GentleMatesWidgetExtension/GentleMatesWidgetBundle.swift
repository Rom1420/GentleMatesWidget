import WidgetKit
import SwiftUI

/// Point d'entrée de l'extension WidgetKit.
@main
struct GentleMatesWidgetBundle: WidgetBundle {
    var body: some Widget {
        GentleMatesWidget()
    }
}

/// Widget calendrier des matchs Gentle Mates (sans bandeau).
///
/// `StaticConfiguration` (pas d'App Intents : un widget configurable reste bloqué
/// sur son placeholder en simulateur / Appetize). Deux tailles :
///  - **small**  → les 3 prochains jours,
///  - **medium** → la semaine (7 jours).
/// Jusqu'à 4 matchs par jour ; un match en cours a une bordure de la couleur du jeu.
struct GentleMatesWidget: Widget {
    let kind = "GentleMatesUpcomingMatches"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatchTimelineProvider()) { entry in
            MatchWidgetView(entry: entry)
        }
        .configurationDisplayName("Gentle Mates — Matchs")
        .description("Le calendrier des prochains matchs de Gentle Mates.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
