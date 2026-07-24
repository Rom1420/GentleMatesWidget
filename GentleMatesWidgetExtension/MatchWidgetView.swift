import WidgetKit
import SwiftUI

/// Vue racine : calendrier des matchs, en colonnes par jour.
/// La taille du widget fixe le nombre de jours affichés :
///  - **small**  → 3 prochains jours,
///  - **medium** → 7 jours (la semaine).
/// (Toute couleur passe par `DesignTokens` / `GameStyle`.)
struct MatchWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MatchEntry

    private var dayCount: Int { family == .systemSmall ? 3 : 7 }

    var body: some View {
        CalendarView(
            dayCount: dayCount,
            matches: entry.matches,
            errorMessage: entry.errorMessage,
            compact: family == .systemSmall
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

    private var days: [Date] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        return (0..<dayCount).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private var hasLive: Bool { matches.contains { $0.status == .live } }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 8) {
            WidgetHeader(isLive: hasLive, compact: compact)

            if matches.isEmpty {
                Spacer(minLength: 0)
                EmptyStateLabel(message: errorMessage ?? "Aucun match à venir")
                Spacer(minLength: 0)
            } else {
                HStack(alignment: .top, spacing: compact ? 3 : 4) {
                    ForEach(days, id: \.self) { day in
                        DayColumn(day: day, matches: matches(on: day), compact: compact)
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
    let compact: Bool

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

/// Créneau : logo du jeu au-dessus, heure en dessous (texte blanc), fond teinté
/// par la couleur du jeu.
private struct CalendarSlot: View {
    let match: Match

    /// Heure toujours en 24h (`HH:mm`), quelle que soit la locale de l'appareil.
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 2) {
            GameLogo(game: match.game, size: 16)
            Text(Self.timeFormatter.string(from: match.date))
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

// MARK: - Header : blason M8 centré + badge LIVE à droite

private struct WidgetHeader: View {
    let isLive: Bool
    let compact: Bool

    var body: some View {
        ZStack {
            Image("m8-logo")
                .resizable()
                .scaledToFit()
                .frame(height: compact ? 18 : 22)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                LiveBadge(isLive: isLive)
                Spacer()
            }
        }
    }
}

/// Pastille "● LIVE" toujours présente dans le header : pastille + texte en **rouge**
/// quand un match est en cours, sinon en clair (gris/blanc).
private struct LiveBadge: View {
    let isLive: Bool

    private var color: Color {
        isLive ? .red : DesignTokens.todayHighlight.opacity(0.7)
    }

    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("LIVE")
                .font(.system(size: 10, weight: .heavy))
                .italic()
                .foregroundStyle(color)
        }
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
            .frame(maxWidth: .infinity, alignment: .center)
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
