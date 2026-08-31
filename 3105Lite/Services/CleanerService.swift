import Foundation

struct CleanerItem: Identifiable, Sendable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let category: CleanCategory

    enum CleanCategory: String, Sendable {
        case cache = "Cache Files"
        case temporary = "Temporary Files"
        case logs = "Logs"
    }
}

actor CleanerService {
    private let fileManager = FileManager.default

    /// Quét các thư mục rác/cache
    func scanForJunk(in rootURL: URL) async throws -> [CleanerItem] {
        var items: [CleanerItem] = []

        let resourceKeys: [URLResourceKey] = [
            .isDirectoryKey,
            .fileSizeKey
        ]

        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: resourceKeys,
            options: [
                .skipsHiddenFiles,
                .skipsPackageDescendants
            ]
        ) else {
            return items
        }

        for case let fileURL as URL in enumerator {
            guard
                let resourceValues = try? fileURL.resourceValues(
                    forKeys: Set(resourceKeys)
                ),
                let isDirectory = resourceValues.isDirectory,
                !isDirectory
            else {
                continue
            }

            let pathLower = fileURL.path.lowercased()
            let size = Int64(resourceValues.fileSize ?? 0)

            if pathLower.contains("cache")
                || pathLower.contains("tmp")
                || pathLower.hasSuffix(".log") {

                let category: CleanerItem.CleanCategory

                if pathLower.hasSuffix(".log") {
                    category = .logs
                } else if pathLower.contains("cache") {
                    category = .cache
                } else {
                    category = .temporary
                }

                let item = CleanerItem(
                    url: fileURL,
                    name: fileURL.lastPathComponent,
                    size: size,
                    category: category
                )

                items.append(item)
            }
        }

        return items
    }

    /// Xóa danh sách file rác
    func clean(items: [CleanerItem]) throws {
        for item in items {
            var coordinationError: NSError?

            NSFileCoordinator().coordinate(
                writingItemAt: item.url,
                options: .forDeleting,
                error: &coordinationError
            ) { coordinatedURL in
                try? fileManager.removeItem(at: coordinatedURL)
            }

            if let coordinationError {
                throw coordinationError
            }
        }
    }
}