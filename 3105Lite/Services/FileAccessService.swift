import Foundation
import Observation

@Observable
final class FileAccessService {
    var savedLocations: [AccessLocation] = []

    private let userDefaultsKey = "com.3105lite.savedLocations"

    init() {
        loadLocations()
    }

    /// Lưu URL được chọn từ Document Picker
    func saveBookmark(for url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw AppError.permissionDenied(url)
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        let bookmarkData = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )

        let newLocation = AccessLocation(
            name: url.lastPathComponent,
            bookmarkData: bookmarkData
        )

        if !savedLocations.contains(where: {
            $0.name == newLocation.name
        }) {
            savedLocations.append(newLocation)
            persistLocations()
        }
    }

    /// Giải mã Bookmark Data thành URL
    func resolveBookmark(for location: AccessLocation) throws -> URL {
        var isStale = false

        let url = try URL(
            resolvingBookmarkData: location.bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )

        if isStale {
            throw AppError.staleBookmark(url)
        }

        return url
    }

    /// Thực hiện thao tác file trong security-scoped URL
    func performSecureAccess<T>(
        url: URL,
        action: () throws -> T
    ) throws -> T {
        let hasAccess = url.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        return try action()
    }

    /// Phiên bản hỗ trợ async/await
    func performSecureAccessAsync<T>(
        url: URL,
        action: () async throws -> T
    ) async throws -> T {
        let hasAccess = url.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        return try await action()
    }

    func removeLocation(_ location: AccessLocation) {
        savedLocations.removeAll {
            $0.id == location.id
        }

        persistLocations()
    }

    private func persistLocations() {
        if let data = try? JSONEncoder().encode(savedLocations) {
            UserDefaults.standard.set(
                data,
                forKey: userDefaultsKey
            )
        }
    }

    private func loadLocations() {
        guard
            let data = UserDefaults.standard.data(
                forKey: userDefaultsKey
            ),
            let locations = try? JSONDecoder().decode(
                [AccessLocation].self,
                from: data
            )
        else {
            return
        }

        savedLocations = locations
    }
}