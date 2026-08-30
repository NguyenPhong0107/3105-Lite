import SwiftUI

struct StorageAnalyzerView: View {
    @State private var viewModel: StorageAnalyzerViewModel
    @Environment(FileAccessService.self) private var fileAccessService
    
    init(fileAccessService: FileAccessService) {
        _viewModel = State(initialValue: StorageAnalyzerViewModel(fileAccessService: fileAccessService))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isAnalyzing {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Đang phân tích bộ nhớ...")
                            Spacer()
                        }
                    }
                } else {
                    Section(header: Text("Tổng quan phân loại")) {
                        categoryRow(title: "Hình ảnh", size: viewModel.stats.imagesSize, color: .purple)
                        categoryRow(title: "Video", size: viewModel.stats.videosSize, color: .red)
                        categoryRow(title: "Âm thanh", size: viewModel.stats.audioSize, color: .orange)
                        categoryRow(title: "Tài liệu", size: viewModel.stats.documentsSize, color: .blue)
                        categoryRow(title: "Tệp nén (Archive)", size: viewModel.stats.archivesSize, color: .green)
                        categoryRow(title: "Khác", size: viewModel.stats.otherSize, color: .gray)
                    }
                    
                    Section(header: Text("Tệp lớn (>50 MB)")) {
                        if viewModel.largeFiles.isEmpty {
                            Text("Không tìm thấy tệp lớn nào.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(viewModel.largeFiles) { file in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(file.name)
                                            .font(.body)
                                            .lineLimit(1)
                                        Text(file.url.path)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Text(formatBytes(file.size))
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Storage Analyzer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await viewModel.startAnalysis() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isAnalyzing)
                }
            }
            .onAppear {
                if viewModel.largeFiles.isEmpty && !viewModel.isAnalyzing {
                    Task { await viewModel.startAnalysis() }
                }
            }
        }
    }
    
    @ViewBuilder
    private func categoryRow(title: String, size: Int64, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(title)
            Spacer()
            Text(formatBytes(size))
                .foregroundColor(.secondary)
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
