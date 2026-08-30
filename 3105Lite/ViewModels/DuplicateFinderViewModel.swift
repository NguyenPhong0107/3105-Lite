import Foundation
import SwiftUI

@Observable
final class DuplicateFinderViewModel {
    var duplicateGroups: [DuplicateGroup] = []
    var isScanning: Bool = false
    var errorMessage: String?
    
    private let finderService = DuplicateFinderService()
    private let fileAccessService: FileAccessService
    
    init(fileAccessService: FileAccessService) {
        self.fileAccessService = fileAccessService
    }
    
    func startScan() async {
        isScanning = true
        errorMessage = nil
        
        do {
            let appContainer = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
            let scanLocations = [appContainer] + fileAccessService.savedLocations.compactMap { try? fileAccessService.resolveBookmark(for: $0) }
            
            var allGroups: [DuplicateGroup] = []
            for location in scanLocations {
                let groups = await finderService.findDuplicates(in: location)
                allGroups.append(contentsOf: groups)
            }
            self.duplicateGroups = allGroups
        }
        
        isScanning = false
    }
    
    func delete(fileURL: URL, in group: DuplicateGroup) {
        do {
            try FileManager.default.removeItem(at: fileURL)
            // Cập nhật lại UI sau khi xoá
            if let index = duplicateGroups.firstIndex(where: { $0.id == group.id }) {
                duplicateGroups[index].files.removeAll { $0 == fileURL }
                if duplicateGroups[index].files.count <= 1 {
                    duplicateGroups.remove(at: index)
                }
            }
        } catch {
            self.errorMessage = "Không thể xoá tệp: \(error.localizedDescription)"
        }
    }
}
