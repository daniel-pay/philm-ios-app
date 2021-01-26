//
//  ForgotPasswordVC.swift
//  CameraApp
//
//  Created by developer on 12/1/20.
//

import UIKit
import EasyTipView
import LGButton

class ForgotPasswordVC: BaseViewController {
    
    @IBOutlet weak var emailField: UITextField!{
        didSet{
            emailField.attributedPlaceholder = NSAttributedString(string: "Enter your username or email",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var btnEmailError: UIButton!
    @IBOutlet weak var resetBtn: LGButton!
    
    var preferences = EasyTipView.Preferences()
    var tipView: EasyTipView?
    var emailErrorMsg = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTipPreferences()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if tipView != nil {
            tipView?.dismiss()
        }
        self.view.endEditing(true)
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
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapRest(_ sender: Any) {
        
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
        
        showHUD()
        resetBtn.isLoading = true
        AuthService.shared.resetPassword(email: emailField.text!) { (success) in
            self.dismissHUD()
            self.resetBtn.isLoading = false
            let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "ResetLinkVC") as! ResetLinkVC
            self.navigationController?.pushViewController(vc, animated: true)
        } error: { (err) in
            
            self.dismissHUD()
            self.resetBtn.isLoading = false
            
            self.emailView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            self.emailView.layer.borderWidth = 1
            self.btnEmailError.isHidden = false
            self.emailErrorMsg = "Your email is incorrect, please try again"
        }
        
    }
    
    @IBAction func didTapEmailError(_ sender: Any) {
        
        showTipView(btnEmailError, message: emailErrorMsg)
       
    }
    
    @IBAction func didTapBackground(_ sender: Any) {
        
        if tipView != nil {
            tipView?.dismiss()
        }
    }
    
}

extension ForgotPasswordVC: UITextFieldDelegate {

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if tipView != nil {
            tipView?.dismiss()
        }
        
        if textField == emailField {
            emailView.layer.borderWidth = 0
            btnEmailError.isHidden = true
            emailErrorMsg = ""
        }
       
        return true
    }
}
