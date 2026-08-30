import SwiftUI

struct CleanerView: View {
    @State private var viewModel: CleanerViewModel
    @Environment(FileAccessService.self) private var fileAccessService
    
    init(fileAccessService: FileAccessService) {
        _viewModel = State(initialValue: CleanerViewModel(fileAccessService: fileAccessService))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header dung lượng rác
                VStack(spacing: 8) {
                    Text("Dung lượng rác có thể dọn")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatBytes(viewModel.totalJunkSize))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding()
                
                if viewModel.isScanning {
                    ProgressView("Đang quét hệ thống...")
                        .padding()
                } else if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "Sạch sẽ!",
                        systemImage: "checkmark.seal.fill",
                        description: Text("Không tìm thấy tệp rác hoặc cache tạm thời nào cần xóa.")
                    )
                } else {
                    List(viewModel.items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.body)
                                    .lineLimit(1)
                                Text(item.category.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                            Text(formatBytes(item.size))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Nút hành động
                VStack(spacing: 12) {
                    Button(action: {
                        Task { await viewModel.startScanning() }
                    }) {
                        Text("Quét ngay")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.isScanning || viewModel.isCleaning)
                    
                    if !viewModel.items.isEmpty {
                        Button(action: {
                            Task { await viewModel.performClean() }
                        }) {
                            Text("Dọn dẹp ngay")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.isCleaning)
                    }
                }
                .padding()
            }
            .navigationTitle("Cleaner")
            .alert("Thông báo", isPresented: Binding(
                get: { viewModel.freedSpaceMessage != nil },
                set: { if !$0 { viewModel.freedSpaceMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.freedSpaceMessage ?? "")
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
