import UIKit

final class IconManagerService {
    static let shared = IconManagerService()
    private init() {}
    
    func setAppIcon(name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error = error {
                print("Lỗi đổi icon: \(error.localizedDescription)")
            }
        }
    }
}
