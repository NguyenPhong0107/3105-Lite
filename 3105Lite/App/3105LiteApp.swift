import SwiftUI

@main
struct _105LiteApp: App {
    // Khởi tạo FileAccessService làm Singleton ở mức App
    @State private var fileAccessService = FileAccessService()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(fileAccessService)
        }
    }
}
