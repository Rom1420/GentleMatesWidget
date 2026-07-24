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
///
/// `AppIntentConfiguration` : l'appui long → "Modifier le widget" affiche
/// nativement le sélecteur de mode d'affichage (`MatchWidgetConfigIntent`).
struct GentleMatesWidget: Widget {
    let kind = "GentleMatesUpcomingMatches"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: MatchWidgetConfigIntent.self,
            provider: MatchTimelineProvider()
        ) { entry in
            MatchWidgetView(entry: entry)
        }
        .configurationDisplayName("Gentle Mates — Prochains matchs")
        .description("Les prochains matchs de Gentle Mates. Appui long → Modifier pour passer en vue calendrier.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
