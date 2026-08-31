import Foundation
import SwiftUI
import Observation

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
        items.reduce(0) { total, item in
            total + item.size
        }
    }

    init(fileAccessService: FileAccessService) {
        self.fileAccessService = fileAccessService
    }

    func startScanning() async {
        isScanning = true
        errorMessage = nil
        freedSpaceMessage = nil
        items.removeAll()

        do {
            var allItems: [CleanerItem] = []

            let appContainer = fileManagerContainerURL()

            let savedLocations = fileAccessService.savedLocations.compactMap {
                try? fileAccessService.resolveBookmark(for: $0)
            }

            let scanLocations = [appContainer] + savedLocations

            for location in scanLocations {
                let foundItems = try await cleanerService.scanForJunk(
                    in: location
                )

                allItems.append(contentsOf: foundItems)
            }

            items = allItems
        } catch {
            errorMessage = error.localizedDescription
        }

        isScanning = false
    }

    func performClean() async {
        isCleaning = true
        errorMessage = nil
        freedSpaceMessage = nil

        do {
            let itemsToClean = items
            let freedBytes = itemsToClean.reduce(Int64(0)) {
                $0 + $1.size
            }

            try await cleanerService.clean(items: itemsToClean)

            items.removeAll()
            freedSpaceMessage = "Đã giải phóng thành công \(formatBytes(freedBytes))!"
        } catch {
            errorMessage = "Lỗi khi dọn dẹp: \(error.localizedDescription)"
        }

        isCleaning = false
    }

    private func fileManagerContainerURL() -> URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        ?? URL(fileURLWithPath: NSTemporaryDirectory())
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}