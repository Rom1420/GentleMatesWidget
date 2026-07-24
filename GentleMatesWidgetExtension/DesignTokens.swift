import SwiftUI

enum DesignTokens {

    // MARK: - Base (confirmé depuis screenshot du planning)

    /// Fond général de l'app
    static let background = Color(hex: "#232323")

    /// Fond des cases par défaut / nav bar / tab bar
    static let surface = Color(hex: "#383838")

    /// Highlight de la colonne "aujourd'hui" dans le calendrier
    static let todayHighlight = Color(hex: "#ECECEC")

    // MARK: - Couleurs par jeu (source : background-color du bouton actif sur gentlemates.com/esports)

    enum GameColor {
        static let valorant = Color(hex: "#EE3694")
        static let valorantGameChangers = Color(hex: "#EE3694") // réutilise la couleur Valorant
        static let callOfDuty = Color(hex: "#EC8FFF")
        static let warzone = Color(hex: "#CEF930")
        static let fortnite = Color(hex: "#F7A221")
        static let rocketLeague = Color(hex: "#7F0CFF")
        static let counterStrike2 = Color(hex: "#185D98")
        static let ageOfEmpires = Color(hex: "#FFC73B")
        static let teamfightTactics = Color(hex: "#80F1A6")
        static let fightingGames = Color(hex: "#31C3FE")
        // Pas de League of Legends : Gentle Mates n'est plus sur ce jeu
    }

    // MARK: - Pictogrammes par jeu

    /// Pattern général : {slug}-black-pictogram.svg (noir) ou {slug}-pictogram.svg (couleur),
    /// dans les dossiers "Black" ou "Colored". Pas de dossier "White".
    /// 2 exceptions à la convention :
    ///  - Warzone : fichiers nommés "PictoWZBlack.svg" / "PictoWZColored.svg", tous les deux
    ///    stockés dans le sous-dossier "Black/" (pas de fichier dans "Colored/").
    ///  - Fighting Games (FGC) : hors du dossier "6 - Games Pictograms", en PNG dans un
    ///    dossier séparé "FGC/" (fgc_black_picto.png / fgc_colored_picto.png).
    enum GamePictogram {
        private static let baseURL = "https://auth.gentlemates.com/storage/v1/render/image/public/gentle-mates-assets"

        static func url(slug: String, colored: Bool) -> URL {
            let folder = colored ? "Colored" : "Black"
            let filename = colored ? "\(slug)-pictogram.svg" : "\(slug)-black-pictogram.svg"
            return URL(string: "\(baseURL)/6%20-%20Games%20Pictograms/\(folder)/\(filename)")!
        }

        // Slugs standards
        static let valorant = "valorant"
        static let callOfDuty = "cod"
        static let fortnite = "fortnite"
        static let rocketLeague = "rl"
        static let counterStrike2 = "cs2"
        static let ageOfEmpires = "aoe"
        static let teamfightTactics = "tft"

        // Warzone — nommage irrégulier, les 2 fichiers sont dans "Black/"
        static let warzoneBlackURL = URL(string: "\(baseURL)/6%20-%20Games%20Pictograms/Black/PictoWZBlack.svg")!
        static let warzoneColoredURL = URL(string: "\(baseURL)/6%20-%20Games%20Pictograms/Black/PictoWZColored.svg")!

        // Fighting Games — hors dossier "6 - Games Pictograms", en PNG
        static let fgcBlackURL = URL(string: "\(baseURL)/FGC/fgc_black_picto.png")!
        static let fgcColoredURL = URL(string: "\(baseURL)/FGC/fgc_colored_picto.png")!
    }

    /// Placeholder — pas confirmé officiellement, à swap si Gentle Mates répond
    /// avec le nom exact. Ajouter "Poppins-Bold.ttf" etc. aux Fonts Provided by
    /// Application dans le target (app + widget extension).
    static let fontPrimary = "Poppins"
}

// MARK: - Helper pour parser un hex en Color

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
