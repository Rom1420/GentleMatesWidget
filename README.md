# Gentle Mates — Widget iOS « Prochains matchs »

POC public d'un widget iOS (WidgetKit / SwiftUI) affichant les prochains matchs de
[Gentle Mates](https://gentlemates.com) sur l'écran d'accueil.

> **Statut :** proof of concept. Les données affichées sont **mockées** (`MockMatchesProvider`).
> L'architecture est prête à être branchée sur la vraie API du jour au lendemain, sans rien
> réécrire d'autre que l'implémentation du provider de données.

<p align="center"><em>Cible : iOS 17+ • Xcode 15+ • Swift 5</em></p>

---

## Sommaire

- [Lancer le POC](#lancer-le-poc)
- [Architecture](#architecture)
- [Brancher une vraie API](#brancher-une-vraie-api) ← le point d'entrée à lire en priorité
- [Design / Design tokens](#design--design-tokens)
- [Périmètre V1](#périmètre-v1)

---

## Lancer le POC

1. Ouvrir `GentleMatesWidget.xcodeproj` dans **Xcode 15+**.
2. Sélectionner le schéma **GentleMatesWidget** et un simulateur iOS 17+.
3. `Cmd + R` pour lancer l'app conteneur.
4. Sur le simulateur : appui long sur l'écran d'accueil → **+** → chercher **Gentle Mates**
   → ajouter le widget (tailles *small* ou *medium*).

Le widget affiche les prochains matchs fournis par `MockMatchesProvider`. Aucune configuration,
aucun réseau, aucun backend : tout tourne en local.

> ℹ️ Le widget se prévisualise aussi directement dans Xcode via les `#Preview` de
> [`MatchWidgetView.swift`](GentleMatesWidgetExtension/MatchWidgetView.swift).

---

## Architecture

La source de données est **totalement isolée** du reste du code par un protocole. Le widget,
la timeline et les vues ne connaissent que ce protocole — jamais une implémentation concrète.

```
┌─────────────────────┐     ┌──────────────────────┐     ┌───────────────────┐
│ MatchWidgetView     │ ──▶ │ MatchTimelineProvider │ ──▶ │ MatchesProvider   │  (protocole)
│ (SwiftUI)           │     │ (WidgetKit)          │     └─────────┬─────────┘
└─────────────────────┘     └──────────────────────┘               │
                                                     ┌─────────────┴──────────────┐
                                                     ▼                            ▼
                                          MockMatchesProvider          GentleMatesAPIProvider
                                          (données factices)           (stub → vraie API)
                                                     ▲
                                                     │  choisi à un seul endroit
                                              ProviderFactory.makeProvider()
```

| Fichier | Rôle |
|---|---|
| [`Providers/MatchesProvider.swift`](GentleMatesWidgetExtension/Providers/MatchesProvider.swift) | Le protocole : `fetchUpcomingMatches() async throws -> [Match]` |
| [`Providers/MockMatchesProvider.swift`](GentleMatesWidgetExtension/Providers/MockMatchesProvider.swift) | Données factices (le POC tourne dessus) |
| [`Providers/GentleMatesAPIProvider.swift`](GentleMatesWidgetExtension/Providers/GentleMatesAPIProvider.swift) | **Stub** de la vraie API — point d'insertion |
| [`Providers/APIConfiguration.swift`](GentleMatesWidgetExtension/Providers/APIConfiguration.swift) | Config (baseURL / apiKey) chargée d'un fichier non commité |
| [`Providers/ProviderFactory.swift`](GentleMatesWidgetExtension/Providers/ProviderFactory.swift) | **Le seul endroit** où l'on choisit le provider actif |
| [`Models/Match.swift`](GentleMatesWidgetExtension/Models/Match.swift) | Le contrat de données `Match` (stable) |
| [`MatchTimelineProvider.swift`](GentleMatesWidgetExtension/MatchTimelineProvider.swift) | `TimelineProvider` WidgetKit |
| [`GentleMatesWidgetBundle.swift`](GentleMatesWidgetExtension/GentleMatesWidgetBundle.swift) | Le widget calendrier (small = 3 j / medium = 7 j) |
| [`MatchWidgetView.swift`](GentleMatesWidgetExtension/MatchWidgetView.swift) | Vue calendrier SwiftUI (colonnes par jour, header M8 / LIVE) |
| [`DesignTokens.swift`](GentleMatesWidgetExtension/DesignTokens.swift) | Couleurs / typo centralisées |

**Pas de backend / BFF.** Le calendrier des matchs est une donnée publique (déjà affichée sans
compte ni paywall dans l'app), donc tout reste côté client pour ce POC.

---

## Brancher une vraie API

Tout est prêt : brancher l'API réelle ne touche **que** le provider, jamais les vues ni la timeline.
En 4 étapes :

### 1. Implémenter `GentleMatesAPIProvider.fetchUpcomingMatches()`

Dans [`GentleMatesAPIProvider.swift`](GentleMatesWidgetExtension/Providers/GentleMatesAPIProvider.swift),
remplacer le `throw APIError.notImplemented` par la vraie requête réseau (un exemple complet est
déjà en commentaire dans le fichier) :

```swift
let url = config.baseURL.appendingPathComponent("matches/upcoming")
var request = URLRequest(url: url)
if let apiKey = config.apiKey {
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
}
let (data, response) = try await session.data(for: request)
// ... vérifier le statut, décoder ...
```

### 2. Mapper le JSON réel vers `Match`

Définir un type `RemoteMatch` qui colle au **vrai** schéma renvoyé par l'API, puis compléter la
fonction `map(_:)` (déjà esquissée en commentaire) pour le convertir vers
[`Match`](GentleMatesWidgetExtension/Models/Match.swift). `Match` est le contrat **stable** côté
widget : c'est le JSON qui s'adapte à lui, pas l'inverse.

### 3. Renseigner la configuration (non commitée)

1. Copier [`APIConfig.example.plist`](GentleMatesWidgetExtension/APIConfig.example.plist) en
   `APIConfig.plist` (même dossier).
2. Renseigner `baseURL` (et `apiKey` si l'API en exige une).
3. Ajouter `APIConfig.plist` au **Target Membership** de `GentleMatesWidgetExtension` pour qu'il
   soit embarqué dans le bundle.

> `APIConfig.plist` est déjà **gitignoré** — il ne sera jamais commité.

### 4. Activer le provider API

Dans [`ProviderFactory.swift`](GentleMatesWidgetExtension/Providers/ProviderFactory.swift),
inverser les deux lignes :

```swift
static func makeProvider() -> MatchesProvider {
    // MockMatchesProvider()          // ← commenter
    GentleMatesAPIProvider()          // ← décommenter
}
```

C'est tout. Aucun autre fichier à modifier.

---

## Design / Design tokens

Aucun press kit officiel avec codes hex n'a été trouvé : la DA a été extraite manuellement
(captures de l'app + pipette) et centralisée dans
[`DesignTokens.swift`](GentleMatesWidgetExtension/DesignTokens.swift). Le widget et l'app
consomment **exclusivement** ces tokens — aucune couleur ni police en dur ailleurs.

- Couleurs de base (fond, surface, highlight) confirmées depuis un screenshot du planning.
- Couleur par jeu résolue via [`GameStyle.color(for:)`](GentleMatesWidgetExtension/GameStyle.swift),
  qui mappe le nom de jeu vers `DesignTokens.GameColor`.
- **Police :** `fontPrimary = "Poppins"` est un **placeholder** non confirmé. Pour l'activer :
  ajouter les `.ttf` (`Poppins-Bold.ttf`, etc.) au projet + « Fonts provided by application »
  dans les Info des deux targets.

---

## Périmètre V1

Volontairement limité (voir le brief) :

- ✅ Tailles **small** + **medium**.
- ✅ **Vue calendrier** en colonnes par jour (logo du jeu + heure), jour courant surligné.
- ✅ **2 tailles** : *small* = 3 prochains jours, *medium* = 7 jours (la semaine).
- ✅ Header : blason **M8** centré + badge **LIVE** toujours présent (pastille + texte **rouges** quand un match est en cours, clair sinon).
- ℹ️ `StaticConfiguration` (pas d'App Intents : un widget configurable reste bloqué sur son
  placeholder en simulateur / Appetize — voir la note dans `GentleMatesWidgetBundle.swift`).
- ❌ Pas de configuration utilisateur (filtre par jeu…).
- ❌ Pas de Live Activities, pas de deep link vers l'app.
- ❌ Pas de backend / serveur.

---

## Structure du repo

```
GentleMatesWidget.xcodeproj
GentleMatesWidget/                     # App conteneur minimale (héberge l'extension)
│   ├── GentleMatesWidgetApp.swift
│   └── ContentView.swift
GentleMatesWidgetExtension/
│   ├── Providers/
│   │   ├── MatchesProvider.swift       # le protocole
│   │   ├── MockMatchesProvider.swift   # données factices (actif)
│   │   ├── GentleMatesAPIProvider.swift# stub API
│   │   ├── APIConfiguration.swift
│   │   └── ProviderFactory.swift       # switch mock <-> API (un seul endroit)
│   ├── Models/
│   │   └── Match.swift                 # contrat de données
│   ├── DesignTokens.swift
│   ├── GameStyle.swift                 # nom de jeu -> token couleur
│   ├── MatchTimelineProvider.swift     # TimelineProvider WidgetKit
│   ├── MatchWidgetView.swift           # vue calendrier (small 3 j / medium 7 j)
│   ├── GentleMatesWidgetBundle.swift   # @main WidgetBundle (widget calendrier)
│   ├── Info.plist
│   └── APIConfig.example.plist         # modèle de config (copier en APIConfig.plist)
└── README.md
```
