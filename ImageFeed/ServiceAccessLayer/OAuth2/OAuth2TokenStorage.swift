import Foundation

final class OAuth2TokenStorage {
    let Token = "token"
    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Token)
        }
        get {
            UserDefaults.standard.string(forKey: Token)
        }
    }
}
