import Foundation

struct FileOperationService {
    private let fileManager = FileManager.default

    /// Tạo thư mục mới
    func createFolder(at parentURL: URL, name: String) throws {
        let newFolderURL = parentURL.appendingPathComponent(name, isDirectory: true)

        if fileManager.fileExists(atPath: newFolderURL.path) {
            throw AppError.generic("Thư mục '\(name)' đã tồn tại.")
        }

        var coordinationError: NSError?
        var operationError: Error?

        NSFileCoordinator().coordinate(
            writingItemAt: newFolderURL,
            options: .forReplacing,
            error: &coordinationError
        ) { url in
            do {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                operationError = error
            }
        }

        if let error = coordinationError ?? operationError {
            throw AppError.writeFailed(
                newFolderURL,
                error.localizedDescription
            )
        }
    }

    /// Xóa tệp hoặc thư mục
    func deleteItem(at url: URL) throws {
        var coordinationError: NSError?
        var operationError: Error?

        NSFileCoordinator().coordinate(
            writingItemAt: url,
            options: .forDeleting,
            error: &coordinationError
        ) { coordinatedURL in
            do {
                try fileManager.removeItem(at: coordinatedURL)
            } catch {
                operationError = error
            }
        }

        if let error = coordinationError ?? operationError {
            throw AppError.writeFailed(
                url,
                error.localizedDescription
            )
        }
    }

    /// Đổi tên tệp hoặc thư mục
    func renameItem(at url: URL, newName: String) throws {
        let newURL = url
            .deletingLastPathComponent()
            .appendingPathComponent(newName)

        if fileManager.fileExists(atPath: newURL.path) {
            throw AppError.generic("Tên '\(newName)' đã được sử dụng.")
        }

        var coordinationError: NSError?
        var operationError: Error?

        NSFileCoordinator().coordinate(
            writingItemAt: url,
            options: .forMoving,
            writingItemAt: newURL,
            options: .forReplacing,
            error: &coordinationError
        ) { oldCoordinatedURL, newCoordinatedURL in
            do {
                try fileManager.moveItem(
                    at: oldCoordinatedURL,
                    to: newCoordinatedURL
                )
            } catch {
                operationError = error
            }
        }

        if let error = coordinationError ?? operationError {
            throw AppError.writeFailed(
                url,
                error.localizedDescription
            )
        }
    }

    /// Đọc nội dung file text UTF-8
    func readString(from url: URL) throws -> String {
        var content = ""
        var coordinationError: NSError?
        var operationError: Error?

        NSFileCoordinator().coordinate(
            readingItemAt: url,
            options: .withoutChanges,
            error: &coordinationError
        ) { coordinatedURL in
            do {
                content = try String(
                    contentsOf: coordinatedURL,
                    encoding: .utf8
                )
            } catch {
                operationError = error
            }
        }

        if let error = coordinationError ?? operationError {
            throw AppError.readFailed(
                url,
                error.localizedDescription
            )
        }

        return content
    }

    /// Ghi đè nội dung file text
    func writeString(_ content: String, to url: URL) throws {
        var coordinationError: NSError?
        var operationError: Error?

        NSFileCoordinator().coordinate(
            writingItemAt: url,
            options: .forReplacing,
            error: &coordinationError
        ) { coordinatedURL in
            do {
                try content.write(
                    to: coordinatedURL,
                    atomically: true,
                    encoding: .utf8
                )
            } catch {
                operationError = error
            }
        }

        if let error = coordinationError ?? operationError {
            throw AppError.writeFailed(
                url,
                error.localizedDescription
            )
        }
    }
}