import UIKit
import ProgressHUD
 
class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    func show() {
        UIBlockingProgressHUD.window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    func dismiss() {
        UIBlockingProgressHUD.window?.isUserInteractionEnabled = true
        ProgressHUD.show()
    }
}
