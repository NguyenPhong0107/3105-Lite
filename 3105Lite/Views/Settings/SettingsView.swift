import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("autoCleanCache") private var autoCleanCache: Bool = false
    @State private var cacheSize: String = "Đang tính..."
    
    var body: some View {
        NavigationStack {
            List {
                // Tùy chỉnh Giao diện
                Section(header: Text("Giao diện")) {
                    Toggle("Chế độ tối (Dark Mode)", isOn: $isDarkMode)
                }
                
                // Quản lý Bộ nhớ & Cache
                Section(header: Text("Bộ nhớ & Dọn dẹp")) {
                    HStack {
                        Text("Bộ nhớ đệm (Cache)")
                        Spacer()
                        Text(cacheSize)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Xóa bộ nhớ đệm", role: .destructive) {
                        clearCache()
                    }
                    
                    Toggle("Tự động xóa Cache khi thoát", isOn: $autoCleanCache)
                }
                
                // Thông tin Ứng dụng
                Section(header: Text("Thông tin")) {
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text("1.0.0 (Lite)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Tên ứng dụng")
                        Spacer()
                        Text("3105 Lite")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Cài đặt")
            .onAppear {
                calculateCacheSize()
            }
        }
    }
    
    private func calculateCacheSize() {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        guard let path = cacheURL?.path,
              let size = try? FileManager.default.attributesOfFileSystem(forPath: path)[.systemSize] as? Int64 else {
            cacheSize = "0 MB"
            return
        }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        cacheSize = formatter.string(fromByteCount: size)
    }
    
    private func clearCache() {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        if let files = try? FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
        calculateCacheSize()
    }
}
