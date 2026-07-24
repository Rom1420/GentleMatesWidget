import SwiftUI

/// Résout un nom de jeu (le champ `Match.game`, une simple `String`) vers les tokens
/// visuels correspondants (couleur, slug de pictogramme).
///
/// C'est le seul pont entre une donnée "jeu" en texte libre et `DesignTokens`.
/// Toute couleur affichée passe donc toujours par `DesignTokens`, jamais par une
/// valeur en dur ailleurs dans les vues.
enum GameStyle {

    /// Couleur d'accent pour un jeu donné. Retombe sur `DesignTokens.surface`
    /// si le jeu n'est pas (encore) reconnu.
    static func color(for game: String) -> Color {
        switch normalize(game) {
        case "valorant":                 return DesignTokens.GameColor.valorant
        case "valorantgamechangers",
             "gamechangers":             return DesignTokens.GameColor.valorantGameChangers
        case "callofduty", "cod":        return DesignTokens.GameColor.callOfDuty
        case "warzone":                  return DesignTokens.GameColor.warzone
        case "fortnite":                 return DesignTokens.GameColor.fortnite
        case "rocketleague", "rl":       return DesignTokens.GameColor.rocketLeague
        case "counterstrike2", "cs2":    return DesignTokens.GameColor.counterStrike2
        case "ageofempires", "aoe":      return DesignTokens.GameColor.ageOfEmpires
        case "teamfighttactics", "tft":  return DesignTokens.GameColor.teamfightTactics
        case "fightinggames", "fgc":     return DesignTokens.GameColor.fightingGames
        default:                         return DesignTokens.surface
        }
    }

    /// Enlève espaces, tirets et met en minuscules pour tolérer les variantes
    /// d'écriture ("Rocket League", "rocket-league", "RocketLeague"...).
    private static func normalize(_ game: String) -> String {
        game.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ":", with: "")
    }
}
