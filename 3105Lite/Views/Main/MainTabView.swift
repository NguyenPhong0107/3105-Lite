import SwiftUI

struct MainTabView: View {
    @Environment(FileAccessService.self) private var fileAccessService
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    
    private var documentDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var body: some View {
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
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
