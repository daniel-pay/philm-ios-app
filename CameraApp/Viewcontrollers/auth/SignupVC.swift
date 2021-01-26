//
//  SignupVC.swift
//  CameraApp
//
//  Created by developer on 12/1/20.
//

import UIKit
import EasyTipView
import CRNotifications
import LGButton
import FirebaseAuth

class SignupVC: BaseViewController {
    
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
    @IBOutlet weak var emailErrorBtn: UIButton!
    @IBOutlet weak var passwordErrorBtn: UIButton!
    @IBOutlet weak var signupBtn: LGButton!
    
    var preferences = EasyTipView.Preferences()
    var tipView: EasyTipView?
    var nameErrorMsg = ""
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
        preferences.positioning.maxWidth = self.view.frame.width - 50
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

    @IBAction func didTapSignup(_ sender: Any) {
        
        if tipView != nil {
            tipView?.dismiss()
        }
        
        self.view.endEditing(true)

        
        if emailField.text!.isEmpty {
            emailView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            emailView.layer.borderWidth = 1
            emailErrorBtn.isHidden = false
            emailErrorMsg = "Your email is empty, please try again."
            return
        }
        
        if !self.isValidEmail(email: emailField.text!) {
            emailView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            emailView.layer.borderWidth = 1
            emailErrorBtn.isHidden = false
            emailErrorMsg = "Your email is invalid, please try again."
            return
        }
        
        if passwordField.text!.isEmpty {
            passwordView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            passwordView.layer.borderWidth = 1
            passwordErrorBtn.isHidden = false
            passwordErrorMsg = "Your password is empty, please try again."
            return
        }
        
        if passwordField.text!.count < 6 {
            passwordView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            passwordView.layer.borderWidth = 1
            passwordErrorBtn.isHidden = false
            passwordErrorMsg = "Password must be at least 6 characters, please try again."
            return
        }
        showHUD()
        self.signupBtn.isLoading = true
        
        AuthService.shared.signup(email: emailField.text!, password: passwordField.text!) { [self] (success) in
            self.dismissHUD()
            self.signupBtn.isLoading = false
            if success {
                let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
                vc.password = passwordField.text!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } error: { (err) in
            self.dismissHUD()
            self.signupBtn.isLoading = false
            if err == "The email address is already in use by another account." {
                self.emailView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
                self.emailView.layer.borderWidth = 1
                self.emailErrorBtn.isHidden = false
                self.emailErrorMsg = err
            }else{
                self.showAlert("Error", msg: err) { _ in }
            }
        }

    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
}

extension SignupVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       

        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if tipView != nil {
            tipView?.dismiss()
        }
   
        if textField == emailField {
            emailView.layer.borderWidth = 0
            emailErrorBtn.isHidden = true
            emailErrorMsg = ""
        }
        
        if textField == passwordField {
            passwordView.layer.borderWidth = 0
            passwordErrorBtn.isHidden = true
            passwordErrorMsg = ""
        }
        return true
    }
}
