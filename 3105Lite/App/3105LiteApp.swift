import SwiftUI

@main
struct _3105LiteApp: App { // Tên struct giữ nguyên theo file của bạn
    // Khởi tạo Service dùng chung cho toàn bộ App
    @State private var fileAccessService = FileAccessService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(fileAccessService)
        }
    }
}
