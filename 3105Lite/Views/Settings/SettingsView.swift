import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("autoCleanCache") private var autoCleanCache: Bool = false
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled: Bool = false
    @AppStorage("selectedAppIcon") private var selectedAppIcon: String = "Default"
    
    @State private var cacheSize: String = "Đang tính..."
    
    var body: some View {
        NavigationStack {
            List {
                // Tùy chỉnh Giao diện & Icon
                Section(header: Text("Giao diện & Biểu tượng")) {
                    Toggle("Chế độ tối (Dark Mode)", isOn: $isDarkMode)
                    
                    Picker("Biểu tượng ứng dụng", selection: $selectedAppIcon) {
                        Text("Mặc định").tag("Default")
                        Text("Chế độ tối (Dark)").tag("AppIconDark")
                        Text("Tối giản (Minimal)").tag("AppIconMinimal")
                    }
                    .onChange(of: selectedAppIcon) { _, newValue in
                        let iconName = newValue == "Default" ? nil : newValue
                        IconManagerService.shared.setAppIcon(name: iconName)
                    }
                }
                
                // Bảo mật
                Section(header: Text("Bảo mật")) {
                    Toggle("Bật khóa ứng dụng (Face ID / Passcode)", isOn: $isAppLockEnabled)
                        .onChange(of: isAppLockEnabled) { _, newValue in
                            if newValue {
                                SecurityService.shared.authenticateUser(reason: "Xác nhận để bật khóa ứng dụng") { success, _ in
                                    if !success {
                                        isAppLockEnabled = false
                                    }
                                }
                            }
                        }
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
