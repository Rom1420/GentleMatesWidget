import WidgetKit
import AppIntents

/// Modes d'affichage proposés dans "Modifier le widget" (appui long → Modifier).
/// C'est le mécanisme natif d'Apple : ce enum devient un sélecteur dans la
/// configuration du widget.
enum CalendarSpan: String, AppEnum {
    case liste
    case troisJours
    case septJours

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Affichage" }

    static var caseDisplayRepresentations: [CalendarSpan: DisplayRepresentation] {
        [
            .liste:      "Liste (prochains matchs)",
            .troisJours: "Calendrier — 3 jours",
            .septJours:  "Calendrier — 7 jours",
        ]
    }

    /// Nombre de jours à afficher en mode calendrier, `nil` pour la vue liste.
    var dayCount: Int? {
        switch self {
        case .liste:      return nil
        case .troisJours: return 3
        case .septJours:  return 7
        }
    }
}

/// Intent de configuration du widget (WidgetKit + AppIntents, iOS 17+).
/// Un seul paramètre : le mode d'affichage.
struct MatchWidgetConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Affichage du widget" }
    static var description: IntentDescription {
        IntentDescription("Basculer entre la liste des prochains matchs et une vue calendrier.")
    }

    @Parameter(title: "Affichage", default: .liste)
    var span: CalendarSpan
}
