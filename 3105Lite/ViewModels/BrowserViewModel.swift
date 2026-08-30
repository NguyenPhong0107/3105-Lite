import Foundation
import SwiftUI

@Observable
final class BrowserViewModel {
    var files: [FileItem] = []
    var errorMessage: String?
    var isLoading: Bool = false
    
    // Dependency Injection
    private let fileAccessService: FileAccessService
    
    init(fileAccessService: FileAccessService) {
        self.fileAccessService = fileAccessService
    }
    
    /// Đọc danh sách file từ một URL
    func loadFiles(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        do {
            // PHẢI dùng wrapper này để đảm bảo quyền Security-Scoped
            self.files = try fileAccessService.performSecureAccess(url: url) {
                
                let keys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey, .creationDateKey, .contentModificationDateKey]
                
                // Đọc nội dung thư mục, bỏ qua các file ẩn (tuỳ chọn)
                let urls = try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: keys,
                    options: [.skipsHiddenFiles]
                )
                
                // Map URL thành FileItem Model
                return urls.compactMap { fileURL in
                    guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(keys)) else { return nil }
                    let isDir = resourceValues.isDirectory ?? false
                    let size = Int64(resourceValues.fileSize ?? 0)
                    
                    return FileItem(
                        id: fileURL,
                        url: fileURL,
                        name: fileURL.lastPathComponent,
                        isDirectory: isDir,
                        size: size,
                        creationDate: resourceValues.creationDate,
                        modificationDate: resourceValues.contentModificationDate
                    )
                }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
