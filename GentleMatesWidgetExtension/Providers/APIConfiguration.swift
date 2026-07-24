import Foundation

/// Configuration d'accès à la vraie API (baseURL + clé éventuelle).
///
/// Les valeurs sont chargées depuis `APIConfig.plist`, un fichier **non commité**
/// (voir `.gitignore` + `APIConfig.example.plist`). Tant qu'aucun fichier n'est fourni,
/// `load()` renvoie une config vide — ce qui est normal en mode mock.
struct APIConfiguration {
    let baseURL: URL
    let apiKey: String?

    /// Config par défaut inoffensive utilisée tant qu'aucun `APIConfig.plist` n'est présent.
    /// La baseURL est un placeholder : le `GentleMatesAPIProvider` reste un stub de toute façon.
    static let empty = APIConfiguration(
        baseURL: URL(string: "https://example.invalid")!,
        apiKey: nil
    )

    /// Charge la config depuis `APIConfig.plist` embarqué dans le bundle de l'extension.
    /// Retombe sur `.empty` si le fichier est absent ou mal formé.
    static func load(bundle: Bundle = .main) -> APIConfiguration {
        guard
            let url = bundle.url(forResource: "APIConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(
                from: data, format: nil
            ) as? [String: Any],
            let baseURLString = dict["baseURL"] as? String,
            let baseURL = URL(string: baseURLString)
        else {
            return .empty
        }

        let apiKey = (dict["apiKey"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        return APIConfiguration(baseURL: baseURL, apiKey: apiKey)
    }
}
