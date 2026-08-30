import Foundation
import UniformTypeIdentifiers

actor ZipService {
    private let fileManager = FileManager.default
    
    /// Nén một thư mục hoặc tệp thành file .zip
    func zipItem(at sourceURL: URL) throws -> URL {
        let parentDir = sourceURL.deletingLastPathComponent()
        let destinationURL = parentDir.appendingPathComponent("\(sourceURL.lastPathComponent).zip")
        
        // Nếu file zip cũ đã tồn tại thì xóa đi
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        var coordinationError: NSError?
        var operationError: Error?
        
        NSFileCoordinator().coordinate(writingItemAt: destinationURL, options: .forReplacing, error: &coordinationError) { coordZipURL in
            do {
                // Sử dụng API chuẩn của FileManager trên iOS 16+ / macOS để nén item
                try fileManager.zipItem(at: sourceURL, to: coordZipURL, shouldKeepParent: true)
            } catch {
                operationError = error
            }
        }
        
        if let error = coordinationError ?? operationError {
            throw AppError.writeFailed(destinationURL, error.localizedDescription)
        }
        
        return destinationURL
    }
    
    /// Giải nén một file .zip vào thư mục chứa nó
    func unzipItem(at zipURL: URL) throws -> URL {
        let parentDir = zipURL.deletingLastPathComponent()
        let destinationURL = parentDir.appendingPathComponent(zipURL.deletingPathExtension().lastPathComponent)
        
        // Tạo thư mục đích nếu chưa có
        if !fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
        }
        
        var coordinationError: NSError?
        var operationError: Error?
        
        NSFileCoordinator().coordinate(readingItemAt: zipURL, options: .withoutChanges, error: &coordinationError) { coordZipURL in
            do {
                try fileManager.unzipItem(at: coordZipURL, to: destinationURL)
            } catch {
                operationError = error
            }
        }
        
        if let error = coordinationError ?? operationError {
            throw AppError.readFailed(zipURL, error.localizedDescription)
        }
        
        return destinationURL
    }
}
