import SwiftUI

struct FileEditorView: View {
    @State private var viewModel: FileEditorViewModel
    
    init(fileURL: URL, parentURL: URL, fileAccessService: FileAccessService) {
        _viewModel = State(initialValue: FileEditorViewModel(fileURL: fileURL, parentURL: parentURL, fileAccessService: fileAccessService))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Đang mở tệp...")
            } else {
                TextEditor(text: $viewModel.text)
                    .font(.system(.body, design: .monospaced)) // Font chữ code dễ nhìn
                    .padding(.horizontal, 4)
            }
            
            // Toast thông báo lưu thành công
            if viewModel.showSuccessToast {
                VStack {
                    Spacer()
                    Text("Đã lưu thành công!")
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(viewModel.fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.saveFile()
                }) {
                    Text("Save")
                        .fontWeight(viewModel.hasChanges ? .bold : .regular)
                }
                .disabled(!viewModel.hasChanges) // Nút Save chỉ kích hoạt khi có thay đổi
            }
        }
        .onAppear {
            viewModel.loadFile()
        }
        .alert(
            "Lỗi",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
