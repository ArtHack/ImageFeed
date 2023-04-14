import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let keychainStorage = KeychainWrapper.standard
    let Token = "token"
    var token: String? {
        set {
            guard let token = newValue else {
                KeychainWrapper.standard.removeObject(forKey: Token)
                return
            }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: Token)
            guard isSuccess else {
                fatalError("Ошибка сохранения токена!")
            }
        }
        get {
            KeychainWrapper.standard.string(forKey: Token)
        }
    }
    
    func clearToken() {
        keychainStorage.removeAllKeys()
    }
}
