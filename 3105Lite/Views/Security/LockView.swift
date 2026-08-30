import SwiftUI

struct LockView: View {
    @Binding var isUnlocked: Bool
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("3105 Lite đã bị khóa")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Xác thực để truy cập vào tệp tin của bạn")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: authenticate) {
                Label("Mở khóa", systemImage: "faceid")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .onAppear {
            authenticate()
        }
    }
    
    private func authenticate() {
        SecurityService.shared.authenticateUser(reason: "Mở khóa ứng dụng 3105 Lite") { success, error in
            if success {
                isUnlocked = true
                errorMessage = nil
            } else {
                errorMessage = "Xác thực thất bại. Vui lòng thử lại."
            }
        }
    }
}
