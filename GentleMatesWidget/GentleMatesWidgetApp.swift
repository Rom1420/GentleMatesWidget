import SwiftUI

/// App conteneur minimale : elle ne sert qu'à héberger l'extension widget.
/// Toute la logique produit vit dans `GentleMatesWidgetExtension`.
@main
struct GentleMatesWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
