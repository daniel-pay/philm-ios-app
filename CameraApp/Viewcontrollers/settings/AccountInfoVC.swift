//
//  AccountInfoVC.swift
//  CameraApp
//
//  Created by developer on 12/2/20.
//

import UIKit
import FirebaseAuth
import LGButton
import EasyTipView
import CRNotifications

class AccountInfoVC: BaseViewController {
    
    
    @IBOutlet weak var addressField1: CustomField!
    @IBOutlet weak var address1View: UIView!
    @IBOutlet weak var address1ErrorBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!{
        didSet{
            cameraBtn.layer.borderColor = UIColor(hex: 0xE36D12)?.cgColor
            cameraBtn.layer.borderWidth = 0.4
        }
    }
    @IBOutlet weak var confirmPassView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordField: CustomField!
    @IBOutlet weak var confirmPassField: CustomField!
    @IBOutlet weak var changeBtn: UIButton!
    
    @IBOutlet weak var createBtn: LGButton!
    
    var preferences = EasyTipView.Preferences()
    var tipView: EasyTipView?
    var address1ErrorMsg = ""
    var isPasswordEditing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        getUser()
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
    
    func getUser(){
        showHUD()
        FirestoreService.shared.getCurrentUser { (user) in
            self.dismissHUD()
            self.addressField1.text = user.email
            
            if user.socialLogin! {
                self.passwordView.isHidden = true
            }else{
                self.passwordView.isHidden = false
                if let base64Decoded = Data(base64Encoded: user.password!, options: Data.Base64DecodingOptions(rawValue: 0))
                .map({ String(data: $0, encoding: .utf8) }) {
                    // Convert back to a string
                    print("Decoded: \(base64Decoded ?? "")")
                    self.passwordField.text = base64Decoded
                }
            }
            
        } error: { (err) in
            self.dismissHUD()
            self.showAlert("Error", msg: err) { _ in }
        }

    }
    
    func showTipView(_ sender: UIButton, message: String){
        
        if tipView != nil {
            tipView?.dismiss()
        }
        
        tipView = EasyTipView(text: message, preferences: preferences, delegate: nil)
        tipView!.show(forView: sender)
    }
    
    @IBAction func didTapEdit(_ sender: Any) {
        
        if !isPasswordEditing {
            passwordField.isEnabled = true
            confirmPassView.isHidden = false
            isPasswordEditing = true
            changeBtn.setTitle("Change", for: .normal)
        }else{
            
            if !passwordField.text!.isEmpty && passwordField.text == confirmPassField.text{
                showHUD()
                FirestoreService.shared.updatePassword(newPassword: passwordField.text!) { [self] (success) in
                    self.dismissHUD()
                    passwordField.isEnabled = false
                    confirmPassView.isHidden = true
                    isPasswordEditing = false
                    changeBtn.setTitle("Edit", for: .normal)
                } error: { (err) in
                    self.dismissHUD()
                }
            }
        }
    }
    
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapCreate(_ sender: Any) {
        

        
        if addressField1.text!.isEmpty {
            address1View.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            address1View.layer.borderWidth = 1
            address1ErrorBtn.isHidden = false
            address1ErrorMsg = "Email is empty, please try again."
            addressField1.becomeFirstResponder()
            return
        }
        
        if Auth.auth().currentUser?.email != addressField1.text {
            
            showHUD()
            self.createBtn.isLoading = true
            FirestoreService.shared.updateEmail(email: addressField1.text!) { [self] (success) in
                if success {
                    
                    self.dismissHUD()
                    self.createBtn.isLoading = false
                    self.navigationController?.popViewController(animated: true)
                    
                }
            } error: { (err) in
                self.dismissHUD()
                self.createBtn.isLoading = false
                self.showAlert("Error", msg: err) { _ in }
            }

        }

    }
    

    
    @IBAction func didTapAddress1Error(_ sender: UIButton) {
        showTipView(sender, message: address1ErrorMsg)
    }
   
    
    @IBAction func didTapBackground(_ sender: Any) {
        
        if tipView != nil {
            tipView?.dismiss()
        }
    }
    @IBAction func didTapCamera(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}


extension AccountInfoVC: UITextFieldDelegate {
 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if tipView != nil {
            tipView?.dismiss()
        }
        
        if textField == addressField1 {
            address1View.layer.borderWidth = 0
            address1ErrorBtn.isHidden = true
            address1ErrorMsg = ""
        }
        
        if let str = textField.text,
            let textRange = Range(range, in: str) {
            let updatedText = str.replacingCharacters(in: textRange,
                                                       with: string)
           
            if textField == confirmPassField {
                if self.passwordField.text == updatedText {
                    self.confirmPassField.textColor = .white
                }else{
                    self.confirmPassField.textColor = UIColor(hex: 0xF33535)
                }
            }
            
        }
       
        return true
    }
}
