import WidgetKit
import SwiftUI

/// Vue racine : choisit la mise en page selon la famille de widget et le mode
/// d'affichage choisi par l'utilisateur (liste / calendrier).
/// (Toute couleur passe par `DesignTokens` / `GameStyle`.)
struct MatchWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MatchEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                // Le small reste "prochain match" quel que soit le mode (le calendrier
                // n'a pas de place ici).
                SmallMatchView(match: entry.matches.first, errorMessage: entry.errorMessage)
            default:
                if let dayCount = entry.span.dayCount {
                    CalendarView(
                        dayCount: dayCount,
                        matches: entry.matches,
                        errorMessage: entry.errorMessage
                    )
                } else {
                    MediumMatchView(matches: entry.matches, errorMessage: entry.errorMessage)
                }
            }
        }
        .containerBackground(DesignTokens.background, for: .widget)
    }
}

// MARK: - Small : le prochain match uniquement

private struct SmallMatchView: View {
    let match: Match?
    let errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetHeader()

            if let match {
                Spacer(minLength: 0)
                GameTag(game: match.game)
                Text(match.opponent)
                    .font(.headline)
                    .foregroundStyle(DesignTokens.todayHighlight)
                    .lineLimit(1)
                Text(match.date, format: .dateTime.weekday(.abbreviated).hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Spacer(minLength: 0)
                EmptyStateLabel(message: errorMessage ?? "Aucun match à venir")
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Medium (liste) : 2-3 prochains matchs

private struct MediumMatchView: View {
    let matches: [Match]
    let errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetHeader()

            if matches.isEmpty {
                Spacer(minLength: 0)
                EmptyStateLabel(message: errorMessage ?? "Aucun match à venir")
                Spacer(minLength: 0)
            } else {
                ForEach(matches.prefix(3)) { match in
                    MatchRow(match: match)
                    if match.id != matches.prefix(3).last?.id {
                        Divider().overlay(DesignTokens.surface)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Medium (calendrier) : colonnes par jour

private struct CalendarView: View {
    let dayCount: Int
    let matches: [Match]
    let errorMessage: String?

    private var days: [Date] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        return (0..<dayCount).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            WidgetHeader()

            if matches.isEmpty {
                Spacer(minLength: 0)
                EmptyStateLabel(message: errorMessage ?? "Aucun match à venir")
                Spacer(minLength: 0)
            } else {
                HStack(alignment: .top, spacing: 4) {
                    ForEach(days, id: \.self) { day in
                        DayColumn(day: day, matches: matches(on: day))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func matches(on day: Date) -> [Match] {
        let cal = Calendar.current
        return matches
            .filter { cal.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date < $1.date }
    }
}

/// Une colonne = un jour : en-tête "LU/MA/…" + créneaux du jour empilés.
private struct DayColumn: View {
    let day: Date
    let matches: [Match]

    private var isToday: Bool { Calendar.current.isDateInToday(day) }

    var body: some View {
        VStack(spacing: 4) {
            Text(Self.shortWeekday(day))
                .font(.caption2.weight(.bold))
                .foregroundStyle(isToday ? DesignTokens.todayHighlight : .secondary)

            ForEach(matches.prefix(2)) { match in
                CalendarSlot(match: match)
            }
            if matches.count > 2 {
                Text("+\(matches.count - 2)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? DesignTokens.surface.opacity(0.55) : Color.clear)
        )
    }

    /// Abréviation FR 2 lettres du jour (LU MA ME JE VE SA DI).
    static func shortWeekday(_ date: Date) -> String {
        let symbols = ["DI", "LU", "MA", "ME", "JE", "VE", "SA"] // weekday 1=dimanche
        let weekday = Calendar.current.component(.weekday, from: date)
        return symbols[(weekday - 1) % 7]
    }
}

/// Créneau calendrier : même esprit que `GameTag` mais en **colonne** —
/// logo du jeu au-dessus, heure en dessous (texte blanc).
private struct CalendarSlot: View {
    let match: Match

    var body: some View {
        VStack(spacing: 2) {
            GameLogo(game: match.game, size: 16)
            Text(match.date, format: .dateTime.hour().minute())
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .padding(.horizontal, 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(GameStyle.color(for: match.game).opacity(0.18))
        )
    }
}

// MARK: - Composants partagés

private struct WidgetHeader: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("M8")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(DesignTokens.todayHighlight)
            Text("Prochains matchs")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Spacer(minLength: 0)
        }
    }
}

private struct MatchRow: View {
    let match: Match

    var body: some View {
        HStack(spacing: 10) {
            GameTag(game: match.game)
                .frame(width: 96, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(match.opponent)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DesignTokens.todayHighlight)
                    .lineLimit(1)
                Text(match.competition)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 2) {
                Text(match.date, format: .dateTime.weekday(.abbreviated))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(match.date, format: .dateTime.hour().minute())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DesignTokens.todayHighlight)
            }
        }
    }
}

/// Logo coloré du jeu (SVG vectoriel embarqué). Fallback sur une pastille
/// colorée si le jeu n'a pas d'asset (`logoAssetName` nil) — pas de trou vide.
private struct GameLogo: View {
    let game: String
    var size: CGFloat = 14

    var body: some View {
        if let asset = GameStyle.logoAssetName(for: game) {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Circle()
                .fill(GameStyle.color(for: game))
                .frame(width: size * 0.6, height: size * 0.6)
        }
    }
}

/// Puce horizontale par jeu (logo + nom), fond teinté par la couleur du jeu.
private struct GameTag: View {
    let game: String

    var body: some View {
        HStack(spacing: 5) {
            GameLogo(game: game, size: 14)
            Text(game)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DesignTokens.todayHighlight)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(GameStyle.color(for: game).opacity(0.18))
        )
    }
}

private struct EmptyStateLabel: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

#Preview("Liste", as: .systemMedium) {
    GentleMatesWidget()
} timeline: {
    MatchEntry(date: .now, matches: Match.sampleWeek, span: .liste, errorMessage: nil)
}

#Preview("Calendrier 3j", as: .systemMedium) {
    GentleMatesWidget()
} timeline: {
    MatchEntry(date: .now, matches: Match.sampleWeek, span: .troisJours, errorMessage: nil)
}

#Preview("Calendrier 7j", as: .systemMedium) {
    GentleMatesWidget()
} timeline: {
    MatchEntry(date: .now, matches: Match.sampleWeek, span: .septJours, errorMessage: nil)
}

#Preview("Small", as: .systemSmall) {
    GentleMatesWidget()
} timeline: {
    MatchEntry(date: .now, matches: Match.sampleWeek, span: .liste, errorMessage: nil)
}
