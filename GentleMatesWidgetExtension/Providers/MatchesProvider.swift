import Foundation

/// Seule dépendance du widget vis-à-vis de la source de données.
///
/// Tout le reste du code (timeline, vues) ne connaît que ce protocole, jamais une
/// implémentation concrète. Pour brancher une vraie API, il suffit de fournir une
/// nouvelle implémentation et de la retourner depuis `ProviderFactory`.
protocol MatchesProvider {
    /// Renvoie les prochains matchs, triés du plus proche au plus lointain.
    func fetchUpcomingMatches() async throws -> [Match]
}
