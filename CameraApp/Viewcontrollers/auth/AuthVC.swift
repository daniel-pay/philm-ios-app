//
//  AuthVC.swift
//  CameraApp
//
//  Created by developer on 12/1/20.
//

import UIKit
import FittedSheets
import GoogleSignIn
import Firebase
import CRNotifications
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit

class AuthVC: BaseViewController {

    var sheetController = SheetViewController()
    var socialVC = SocialLoginVC()
    var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpBottomSlider()
        
    }

    
    func setUpBottomSlider(){
        
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        socialVC = storyboard.instantiateViewController(withIdentifier: "SocialLoginVC") as! SocialLoginVC

        sheetController = SheetViewController(controller: socialVC, sizes: [.fixed(420)])
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false
        sheetController.dismissOnBackgroundTap = true
        sheetController.topCornersRadius = 40
//        sheetController.overlayColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        sheetController.handleSize = .zero
//        sheetController.containerView.layer.shadowColor = UIColor.gray.cgColor
//        sheetController.containerView.layer.shadowOffset = CGSize(width: 0, height: -1)
//        sheetController.containerView.layer.shadowRadius = 3
//        sheetController.containerView.layer.shadowOpacity = 0.4
        sheetController.dismissOnPan = true
        sheetController.dismissOnBackgroundTap = true

//        socialVC.delegate = self
    }

    @IBAction func didTapLogin(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "SigninVC") as! SigninVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func didTapSignup(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "TutorialVC") as! TutorialVC
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)

    }
    
    @IBAction func didTapSocialLogin(_ sender: Any) {
        socialVC.delegate = self
        self.present(sheetController, animated: false, completion: nil)
    }
    
    func signin(with credential: AuthCredential, isAppleSign: Bool){
        
        Auth.auth().signIn(with: credential) { result, error in
            
            guard error == nil else {  self.dismissHUD(); self.displayError(error); return}
            
            FirestoreService.shared.isExistUser(uid: result!.user.uid) { (user) in
                self.dismissHUD()
                Pref.shared.setPref(.uid, value: user.userId!)
                Pref.shared.setPref(.username, value: user.name!)
                DispatchQueue.main.async {
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
                    self.view.window?.rootViewController = vc
                    CRNotifications.showNotification(textColor: .white, backgroundColor: UIColor(hex: 0x3A3A3E)!, image: UIImage(named: "success"), title: "Success!", message: "Login successfully", dismissDelay: 2.0)
                }
            } error: { (err) in
                self.dismissHUD()
                if err == "The user does not exist." {
                    
                    if isAppleSign {
                        var data = [String:Any]()
                        data[Constants.USER_NAME] = ""
                        data[Constants.USER_EMAIL] = Auth.auth().currentUser?.email
                        data[Constants.USER_ID] = Auth.auth().currentUser?.uid
                        data[Constants.ADDRESS1] = ""
                        data[Constants.ADDRESS2] = ""
                        data[Constants.CITY] = ""
                        data[Constants.STATE] = ""
                        data[Constants.ZIPCODE] = ""
                        data[Constants.SSO] = true
                        data[Constants.PASSWORD] = ""
                        
                        
                        FirestoreService.shared.createUser(profile: data) { [self] (user) in
                            Pref.shared.setPref(.uid, value: user.userId!)
                            Pref.shared.setPref(.username, value: user.name!)
                            CRNotifications.showNotification(textColor: .white, backgroundColor: UIColor(hex: 0x3A3A3E)!, image: UIImage(named: "success"), title: "Success!", message: "You successfully created an account.", dismissDelay: 2.0)
                            
                            self.dismissHUD()
                            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
                            self.view.window?.rootViewController = vc
                            
                        } error: { (error) in
                            
                            self.dismissHUD()
                            self.showAlert("Error", msg: error) { _ in }
                        }
                    }else{
                        let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
                        vc.fromSocial = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }                    


                }
            }


            
        }
    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
          let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
              fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
              )
            }
            return random
          }

          randoms.forEach { random in
            if remainingLength == 0 {
              return
            }

            if random < charset.count {
              result.append(charset[Int(random)])
              remainingLength -= 1
            }
          }
        }

        return result
      }

      private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
          String(format: "%02x", $0)
        }.joined()

        return hashString
      }
}

extension AuthVC: SocialLoginVCDelegate {
    func googleSign() {
        self.sheetController.closeSheet()
        self.showHUD()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()!.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func facebookSign() {
        self.sheetController.closeSheet()
        self.showHUD()
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions: ["email","public_profile"], from: self) { result, error in
          guard error == nil else { return self.displayError(error) }
            guard let accessToken = AccessToken.current else { self.dismissHUD(); return }
          let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
          self.signin(with: credential,isAppleSign: false)
        }
        
    }
    
    func appleSign() {
        self.sheetController.closeSheet()
        self.showHUD()
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
}

// MARK: - GIDSignInDelegate for Google Sign In
extension AuthVC: GIDSignInDelegate {
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    guard error == nil else { return self.displayError(error) }

    guard let authentication = user.authentication else {self.dismissHUD(); return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)

    self.signin(with: credential, isAppleSign: false)
  }
}



extension AuthVC: ASAuthorizationControllerDelegate,
  ASAuthorizationControllerPresentationContextProviding {
  // MARK: ASAuthorizationControllerDelegate
  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
    else {
        self.dismissHUD()
        showAlert("error", msg: "Unable to retrieve AppleIDCredential") { (_) in }
        print("Unable to retrieve AppleIDCredential")
      return
    }

    guard let nonce = currentNonce else {
        self.dismissHUD()
        showAlert("error", msg: "Invalid state: A login callback was received, but no login request was sent.") { (_) in }
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
    }
    guard let appleIDToken = appleIDCredential.identityToken else {
        self.dismissHUD()
        showAlert("error", msg: "Unable to fetch identity token") { (_) in }
      print("Unable to fetch identity token")
      return
    }
    guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        self.dismissHUD()
        showAlert("error", msg: "Unable to serialize token string from data: \(appleIDToken.debugDescription)") { (_) in }
      print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
      return
    }

    let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                              idToken: idTokenString,
                                              rawNonce: nonce)
    // Once we have created the above `credential`, we can link accounts to it.
    signin(with: credential,isAppleSign: true)
  }

  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithError error: Error) {
    // Ensure that you have:
    //  - enabled `Sign in with Apple` on the Firebase console
    //  - added the `Sign in with Apple` capability for this project
    self.dismissHUD()
    print("Sign in with Apple errored: \(error)")
  }

  // MARK: ASAuthorizationControllerPresentationContextProviding
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
  }
}

extension AuthVC: TutorialVCDelegate {
    
    func next(){
        
        let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
