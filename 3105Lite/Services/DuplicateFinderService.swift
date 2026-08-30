import Foundation
import CryptoKit

struct DuplicateGroup: Identifiable, Sendable {
    let id = UUID()
    let hash: String
    var files: [URL]
    let size: Int64
}

actor DuplicateFinderService {
    private let fileManager = FileManager.default
    
    func findDuplicates(in rootURL: URL) async -> [DuplicateGroup] {
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey]
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return [] }
        
        // Bước 1: Nhóm theo dung lượng
        var sizeDict: [Int64: [URL]] = [:]
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                  let isDir = values.isDirectory, !isDir,
                  let size = values.fileSize, size > 0 else { continue }
            sizeDict[Int64(size), default: []].append(fileURL)
        }
        
        // Lọc ra các nhóm có > 1 tệp cùng dung lượng
        let potentialDuplicates = sizeDict.filter { $0.value.count > 1 }
        
        // Bước 2: Băm dữ liệu (Hash) để xác nhận chính xác
        var hashDict: [String: [URL]] = [:]
        var sizeForHash: [String: Int64] = [:]
        
        for (size, urls) in potentialDuplicates {
            for url in urls {
                if let hashString = hashFile(at: url) {
                    hashDict[hashString, default: []].append(url)
                    sizeForHash[hashString] = size
                }
            }
        }
        
        // Đóng gói kết quả những nhóm thực sự trùng mã Hash
        return hashDict
            .filter { $0.value.count > 1 }
            .map { DuplicateGroup(hash: $0.key, files: $0.value, size: sizeForHash[$0.key] ?? 0) }
            .sorted { $0.size > $1.size }
    }
    
    private func hashFile(at url: URL) -> String? {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
