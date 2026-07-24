import WidgetKit
import SwiftUI

/// Point d'entrée de l'extension WidgetKit.
///
/// Pour cette phase de comparaison, on expose 3 variantes de bandeau (elles seront
/// réduites à une seule une fois le choix fait). Toutes en `StaticConfiguration`
/// (pas d'App Intents : un widget configurable reste bloqué sur son placeholder en
/// simulateur / Appetize).
@main
struct GentleMatesWidgetBundle: WidgetBundle {
    var body: some Widget {
        GentleMatesWidget()
        GentleMatesWidgetNoHeader()
        GentleMatesWidgetLiveOnly()
    }
}

/// Référence : bandeau complet (blason M8 + LIVE), 2 matchs max par jour.
struct GentleMatesWidget: Widget {
    let kind = "GentleMatesUpcomingMatches"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatchTimelineProvider()) { entry in
            MatchWidgetView(entry: entry, headerStyle: .full, maxPerDay: 2)
        }
        .configurationDisplayName("Gentle Mates — Matchs")
        .description("Le calendrier des prochains matchs de Gentle Mates.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// Version A : sans bandeau, jusqu'à 4 matchs par jour (max de place).
struct GentleMatesWidgetNoHeader: Widget {
    let kind = "GentleMatesCalendarNoHeader"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatchTimelineProvider()) { entry in
            MatchWidgetView(entry: entry, headerStyle: .hidden, maxPerDay: 4)
        }
        .configurationDisplayName("Gentle Mates — Calendrier (sans bandeau)")
        .description("Calendrier dense, jusqu'à 4 matchs par jour, sans en-tête.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

/// Version B : bandeau réduit au badge LIVE, jusqu'à 4 matchs par jour.
struct GentleMatesWidgetLiveOnly: Widget {
    let kind = "GentleMatesCalendarLiveOnly"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatchTimelineProvider()) { entry in
            MatchWidgetView(entry: entry, headerStyle: .liveOnly, maxPerDay: 4)
        }
        .configurationDisplayName("Gentle Mates — Calendrier (LIVE seul)")
        .description("Calendrier dense, jusqu'à 4 matchs par jour, avec badge LIVE.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
