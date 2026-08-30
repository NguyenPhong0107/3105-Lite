import SwiftUI

struct FileBrowserView: View {
    let folderURL: URL
    let title: String
    
    @State private var viewModel: BrowserViewModel
    
    init(folderURL: URL, title: String, fileAccessService: FileAccessService) {
        self.folderURL = folderURL
        self.title = title
        // Khởi tạo ViewModel với FileAccessService
        _viewModel = State(initialValue: BrowserViewModel(fileAccessService: fileAccessService))
    }
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if viewModel.files.isEmpty {
                Text("Folder is empty")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(viewModel.files) { file in
                    HStack {
                        Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                            .foregroundColor(file.isDirectory ? .blue : .gray)
                            .font(.title2)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.name)
                                .font(.body)
                                .lineLimit(1)
                            
                            if !file.isDirectory {
                                Text(formatBytes(file.size))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(title)
        .onAppear {
            viewModel.loadFiles(from: folderURL)
        }
    }
    
    // Hàm phụ trợ để format dung lượng (nên tách ra Utilities ở các phase sau)
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
