import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import CryptoKit
import AuthenticationServices
import FacebookLogin

class SignUpViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, UITextViewDelegate {
    
    // MARK: - Variables
    var viewModel = ProfileViewModel()
    var currentNonce: String?
    let message = "By signing up, you confirm that you agree to our Terms of Use and have read and understood our Privacy Policy."
    let findword1 = "Terms of Use"
    let findword2 = "Privacy Policy"
    
    var social = ""
    var email = ""
    var isSwitchAccount = false

    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()

    // MARK: - Outlets
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var phoneLoginButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.configureSubViews()
        ConstantManager.isSwitchAccountFlow = self.isSwitchAccount
    }
    
    // MARK: - Functions
    private func configureSubViews() {
        let attributeMutableStringLink = NSMutableAttributedString(string: message)
        
        // Configure links
        let links = [
            (findword1, "https://www.termsfeed.com/privacy-policy/4dec1a564a01ea0d15ed86c97c4e8253", "Terms of Service"),
            (findword2, "https://www.termsfeed.com/privacy-policy/4dec1a564a01ea0d15ed86c97c4e8253", "Privacy Policy")
        ]
        
        for (word, link, title) in links {
            let range = message.createRangeinaLink(of: word)
            attributeMutableStringLink.addAttribute(.link, value: link, range: range)
            attributeMutableStringLink.addAttributes([
                .font: AppFont.font(type: .Regular, size: 14.0)
            ], range: range)
        }
        
        // Configure text view link attributes
        let applyColorheadlineOnText: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.appColor(.theme)
        ]
        
        textView.linkTextAttributes = applyColorheadlineOnText
        textView.attributedText = attributeMutableStringLink
        textView.textAlignment = .center
        textView.sizeToFit()
        textView.textColor = UIColor.appColor(.darkGrey)
        textView.font = AppFont.font(type: .Regular, size: 14.0)
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let attributedText = textView.attributedText else { return true }
        
        let text = attributedText.string as NSString
        let termsOfServiceRange = text.range(of: "Terms of Use")
        let privacyPolicyRange = text.range(of: "Privacy Policy")
        
        let termsUrl = "https://www.termsfeed.com/privacy-policy/4dec1a564a01ea0d15ed86c97c4e8253"
        let privacyUrl = "https://www.termsfeed.com/privacy-policy/4dec1a564a01ea0d15ed86c97c4e8253"
        
        if NSLocationInRange(characterRange.location, termsOfServiceRange) {
            openWebViewController(with: termsUrl, title: "Terms of Use")
            return false
        } else if NSLocationInRange(characterRange.location, privacyPolicyRange) {
            openWebViewController(with: privacyUrl, title: "Privacy Policy")
            return false
        }
        
        return true
    }

    private func openWebViewController(with url: String, title: String) {
        let webViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        webViewController.myUrl = url
        webViewController.linkTitle = title
        webViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func googleFirebase() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                Utility.showMessage(message: error.localizedDescription, on: self.view)
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            
            self.email = user.profile?.email ?? ""
            let googleCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            loader.isHidden = false
            Auth.auth().signIn(with: googleCredential) { authResult, error in
                self.loader.isHidden = true
                if let error = error {
                    Utility.showMessage(message: error.localizedDescription, on: self.view)
                    return
                }
                authResult?.user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
                    guard let self = self else { return }
                    self.social = "google"
                    UserDefaultsManager.shared.idAuthToken = idToken ?? ""
                    self.getUserDetail()
                }
            }
        }
    }
    
    func getUserDetail() {
        let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
        viewModel.showUserDetail(parameters: showUserDetail)
        observeEvent()
    }

    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .error(let error):
                print("Error: \(error)")
            case .newShowUserDetail(let showUserDetail):
                if showUserDetail.code == 200 {
                    UserDefaultsManager.shared.user_id = showUserDetail.msg?.user?.id?.toString() ?? ""
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        // Updated `gotoHomeController` to `presentLogin()`
                        appDelegate.presentLogin()
                    }
                } else {
                    let usernameVC = UserNameController(nibName: "UserNameController", bundle: nil)
                    usernameVC.social = self.social
                    self.navigationController?.pushViewController(usernameVC, animated: true)
                }
            default:
                break
            }
        }
    }

    // MARK: - Actions
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        let phoneEmailVC = PhoneEmailSignInViewController(nibName: "PhoneEmailSignInViewController", bundle: nil)
        self.navigationController?.pushViewController(phoneEmailVC, animated: true)
    }
    
    @IBAction func googleButtonPressed(_ sender: UIButton) {
        self.googleFirebase()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let phoneEmailVC = PhoneEmailSignInViewController(nibName: "PhoneEmailSignInViewController", bundle: nil)
        phoneEmailVC.isLogin = false
        self.navigationController?.pushViewController(phoneEmailVC, animated: true)
    }
    
    // MARK: - ASAuthorizationController Presentation Context
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
