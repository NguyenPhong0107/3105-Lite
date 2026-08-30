import Foundation
import SwiftUI

@Observable
final class CleanerViewModel {
    var items: [CleanerItem] = []
    var isScanning: Bool = false
    var isCleaning: Bool = false
    var errorMessage: String?
    var freedSpaceMessage: String?
    
    private let cleanerService = CleanerService()
    private let fileAccessService: FileAccessService
    
    var totalJunkSize: Int64 {
        items.reduce(0) { $0 + $1.size }
    }
    
    init(fileAccessService: FileAccessService) {
        self.fileAccessService = fileAccessService
    }
    
    func startScanning() async {
        isScanning = true
        errorMessage = nil
        items.removeAll()
        
        do {
            var allItems: [CleanerItem] = []
            
            // Quét qua tất cả các location người dùng đã cấp quyền + App container chính
            let appContainer = fileManagerContainerURL()
            let scanLocations = [appContainer] + fileAccessService.savedLocations.compactMap { try? fileAccessService.resolveBookmark(for: $0) }
            
            for location in scanLocations {
                let found = try await cleanerService.scanForJunk(in: location)
                allItems.append(contentsOf: found)
            }
            
            self.items = allItems
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isScanning = false
    }
    
    func performClean() async {
        isCleaning = false // Sửa lại thành true khi bắt đầu
        isCleaning = true
        do {
            try await cleanerService.clean(items: items)
            let freed = totalJunkSize
            items.removeAll()
            freedSpaceMessage = "Đã giải phóng thành công \(formatBytes(freed))!"
        } catch {
            self.errorMessage = "Lỗi khi dọn dẹp: \(error.localizedDescription)"
        }
        isCleaning = false
    }
    
    private func fileManagerContainerURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
