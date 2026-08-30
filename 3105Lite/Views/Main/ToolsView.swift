import SwiftUI

struct ToolsView: View {
    @Environment(FileAccessService.self) private var fileAccessService
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Quản lý lưu trữ")) {
                    NavigationLink {
                        StorageAnalyzerView(fileAccessService: fileAccessService)
                    } label: {
                        Label("Phân tích bộ nhớ", systemImage: "chart.pie.fill")
                            .foregroundColor(.blue)
                    }
                    
                    NavigationLink {
                        DuplicateFinderView(fileAccessService: fileAccessService)
                    } label: {
                        Label("Tìm tệp trùng lặp", systemImage: "doc.on.doc.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                Section(header: Text("Hệ thống")) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Cài đặt", systemImage: "gearshape.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Công cụ")
        }
    }
}
