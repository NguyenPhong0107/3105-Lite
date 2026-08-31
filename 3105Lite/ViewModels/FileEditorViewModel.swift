import Foundation
import SwiftUI
import Observation

@Observable
final class FileEditorViewModel {
    var text: String = ""
    var originalText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var showSuccessToast: Bool = false

    var hasChanges: Bool {
        text != originalText
    }

    private let fileAccessService: FileAccessService
    private let fileOperationService = FileOperationService()

    let fileURL: URL
    let parentURL: URL

    init(
        fileURL: URL,
        parentURL: URL,
        fileAccessService: FileAccessService
    ) {
        self.fileURL = fileURL
        self.parentURL = parentURL
        self.fileAccessService = fileAccessService
    }

    func loadFile() {
        isLoading = true
        errorMessage = nil

        do {
            let content = try fileAccessService.performSecureAccess(
                url: parentURL
            ) {
                try fileOperationService.readString(from: fileURL)
            }

            text = content
            originalText = content
        } catch {
            errorMessage = "Không thể đọc file: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func saveFile() {
        guard hasChanges else {
            return
        }

        errorMessage = nil

        do {
            try fileAccessService.performSecureAccess(
                url: parentURL
            ) {
                try fileOperationService.writeString(
                    text,
                    to: fileURL
                )
            }

            originalText = text

            withAnimation {
                showSuccessToast = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.showSuccessToast = false
                }
            }
        } catch {
            errorMessage = "Lỗi khi lưu: \(error.localizedDescription)"
        }
    }
}