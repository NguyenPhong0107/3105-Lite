import Foundation

struct CleanerItem: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let category: CleanCategory
    
    enum CleanCategory: String {
        case cache = "Cache Files"
        case temporary = "Temporary Files"
        case logs = "Logs"
    }
}

actor CleanerService {
    private let fileManager = FileManager.default
    
    /// Quét các thư mục rác/cache trong một URL cho phép
    func scanForJunk(in rootURL: URL) async throws -> [CleanerItem] {
        var items: [CleanerItem] = []
        
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey]
        
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return items
        }
        
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                  let isDir = resourceValues.isDirectory, !isDir else {
                continue
            }
            
            let pathLower = fileURL.path.lowercased()
            let size = Int64(resourceValues.fileSize ?? 0)
            
            // Nhận diện tệp rác dựa trên định dạng/thư mục chuẩn
            if pathLower.contains("cache") || pathLower.contains("tmp") || pathLower.hasSuffix(".log") {
                let category: CleanerItem.CleanCategory
                if pathLower.hasSuffix(".log") {
                    category = .logs
                } else if pathLower.contains("cache") {
                    category = .cache
                } else {
                    category = .temporary
                }
                
                let item = CleanerItem(url: fileURL, name: fileURL.lastPathComponent, size: size, category: category)
                items.append(item)
            }
        }
        
        return items
    }
    
    /// Thực hiện xóa danh sách các tệp rác đã chọn
    func clean(items: [CleanerItem]) throws {
        for item in items {
            var coordinationError: NSError?
            NSFileCoordinator().coordinate(writingItemAt: item.url, options: .forDeleting, error: &coordinationError) { url in
                try? fileManager.removeItem(at: url)
            }
        }
    }
}
