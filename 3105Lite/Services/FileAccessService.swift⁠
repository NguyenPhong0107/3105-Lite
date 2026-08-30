import Foundation

@Observable
final class FileAccessService {
    // Lưu danh sách location để UI (Dashboard) có thể bind và hiển thị
    var savedLocations: [AccessLocation] = []
    
    private let userDefaultsKey = "com.3105lite.savedLocations"
    
    init() {
        loadLocations()
    }
    
    /// Lưu URL được chọn từ Document Picker vào Bookmark
    func saveBookmark(for url: URL) throws {
        // Yêu cầu quyền truy cập vào URL trước khi tạo bookmark
        guard url.startAccessingSecurityScopedResource() else {
            throw AppError.permissionDenied(url)
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let bookmarkData = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        
        let newLocation = AccessLocation(
            name: url.lastPathComponent,
            bookmarkData: bookmarkData
        )
        
        // Tránh trùng lặp
        if !savedLocations.contains(where: { $0.name == newLocation.name }) {
            savedLocations.append(newLocation)
            persistLocations()
        }
    }
    
    /// Giải mã Bookmark Data thành URL có thể truy cập được
    func resolveBookmark(for location: AccessLocation) throws -> URL {
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: location.bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        
        if isStale {
            // Nếu iOS báo stale (VD: người dùng đổi tên thư mục), cần cập nhật lại bookmark (sẽ implement ở phase sau)
            throw AppError.staleBookmark(url)
        }
        return url
    }
    
    /// Wrapper thần thánh: MỌI thao tác file (Read/Write/Delete) trong các thư mục được cấp quyền PHẢI chạy qua hàm này
    func performSecureAccess<T>(url: URL, action: () throws -> T) throws -> T {
        let hasAccess = url.startAccessingSecurityScopedResource()
        
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        // Thử thực thi action. Nếu lỗi ném ra ngoài
        return try action()
    }
    
    /// Tương tự performSecureAccess nhưng hỗ trợ Async/Await
    func performSecureAccessAsync<T>(url: URL, action: () async throws -> T) async throws -> T {
        let hasAccess = url.startAccessingSecurityScopedResource()
        
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        return try await action()
    }
    
    func removeLocation(_ location: AccessLocation) {
        savedLocations.removeAll { $0.id == location.id }
        persistLocations()
    }
    
    // MARK: - Private Persistence
    private func persistLocations() {
        if let data = try? JSONEncoder().encode(savedLocations) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func loadLocations() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let locations = try? JSONDecoder().decode([AccessLocation].self, from: data) else {
            return
        }
        self.savedLocations = locations
    }
}
