import WidgetKit
import SwiftUI

/// Vue racine : choisit la mise en page selon la famille de widget.
/// V1 : small + medium. (Toute couleur passe par `DesignTokens` / `GameStyle`.)
struct MatchWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MatchEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallMatchView(match: entry.matches.first, errorMessage: entry.errorMessage)
            default:
                MediumMatchView(matches: entry.matches, errorMessage: entry.errorMessage)
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

// MARK: - Medium : 2-3 prochains matchs

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

/// Puce colorée par jeu (couleur issue de `DesignTokens.GameColor` via `GameStyle`).
private struct GameTag: View {
    let game: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(GameStyle.color(for: game))
                .frame(width: 8, height: 8)
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

#Preview("Medium", as: .systemMedium) {
    GentleMatesWidget()
} timeline: {
    MatchEntry.placeholder
}

#Preview("Small", as: .systemSmall) {
    GentleMatesWidget()
} timeline: {
    MatchEntry.placeholder
}
