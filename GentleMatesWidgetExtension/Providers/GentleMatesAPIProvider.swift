import Foundation

/// Point d'insertion de la vraie API Gentle Mates.
///
/// ⚠️ STUB. Ce fichier ne fait **aucun appel réseau réel** pour l'instant : on n'a pas
/// l'accès à l'API. Il matérialise juste où le brancher, sans rien deviner du format.
///
/// Pour l'activer, voir la section "Brancher une vraie API" du README. En résumé :
///   1. Implémenter `fetchUpcomingMatches()` ci-dessous (requête + décodage).
///   2. Mapper le JSON réel vers `Match` (voir `map(_:)`).
///   3. Renseigner `APIConfiguration` (baseURL / apiKey) via le fichier de config non commité.
///   4. Activer ce provider dans `ProviderFactory`.
struct GentleMatesAPIProvider: MatchesProvider {

    private let config: APIConfiguration
    private let session: URLSession

    init(config: APIConfiguration = .load(), session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    func fetchUpcomingMatches() async throws -> [Match] {
        // TODO: remplacer par le vrai endpoint des matchs à venir une fois connu.
        //
        // Exemple d'implémentation attendue :
        //
        //   let url = config.baseURL.appendingPathComponent("matches/upcoming")
        //   var request = URLRequest(url: url)
        //   if let apiKey = config.apiKey {
        //       request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        //   }
        //   let (data, response) = try await session.data(for: request)
        //   guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
        //       throw APIError.badStatus
        //   }
        //   let decoded = try JSONDecoder.gentleMates.decode([RemoteMatch].self, from: data)
        //   return decoded.map(map).sorted { $0.date < $1.date }

        throw APIError.notImplemented
    }

    // MARK: - Mapping JSON réel -> Match
    //
    // TODO: définir `RemoteMatch` d'après le vrai schéma renvoyé par l'API, puis
    // compléter ce mapping. La cible (`Match`) est le contrat stable côté widget.
    //
    // private func map(_ remote: RemoteMatch) -> Match {
    //     Match(
    //         id: remote.id,
    //         game: remote.game,
    //         team: remote.team,
    //         opponent: remote.opponent,
    //         date: remote.startsAt,
    //         competition: remote.competition,
    //         status: MatchStatus(rawValue: remote.status) ?? .upcoming,
    //         score: remote.score
    //     )
    // }

    enum APIError: Error {
        case notImplemented
        case badStatus
        case missingConfiguration
    }
}
