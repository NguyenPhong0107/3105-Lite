import SwiftUI

struct MainTabView: View {
    @Environment(FileAccessService.self) private var fileAccessService
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled: Bool = false
    
    @State private var isUnlocked: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    private var documentDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var body: some View {
        Group {
            if isAppLockEnabled && !isUnlocked {
                LockView(isUnlocked: $isUnlocked)
            } else {
                TabView {
                    NavigationStack {
                        FileBrowserView(
                            folderURL: documentDirectory,
                            title: "Tệp tin",
                            fileAccessService: fileAccessService
                        )
                    }
                    .tabItem {
                        Label("Tệp tin", systemImage: "folder.fill")
                    }
                    
                    CleanerView(fileAccessService: fileAccessService)
                        .tabItem {
                            Label("Dọn dẹp", systemImage: "trash.fill")
                        }
                    
                    ToolsView()
                        .tabItem {
                            Label("Công cụ", systemImage: "wrench.and.screwdriver.fill")
                        }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: scenePhase) { _, newPhase in
            // Tự động khóa lại ứng dụng khi chuyển sang nền (Background)
            if newPhase == .background && isAppLockEnabled {
                isUnlocked = false
            }
        }
    }
}
