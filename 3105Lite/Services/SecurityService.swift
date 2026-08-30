import Foundation
import LocalAuthentication

final class SecurityService {
    static let shared = SecurityService()
    
    private init() {}
    
    /// Kiểm tra thiết bị có hỗ trợ Face ID / Touch ID hay không
    func canEvaluatePolicy() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Yêu cầu người dùng xác thực bằng Face ID / Touch ID / Passcode
    func authenticateUser(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Sử dụng policy cho phép dùng cả Biometrics lẫn Mật khẩu thiết bị làm dự phòng
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success, authenticationError)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, error)
            }
        }
    }
}
