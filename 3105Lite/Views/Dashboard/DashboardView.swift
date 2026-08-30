import SwiftUI

struct DashboardView: View {
    // Inject service từ App Level xuống
    @Environment(FileAccessService.self) private var fileAccessService
    @State private var showingDocumentPicker = false
    @State private var alertMessage: String?
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Delegated Locations").textCase(.uppercase)) {
                    if fileAccessService.savedLocations.isEmpty {
                        Text("No locations added yet.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(fileAccessService.savedLocations) { location in
                            // Resolve URL an toàn khi người dùng bấm vào
                            if let url = try? fileAccessService.resolveBookmark(for: location) {
                                NavigationLink {
                                    FileBrowserView(
                                        folderURL: url,
                                        title: location.name,
                                        fileAccessService: fileAccessService
                                    )
                                } label: {
                                    HStack {
                                        Image(systemName: "externaldrive.fill")
                                            .foregroundColor(.green)
                                        Text(location.name)
                                            .font(.headline)
                                    }
                                }
                            } else {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("\(location.name) (Unavailable)")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .onDelete(perform: deleteLocation)
                    }
                }
                
                Button(action: {
                    showingDocumentPicker = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Location")
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("3105 Lite")
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPickerView { url in
                    do {
                        try fileAccessService.saveBookmark(for: url)
                    } catch {
                        alertMessage = error.localizedDescription
                    }
                }
            }
            .alert(isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func deleteLocation(at offsets: IndexSet) {
        for index in offsets {
            let location = fileAccessService.savedLocations[index]
            fileAccessService.removeLocation(location)
        }
    }
}
