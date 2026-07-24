import Foundation

/// Unique endroit où l'on décide quel `MatchesProvider` alimente le widget.
///
/// Le brief impose que le switch mock <-> API se fasse ici et nulle part ailleurs.
/// Pour passer à la vraie API : commenter la ligne mock, décommenter la ligne API.
enum ProviderFactory {

    static func makeProvider() -> MatchesProvider {
        // --- POC : données factices ---
        MockMatchesProvider()

        // --- Vraie API (une fois GentleMatesAPIProvider implémenté) ---
        // GentleMatesAPIProvider()
    }
}
