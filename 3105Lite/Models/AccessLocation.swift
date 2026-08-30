import Foundation

/// Đại diện cho một thư mục ngoài Sandbox đã được người dùng cấp quyền qua Document Picker.
struct AccessLocation: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let bookmarkData: Data
    
    init(id: UUID = UUID(), name: String, bookmarkData: Data) {
        self.id = id
        self.name = name
        self.bookmarkData = bookmarkData
    }
}
