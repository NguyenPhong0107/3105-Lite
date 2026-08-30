import SwiftUI

struct DuplicateFinderView: View {
    @State private var viewModel: DuplicateFinderViewModel
    @Environment(FileAccessService.self) private var fileAccessService
    
    init(fileAccessService: FileAccessService) {
        _viewModel = State(initialValue: DuplicateFinderViewModel(fileAccessService: fileAccessService))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isScanning {
                    ProgressView("Đang quét tìm tệp trùng lặp...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.duplicateGroups.isEmpty {
                    ContentUnavailableView(
                        "Không có tệp trùng lặp",
                        systemImage: "doc.on.doc",
                        description: Text("Bộ nhớ của bạn rất gọn gàng.")
                    )
                } else {
                    ForEach(viewModel.duplicateGroups) { group in
                        Section(header: Text("Dung lượng: \(formatBytes(group.size))")) {
                            ForEach(group.files, id: \.self) { fileURL in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(fileURL.lastPathComponent)
                                            .font(.body)
                                            .lineLimit(1)
                                        Text(fileURL.path)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Button(role: .destructive) {
                                        viewModel.delete(fileURL: fileURL, in: group)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tìm tệp trùng lặp")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await viewModel.startScan() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isScanning)
                }
            }
            .onAppear {
                if viewModel.duplicateGroups.isEmpty && !viewModel.isScanning {
                    Task { await viewModel.startScan() }
                }
            }
            .alert("Lỗi", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
