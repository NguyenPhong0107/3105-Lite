import Foundation
import SwiftUI

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
        
        do {
            let appContainer = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
            let scanLocations = [appContainer] + fileAccessService.savedLocations.compactMap { try? fileAccessService.resolveBookmark(for: $0) }
            
            for location in scanLocations {
                let (st, lg) = await analyzerService.analyze(rootURL: location, sizeThreshold: sizeThreshold)
                
                combinedStats.imagesSize += st.imagesSize
                combinedStats.videosSize += st.videosSize
                combinedStats.audioSize += st.audioSize
                combinedStats.documentsSize += st.documentsSize
                combinedStats.archivesSize += st.archivesSize
                combinedStats.otherSize += st.otherSize
                
                combinedLargeFiles.append(contentsOf: lg)
            }
            
            self.stats = combinedStats
            self.largeFiles = combinedLargeFiles.sorted { $0.size > $1.size }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isAnalyzing = false
    }
}
