import WidgetKit
import SwiftUI

/// Point d'entrée de l'extension WidgetKit.
@main
struct GentleMatesWidgetBundle: WidgetBundle {
    var body: some Widget {
        GentleMatesWidget()
    }
}

/// Définition du widget "Prochains matchs".
struct GentleMatesWidget: Widget {
    let kind = "GentleMatesUpcomingMatches"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatchTimelineProvider()) { entry in
            MatchWidgetView(entry: entry)
        }
        .configurationDisplayName("Gentle Mates — Prochains matchs")
        .description("Les prochains matchs de Gentle Mates sur votre écran d'accueil.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
