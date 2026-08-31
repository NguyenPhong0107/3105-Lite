import Foundation
import SwiftUI
import Observation

@Observable
final class StorageAnalyzerViewModel {
    var stats = StorageCategoryStats()
    var largeFiles: [LargeFileItem] = []
    var isAnalyzing: Bool = false
    var errorMessage: String?

    var sizeThreshold: Int64 = 50 * 1024 * 1024

    private let analyzerService = StorageAnalyzerService()
    private let fileAccessService: FileAccessService

    init(fileAccessService: FileAccessService) {
        self.fileAccessService = fileAccessService
    }

    func startAnalysis() async {
        isAnalyzing = true
        errorMessage = nil

        var combinedStats = StorageCategoryStats()
        var combinedLargeFiles: [LargeFileItem] = []

        let appContainer = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        ?? URL(fileURLWithPath: NSTemporaryDirectory())

        let savedLocations = fileAccessService.savedLocations.compactMap {
            try? fileAccessService.resolveBookmark(for: $0)
        }

        let scanLocations = [appContainer] + savedLocations

        for location in scanLocations {
            let result = await analyzerService.analyze(
                rootURL: location,
                sizeThreshold: sizeThreshold
            )

            let locationStats = result.0
            let locationLargeFiles = result.1

            combinedStats.imagesSize += locationStats.imagesSize
            combinedStats.videosSize += locationStats.videosSize
            combinedStats.audioSize += locationStats.audioSize
            combinedStats.documentsSize += locationStats.documentsSize
            combinedStats.archivesSize += locationStats.archivesSize
            combinedStats.otherSize += locationStats.otherSize

            combinedLargeFiles.append(contentsOf: locationLargeFiles)
        }

        stats = combinedStats
        largeFiles = combinedLargeFiles.sorted {
            $0.size > $1.size
        }

        isAnalyzing = false
    }
}