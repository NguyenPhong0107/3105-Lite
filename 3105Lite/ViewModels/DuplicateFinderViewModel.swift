import Foundation
import SwiftUI
import Observation

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
        duplicateGroups.removeAll()

        let appContainer = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        ?? URL(fileURLWithPath: NSTemporaryDirectory())

        let savedLocations = fileAccessService.savedLocations.compactMap {
            try? fileAccessService.resolveBookmark(for: $0)
        }

        let scanLocations = [appContainer] + savedLocations

        var allGroups: [DuplicateGroup] = []

        for location in scanLocations {
            let groups = await finderService.findDuplicates(
                in: location
            )

            allGroups.append(contentsOf: groups)
        }

        duplicateGroups = allGroups
        isScanning = false
    }

    func delete(fileURL: URL, in group: DuplicateGroup) {
        do {
            try FileManager.default.removeItem(at: fileURL)

            guard let groupIndex = duplicateGroups.firstIndex(
                where: { $0.id == group.id }
            ) else {
                return
            }

            duplicateGroups[groupIndex].files.removeAll {
                $0 == fileURL
            }

            if duplicateGroups[groupIndex].files.count <= 1 {
                duplicateGroups.remove(at: groupIndex)
            }
        } catch {
            errorMessage = "Không thể xoá tệp: \(error.localizedDescription)"
        }
    }
}