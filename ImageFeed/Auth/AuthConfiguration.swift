import Foundation

let AccessKey = "dPl3i6n7ELzPVvq55BF1Tayc_oxYZewxTy54JrtEtoY"
let SecretKey = "_tU17nB6r8dbPVm9J4Y7_PmFqquu7-SWvnpUaW7vLBE"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"

let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessKey,
                                 defaultBaseURL: DefaultBaseURL,
                                 authURLString: UnsplashAuthorizeURLString)
    }
}
