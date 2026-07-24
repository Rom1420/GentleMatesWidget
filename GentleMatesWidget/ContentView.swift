import SwiftUI

/// Écran d'accueil de l'app conteneur : explique comment ajouter le widget.
/// Consomme exclusivement `DesignTokens` (aucune couleur en dur).
struct ContentView: View {
    var body: some View {
        ZStack {
            DesignTokens.background.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Gentle Mates")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(DesignTokens.todayHighlight)

                Text("Widget « Prochains matchs »")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("Ajoutez le widget depuis l'écran d'accueil :\nappui long → « + » → Gentle Mates.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DesignTokens.todayHighlight.opacity(0.8))
                    .padding(.horizontal, 24)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
