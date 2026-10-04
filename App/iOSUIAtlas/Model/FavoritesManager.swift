import Foundation

@MainActor
public final class FavoritesManager: ObservableObject {
    public static let shared = FavoritesManager()

    @Published public private(set) var favoriteIDs: Set<String> = []
    @Published public private(set) var recentIDs: [String] = []

    private let favoritesKey = "ios_ui_atlas_favorites"
    private let recentsKey = "ios_ui_atlas_recents"
    private let maxRecents = 25

    public init() {
        load()
    }

    public func isFavorite(_ id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    public func toggleFavorite(_ id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        saveFavorites()
    }

    public func recordViewed(_ id: String) {
        recentIDs.removeAll { $0 == id }
        recentIDs.insert(id, at: 0)
        if recentIDs.count > maxRecents {
            recentIDs.removeLast(recentIDs.count - maxRecents)
        }
        saveRecents()
    }

    public func clearRecents() {
        recentIDs.removeAll()
        saveRecents()
    }

    private func load() {
        let defaults = UserDefaults.standard
        if let favArray = defaults.stringArray(forKey: favoritesKey) {
            favoriteIDs = Set(favArray)
        }
        if let recArray = defaults.stringArray(forKey: recentsKey) {
            recentIDs = recArray
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: favoritesKey)
    }

    private func saveRecents() {
        UserDefaults.standard.set(recentIDs, forKey: recentsKey)
    }
}
