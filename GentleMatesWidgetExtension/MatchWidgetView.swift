import WidgetKit
import SwiftUI

/// Vue racine : calendrier des matchs, en colonnes par jour, **sans bandeau**.
/// La taille du widget fixe le nombre de jours : small = 3, medium = 7.
/// Jusqu'à 4 matchs par jour ; un match en cours est signalé par une bordure
/// de la couleur du jeu (pleine opacité). (Toute couleur passe par `DesignTokens`.)
struct MatchWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MatchEntry
    var maxPerDay: Int = 4

    private var dayCount: Int { family == .systemSmall ? 3 : 7 }

    var body: some View {
        CalendarView(
            dayCount: dayCount,
            matches: entry.matches,
            errorMessage: entry.errorMessage,
            compact: family == .systemSmall,
            maxPerDay: maxPerDay
        )
        .containerBackground(DesignTokens.background, for: .widget)
    }
}

// MARK: - Calendrier : colonnes par jour

private struct CalendarView: View {
    let dayCount: Int
    let matches: [Match]
    let errorMessage: String?
    let compact: Bool
    let maxPerDay: Int

    private let slotSpacing: CGFloat = 3
    private let dayLabelHeight: CGFloat = 15

    private var days: [Date] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        return (0..<dayCount).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        Group {
            if matches.isEmpty {
                EmptyStateLabel(message: errorMessage ?? "Aucun match à venir")
            } else {
                GeometryReader { geo in
                    // Hauteur de créneau = espace dispo / nb max par jour → boxes
                    // uniformes ET qui rentrent, quelle que soit la taille.
                    let available = geo.size.height - dayLabelHeight - slotSpacing
                    let rawHeight = (available - CGFloat(maxPerDay - 1) * slotSpacing) / CGFloat(maxPerDay)
                    let slotHeight = min(38, max(20, rawHeight))

                    HStack(alignment: .top, spacing: compact ? 3 : 4) {
                        ForEach(days, id: \.self) { day in
                            DayColumn(
                                day: day,
                                matches: matches(on: day),
                                maxPerDay: maxPerDay,
                                slotHeight: slotHeight,
                                slotSpacing: slotSpacing
                            )
                        }
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
    let maxPerDay: Int
    let slotHeight: CGFloat
    let slotSpacing: CGFloat

    private var isToday: Bool { Calendar.current.isDateInToday(day) }

    var body: some View {
        VStack(spacing: slotSpacing) {
            Text(Self.shortWeekday(day))
                .font(.caption2.weight(.bold))
                .foregroundStyle(isToday ? DesignTokens.todayHighlight : .secondary)

            ForEach(matches.prefix(maxPerDay)) { match in
                CalendarSlot(match: match, height: slotHeight)
            }
            if matches.count > maxPerDay {
                Text("+\(matches.count - maxPerDay)")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .top)
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

/// Créneau : logo du jeu au-dessus, heure en dessous (blanc), fond teinté par le jeu.
/// Hauteur imposée par le parent → toutes les boxes identiques. Un match en cours
/// reçoit une bordure de la couleur du jeu (pleine opacité).
private struct CalendarSlot: View {
    let match: Match
    let height: CGFloat

    /// Heure toujours en 24h (`HH:mm`), quelle que soit la locale de l'appareil.
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var logoSize: CGFloat { min(16, max(11, height * 0.48)) }

    var body: some View {
        VStack(spacing: 1) {
            GameLogo(game: match.game, size: logoSize)
            Text(Self.timeFormatter.string(from: match.date))
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(GameStyle.color(for: match.game).opacity(0.18))
        )
        // Match en cours : bordure de la couleur du jeu en pleine opacité.
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    GameStyle.color(for: match.game),
                    lineWidth: match.status == .live ? 1.5 : 0
                )
        )
    }
}

// MARK: - Composants partagés

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

private struct EmptyStateLabel: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Previews

#Preview("Small — 3 jours", as: .systemSmall) {
    GentleMatesWidget()
} timeline: {
    MatchEntry(date: .now, matches: Match.sampleWeek, errorMessage: nil)
}

#Preview("Medium — 7 jours", as: .systemMedium) {
    GentleMatesWidget()
} timeline: {
    MatchEntry(date: .now, matches: Match.sampleWeek, errorMessage: nil)
}
