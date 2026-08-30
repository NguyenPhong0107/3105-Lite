import Foundation
import UniformTypeIdentifiers

struct LargeFileItem: Identifiable, Sendable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let modificationDate: Date?
}

struct StorageCategoryStats: Sendable {
    var imagesSize: Int64 = 0
    var videosSize: Int64 = 0
    var audioSize: Int64 = 0
    var documentsSize: Int64 = 0
    var archivesSize: Int64 = 0
    var otherSize: Int64 = 0
    
    var totalSize: Int64 {
        imagesSize + videosSize + audioSize + documentsSize + archivesSize + otherSize
    }
}

actor StorageAnalyzerService {
    private let fileManager = FileManager.default
    
    /// Phân tích dung lượng theo danh mục và tìm các tệp lớn hơn threshold (VD: 50MB)
    func analyze(rootURL: URL, sizeThreshold: Int64 = 50 * 1024 * 1024) async -> (stats: StorageCategoryStats, largeFiles: [LargeFileItem]) {
        var stats = StorageCategoryStats()
        var largeFiles: [LargeFileItem] = []
        
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
        
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return (stats, largeFiles)
        }
        
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                  let isDir = resourceValues.isDirectory, !isDir else {
                continue
            }
            
            let size = Int64(resourceValues.fileSize ?? 0)
            let modDate = resourceValues.contentModificationDate
            
            // 1. Phân loại theo UniformTypeIdentifiers (UTType)
            let ext = fileURL.pathExtension.lowercased()
            let utType = UTType(filenameExtension: ext) ?? .data
            
            if utType.conforms(to: .image) {
                stats.imagesSize += size
            } else if utType.conforms(to: .movie) || utType.conforms(to: .video) {
                stats.videosSize += size
            } else if utType.conforms(to: .audio) {
                stats.audioSize += size
            } else if utType.conforms(to: .pdf) || utType.conforms(to: .text) || utType.conforms(to: .spreadsheet) {
                stats.documentsSize += size
            } else if utType.conforms(to: .archive) {
                stats.archivesSize += size
            } else {
                stats.otherSize += size
            }
            
            // 2. Kiểm tra nếu vượt ngưỡng tệp lớn
            if size >= sizeThreshold {
                let largeItem = LargeFileItem(
                    url: fileURL,
                    name: fileURL.lastPathComponent,
                    size: size,
                    modificationDate: modDate
                )
                largeFiles.append(largeItem)
            }
        }
        
        largeFiles.sort { $0.size > $1.size }
        return (stats, largeFiles)
    }
}
