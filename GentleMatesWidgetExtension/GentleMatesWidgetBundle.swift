import WidgetKit
import SwiftUI

/// Point d'entrée de l'extension WidgetKit.
///
/// On expose **un widget par mode d'affichage** plutôt qu'un seul widget
/// configurable via App Intents : sur simulateur (et via Appetize) un widget en
/// `AppIntentConfiguration` reste bloqué sur son placeholder. Trois
/// `StaticConfiguration` = même résultat pour l'utilisateur (il choisit dans la
/// galerie), fiable partout et dès iOS 17.
@main
struct GentleMatesWidgetBundle: WidgetBundle {
    var body: some Widget {
        GentleMatesListWidget()
        GentleMatesCalendar3Widget()
        GentleMatesCalendar7Widget()
    }
}

/// Vue liste : les 3 prochains matchs.
struct GentleMatesListWidget: Widget {
    let kind = "GentleMatesUpcomingMatches"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatchTimelineProvider(span: .liste)) { entry in
            MatchWidgetView(entry: entry)
        }
        .configurationDisplayName("Gentle Mates — Prochains matchs")
        .description("Les 3 prochains matchs de Gentle Mates.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// Vue calendrier sur 3 jours.
struct GentleMatesCalendar3Widget: Widget {
    let kind = "GentleMatesCalendar3"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatchTimelineProvider(span: .troisJours)) { entry in
            MatchWidgetView(entry: entry)
        }
        .configurationDisplayName("Gentle Mates — Calendrier 3 jours")
        .description("Les matchs des 3 prochains jours.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

/// Vue calendrier sur 7 jours.
struct GentleMatesCalendar7Widget: Widget {
    let kind = "GentleMatesCalendar7"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatchTimelineProvider(span: .septJours)) { entry in
            MatchWidgetView(entry: entry)
        }
        .configurationDisplayName("Gentle Mates — Calendrier 7 jours")
        .description("Les matchs de la semaine.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
