import Foundation
import SwiftUI
import Observation

@Observable
final class BrowserViewModel {
    var files: [FileItem] = []
    var errorMessage: String?
    var isLoading: Bool = false

    private let fileAccessService: FileAccessService

    init(fileAccessService: FileAccessService) {
        self.fileAccessService = fileAccessService
    }

    /// Đọc danh sách file từ một URL
    func loadFiles(from url: URL) {
        isLoading = true
        errorMessage = nil

        do {
            files = try fileAccessService.performSecureAccess(url: url) {
                let keys: [URLResourceKey] = [
                    .isDirectoryKey,
                    .fileSizeKey,
                    .creationDateKey,
                    .contentModificationDateKey
                ]

                let urls = try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: keys,
                    options: [.skipsHiddenFiles]
                )

                return urls
                    .compactMap { fileURL in
                        guard let resourceValues = try? fileURL.resourceValues(
                            forKeys: Set(keys)
                        ) else {
                            return nil
                        }

                        let isDirectory = resourceValues.isDirectory ?? false
                        let size = Int64(resourceValues.fileSize ?? 0)

                        return FileItem(
                            url: fileURL,
                            name: fileURL.lastPathComponent,
                            isDirectory: isDirectory,
                            size: size,
                            modificationDate: resourceValues.contentModificationDate
                        )
                    }
                    .sorted {
                        $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}