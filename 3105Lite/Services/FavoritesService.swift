import Foundation
import Observation

@Observable
final class FavoritesService {
    private let favoritesKey = "user_favorite_paths"

    var favoritePaths: Set<String> = []

    init() {
        loadFavorites()
    }

    func loadFavorites() {
        guard let paths = UserDefaults.standard.stringArray(
            forKey: favoritesKey
        ) else {
            return
        }

        favoritePaths = Set(paths)
    }

    func toggleFavorite(for url: URL) {
        let path = url.path

        if favoritePaths.contains(path) {
            favoritePaths.remove(path)
        } else {
            favoritePaths.insert(path)
        }

        UserDefaults.standard.set(
            Array(favoritePaths),
            forKey: favoritesKey
        )
    }

    func isFavorite(url: URL) -> Bool {
        favoritePaths.contains(url.path)
    }
}