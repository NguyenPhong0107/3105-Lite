import SwiftUI

struct MainTabView: View {
    @Environment(FileAccessService.self) private var fileAccessService
    
    // Lấy thư mục Document gốc của App để làm màn hình mặc định cho File Browser
    private var documentDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var body: some View {
        TabView {
            // Tab 1: Trình quản lý tệp tin
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
            
            // Tab 2: Dọn dẹp rác
            CleanerView(fileAccessService: fileAccessService)
                .tabItem {
                    Label("Dọn dẹp", systemImage: "trash.fill")
                }
            
            // Tab 3: Công cụ nâng cao
            ToolsView()
                .tabItem {
                    Label("Công cụ", systemImage: "wrench.and.screwdriver.fill")
                }
        }
    }
}
