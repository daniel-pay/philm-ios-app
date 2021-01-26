//
//  SigninVC.swift
//  CameraApp
//
//  Created by developer on 12/1/20.
//

import UIKit
import EasyTipView
import CRNotifications
import LGButton

class SigninVC: BaseViewController {

    @IBOutlet weak var emailField: UITextField!{
        didSet{
            emailField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    @IBOutlet weak var passwordField: UITextField!{
        didSet{
            passwordField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var btnEmailError: UIButton!
    @IBOutlet weak var btnPasswordError: UIButton!
    @IBOutlet weak var signinBtn: LGButton!
    
    var preferences = EasyTipView.Preferences()
    var tipView: EasyTipView?
    
    var emailErrorMsg = ""
    var passwordErrorMsg = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initTipPreferences()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if tipView != nil {
            tipView?.dismiss()
        }
        self.view.endEditing(true)
    }
    
    func initView(){
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func initTipPreferences(){
        
        preferences.drawing.font = UIFont(name: "BrandonGrotesque-Regular", size: 14)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor(hex: 0x323236)!
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        preferences.drawing.arrowHeight = 12
        preferences.drawing.arrowWidth = 12
        preferences.positioning.maxWidth = self.view.frame.width - 100
        preferences.positioning.contentHInset = 30
        preferences.positioning.contentVInset = 20
        preferences.positioning.bubbleHInset = 16
    }
    
    func showTipView(_ sender: UIButton, message: String){
        
        if tipView != nil {
            tipView?.dismiss()
        }
        
        tipView = EasyTipView(text: message, preferences: preferences, delegate: nil)
        tipView!.show(forView: sender)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapLogin(_ sender: Any) {

        
        if tipView != nil {
            tipView?.dismiss()
        }
        self.view.endEditing(true)
        
        if emailField.text!.isEmpty {
            emailView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            emailView.layer.borderWidth = 1
            btnEmailError.isHidden = false
            emailErrorMsg = "Your email is empty, please try again."
            return
        }
        
        if !self.isValidEmail(email: emailField.text!) {
            emailView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            emailView.layer.borderWidth = 1
            btnEmailError.isHidden = false
            emailErrorMsg = "Your email is invalid, please try again."
            return
        }
        
        if passwordField.text!.isEmpty {
            passwordView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            passwordView.layer.borderWidth = 1
            btnPasswordError.isHidden = false
            passwordErrorMsg = "Your password is empty, please try again."
            return
        }
 
        showHUD()
        signinBtn.isLoading = true
        AuthService.shared.signIn(email: emailField.text!, password: passwordField.text!) { (user) in
            self.dismissHUD()
            self.signinBtn.isLoading = false
            Pref.shared.setPref(.uid, value: user.userId!)
            Pref.shared.setPref(.username, value: user.name!)
            DispatchQueue.main.async {

                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
                self.view.window?.rootViewController = vc
                CRNotifications.showNotification(textColor: .white, backgroundColor: UIColor(hex: 0x3A3A3E)!, image: UIImage(named: "success"), title: "Success!", message: "Login successfully", dismissDelay: 2.0)
            }

        } error: { [self] (error) in
            self.dismissHUD()
            self.signinBtn.isLoading = false
            if error == "The password is invalid or the user does not have a password." {
                self.passwordView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
                self.passwordView.layer.borderWidth = 1
                self.btnPasswordError.isHidden = false
                self.passwordErrorMsg = error
            }else if error == "There is no user record corresponding to this identifier. The user may have been deleted." {
                self.emailView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
                self.emailView.layer.borderWidth = 1
                self.btnEmailError.isHidden = false
                self.emailErrorMsg = error
            }else if error == "The email was not verified." {
                self.emailView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
                self.emailView.layer.borderWidth = 1
                self.btnEmailError.isHidden = false
                self.emailErrorMsg = error
            }else if error == "The user does not exist."{
                let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
                vc.password = passwordField.text!
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.showAlert("Error", msg: error) { _ in }
            }
        }

    }

    
    @IBAction func didTapEmailError(_ sender: UIButton) {
        
        showTipView(sender, message: emailErrorMsg)
       
    }
    
    @IBAction func didTapPasswordError(_ sender: UIButton) {
        
        showTipView(sender, message: passwordErrorMsg)
       
    }
    
    @IBAction func didTapBackground(_ sender: Any) {
        
        if tipView != nil {
            tipView?.dismiss()
        }
    }
    
    @IBAction func didTapForgotPassword(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension SigninVC: UITextFieldDelegate {

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if tipView != nil {
            tipView?.dismiss()
        }
        
        if textField == emailField {
            emailView.layer.borderWidth = 0
            btnEmailError.isHidden = true
            emailErrorMsg = ""
        }
        
        if textField == passwordField {
            passwordView.layer.borderWidth = 0
            btnPasswordError.isHidden = true
            passwordErrorMsg = ""
        }
        return true
    }
}
