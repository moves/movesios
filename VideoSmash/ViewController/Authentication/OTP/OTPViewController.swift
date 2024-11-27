//
//  OTPViewController.swift
//  Created by iMac on 10/06/2024.
//

import UIKit
import DPOTPView
import FirebaseAuth

class OTPViewController: UIViewController {
    
    // MARK: - Variables
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    
    var viewModel = ProfileViewModel()
    private var viewModel1 = EditProfileViewModel()
    var verifyAccountDetails: ProfileResponse?
    var isLogin = false
    var counter = 60
    var timer = Timer()
    var number = ""
    var code: Int?
    var email = ""
    var updatedPhone = ""
    var isPhoneUpdate = false
    
    // MARK: - Outlets
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblCodeSent: UILabel!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var otpView: DPOTPView!
    @IBOutlet weak var lblError: UILabel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.lblCodeSent.text = "Your code was sent \(number)"
        otpView.dpOTPViewDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.timerSetup()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helper Methods
    private func timerSetup() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc private func updateCounter() {
        if counter != 0 {
            let formattedCounter = String(format: "%02d", counter)
            lblTimer.text = "Resend Code 00:\(formattedCounter)"
            counter -= 1
        } else {
            counter = 60
            timer.invalidate()
            lblTimer.isHidden = true
            btnResend.isHidden = false
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Button Actions
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        self.timerSetup()
        Utility.showMessage(message: "OTP sent to your number successfully", on: self.view)
        FirebaseAuthService.shared.verifyPhoneNumber(number) { verificationID, error in
            if let error = error {
                print("Error verifying phone number: \(error.localizedDescription)")
                return
            }
            UserDefaultsManager.shared.verificationID = verificationID ?? ""
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if isPhoneUpdate {
            let phoneCredential = FirebaseAuthService.shared.createPhoneAuthCredential(verificationID: UserDefaultsManager.shared.verificationID, verificationCode: otpView.text!)
            FirebaseAuthService.shared.updatePhoneNumber(credential: phoneCredential) { error in
                if let error = error {
                    self.lblError.isHidden = false
                    self.lblError.text = "Phone number is already in use"
                    print("Error updating phone number: \(error.localizedDescription)")
                } else {
                    print("Phone number updated successfully.")
                    let editProfile = EditProfileRequest(firstName: nil, lastName: nil, gender: nil, website: nil, bio: nil, phone: self.number, email: nil, username: nil, profileImage: nil)
                    self.viewModel1.editProfile(parameters: editProfile)
                }
            }
        } else {
            let phoneCredential = FirebaseAuthService.shared.createPhoneAuthCredential(verificationID: UserDefaultsManager.shared.verificationID, verificationCode: otpView.text!)
            
            loader.isHidden = false
            Auth.auth().signIn(with: phoneCredential) { [weak self] (authResult, error) in
                guard let self = self else { return }
                
                if let error = error as NSError? {
                    self.lblError.isHidden = false
                    self.lblError.text = {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .invalidVerificationCode:
                            return "Invalid verification code."
                        default:
                            return error.localizedDescription
                        }
                    }()
                    self.loader.isHidden = true
                    return
                }
                
                guard let authResult = authResult else { return }
                lblError.isHidden = true
                let uid = authResult.user.uid
                UserDefaultsManager.shared.authToken = uid
                authResult.user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
                    guard let self = self else { return }
                    UserDefaultsManager.shared.idAuthToken = idToken ?? ""
                    self.getUserDetail()
                }
            }
        }
    }
    
    private func getUserDetail() {
        let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
        self.viewModel.showUserDetail(parameters: showUserDetail)
        DispatchQueue.main.async {
            self.observeEvent()
        }
    }
    
    private func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .error(let error):
                print("Error: \(error)")
            case .newShowUserDetail(showUserDetail: let showUserDetail):
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    if showUserDetail.code == 200 {
                        UserDefaultsManager.shared.user_id = showUserDetail.msg?.user?.id?.toString() ?? ""
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.gotoHomeController()
                        }
                    } else {
                        let birthday = DobViewController(nibName: "DobViewController", bundle: nil)
                        birthday.phone = self.number
                        self.navigationController?.pushViewController(birthday, animated: true)
                    }
                }
            default:
                break
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - DPOTPViewDelegate
extension OTPViewController: DPOTPViewDelegate {
    func dpOTPViewAddText(_ text: String, at position: Int) {
        btnNext.isUserInteractionEnabled = text.count == 6
        btnNext.backgroundColor = text.count == 6 ? UIColor.appColor(.theme) : UIColor.appColor(.barColor)
    }
    
    func dpOTPViewRemoveText(_ text: String, at position: Int) {
        dpOTPViewAddText(text, at: position)
    }
}

