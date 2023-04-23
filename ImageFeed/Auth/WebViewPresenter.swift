import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
//  Логика создания и отправки запроса.
    func viewDidLoad()
//  Чтобы презентер получал от вьюконтроллера уведомления об изменении значения прогресса.
    func didUpdateProgressValue(_ newValue: Double)
//  Aнализирует URL и достаёт из него код.
    func code(from url: URL) -> String?

}

final class WebViewPresenter: WebViewPresenterProtocol {

    var view: WebViewViewControllerProtocol?
    
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
        
    func viewDidLoad() {
        let request = authHelper.authRequest()
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHiden(shouldHideProgress)
    }
    
//  Функцию вычисления того, должен ли быть скрыт progressView.
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
//         if let urlComponents = URLComponents(string: url.absoluteString),
//            urlComponents.path == "/oauth/authorize/native",
//            let items = urlComponents.queryItems,
//            let codeItem = items.first(where: { $0.name == "code" })
//          {
//            return codeItem.value
//          } else {
//                return nil
//          }
     }
}
