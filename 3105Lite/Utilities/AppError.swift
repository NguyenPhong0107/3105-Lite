import Foundation

enum AppError: LocalizedError {
    case permissionDenied(URL)
    case bookmarkCreationFailed(URL)
    case staleBookmark(URL)
    case fileNotFound(URL)
    case readFailed(URL, String)
    case writeFailed(URL, String)
    case generic(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied(let url):
            return "Không có quyền truy cập vào: \(url.lastPathComponent). Vui lòng kiểm tra lại quyền."
        case .bookmarkCreationFailed(let url):
            return "Không thể tạo Security-Scoped Bookmark cho: \(url.lastPathComponent)."
        case .staleBookmark(let url):
            return "Quyền truy cập thư mục \(url.lastPathComponent) đã hết hạn hoặc thư mục đã bị di chuyển."
        case .fileNotFound(let url):
            return "Không tìm thấy tệp hoặc thư mục: \(url.lastPathComponent)."
        case .readFailed(_, let reason), .writeFailed(_, let reason):
            return reason
        case .generic(let message):
            return message
        }
    }
}
