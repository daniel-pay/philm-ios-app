//
//  CreateProfileVC.swift
//  CameraApp
//
//  Created by developer on 12/11/20.
//

import UIKit
import FirebaseAuth
import LGButton
import EasyTipView
import CRNotifications

class CreateProfileVC: UIViewController {

    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField1: UITextField!
    @IBOutlet weak var addressField2: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var zipcodeField: UITextField!
    @IBOutlet weak var nameErrorBtn: UIButton!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var address1View: UIView!
    @IBOutlet weak var address1ErrorBtn: UIButton!
    @IBOutlet weak var address2ErrorBtn: UIButton!
    @IBOutlet weak var address2View: UIView!
    @IBOutlet weak var cityErrorBtn: UIButton!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var stateErrorBtn: UIButton!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var zipcodeErrorBtn: UIButton!
    @IBOutlet weak var zipcodeView: UIView!
    
    
    @IBOutlet weak var createBtn: LGButton!
    
    var preferences = EasyTipView.Preferences()
    var tipView: EasyTipView?
    var nameErrorMsg = ""
    var address1ErrorMsg = ""
    var address2ErrorMsg = ""
    var cityErrorMsg = ""
    var stateErrorMsg = ""
    var zipcodeErrorMsg = ""
    var fromSocial = false
    var password = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        initTipPreferences()
        initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if tipView != nil {
            tipView?.dismiss()
        }
        self.view.endEditing(true)
    }
    
    func initView(){
        
        if Auth.auth().currentUser!.displayName != nil {
            self.nameField.text = Auth.auth().currentUser!.displayName
        }
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
    @IBAction func didTapCreate(_ sender: Any) {
        
        if nameField.text!.isEmpty {
            nameView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            nameView.layer.borderWidth = 1
            nameErrorBtn.isHidden = false
            nameErrorMsg = "Name is empty, please try again."
            nameField.becomeFirstResponder()
            return
        }
        
        if addressField1.text!.isEmpty {
            address1View.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            address1View.layer.borderWidth = 1
            address1ErrorBtn.isHidden = false
            address1ErrorMsg = "Address1 is empty, please try again."
            addressField1.becomeFirstResponder()
            return
        }
        
        if cityField.text!.isEmpty {
            cityView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            cityView.layer.borderWidth = 1
            cityErrorBtn.isHidden = false
            cityErrorMsg = "City is empty, please try again."
            cityField.becomeFirstResponder()
            return
        }
        if stateField.text!.isEmpty {
            stateView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            stateView.layer.borderWidth = 1
            stateErrorBtn.isHidden = false
            stateErrorMsg = "State is empty, please try again."
            stateField.becomeFirstResponder()
            return
        }
        
        if zipcodeField.text!.isEmpty {
            zipcodeView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            zipcodeView.layer.borderWidth = 1
            zipcodeErrorBtn.isHidden = false
            zipcodeErrorMsg = "ZIP Code is empty, please try again."
            zipcodeField.becomeFirstResponder()
            return
        }
       
        
        var data = [String:Any]()
        data[Constants.USER_NAME] = nameField.text
        data[Constants.USER_EMAIL] = Auth.auth().currentUser?.email
        data[Constants.USER_ID] = Auth.auth().currentUser?.uid
        data[Constants.ADDRESS1] = addressField1.text
        data[Constants.ADDRESS2] = addressField2.text
        data[Constants.CITY] = cityField.text
        data[Constants.STATE] = stateField.text
        data[Constants.ZIPCODE] = zipcodeField.text
        data[Constants.SSO] = fromSocial
        if fromSocial {
            data[Constants.PASSWORD] = password
        }else{
            let utf8str = password.data(using: .utf8)
            if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
                
                data[Constants.PASSWORD] = base64Encoded
            }
        }

        showHUD()
        self.createBtn.isLoading = true

        FirestoreService.shared.createUser(profile: data) { [self] (user) in
            
 
            CRNotifications.showNotification(textColor: .white, backgroundColor: UIColor(hex: 0x3A3A3E)!, image: UIImage(named: "success"), title: "Success!", message: "You successfully created an account.", dismissDelay: 2.0)
            
            if fromSocial {
                self.dismissHUD()
                self.createBtn.isLoading = false
                Pref.shared.setPref(.uid, value: user.userId!)
                Pref.shared.setPref(.username, value: user.name!)

                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
                self.view.window?.rootViewController = vc
            }else{
                
//                let actionCodeSettings = ActionCodeSettings.init()
//                let redirectUrl = String(format: "https://photoapp-81d79.firebaseapp.com/?verifyemail=%@", user.email!)
//
//                actionCodeSettings.handleCodeInApp = true
//                actionCodeSettings.url = URL(string: "https://photoapp-81d79.firebaseapp.com/")
//                actionCodeSettings.setIOSBundleID("com.camera.philm")
//
//                Auth.auth().currentUser?.sendEmailVerification(with: actionCodeSettings) { error in
//                    guard error == nil else {
//                        self.showAlert("Send Error", msg: error!.localizedDescription) { (_) in }
//                        return
//                    }
//                    self.navigationController?.popToRootViewController(animated: true)
//                }
                
                Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                    self.dismissHUD()
                    self.createBtn.isLoading = false
                    if error == nil {
                        self.showAlert("Email Verification", msg: "Please check your email and verify this address to proceed.") { (success) in
                            if success {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                })
            }
            

            
        } error: { (error) in
            
            self.dismissHUD()
            self.createBtn.isLoading = false
            self.showAlert("Error", msg: error) { _ in }
        }

    }
    
    
    @IBAction func didTapNameError(_ sender: UIButton) {
        showTipView(sender, message: nameErrorMsg)
    }
    
    @IBAction func didTapAddress1Error(_ sender: UIButton) {
        showTipView(sender, message: address1ErrorMsg)
    }
    @IBAction func didTapAddress2Error(_ sender: UIButton) {
        showTipView(sender, message: address2ErrorMsg)
    }
    @IBAction func didTapCityError(_ sender: UIButton) {
        showTipView(sender, message: cityErrorMsg)
    }
    
    @IBAction func didTapStateError(_ sender: UIButton) {
        showTipView(sender, message: stateErrorMsg)
    }
    
    @IBAction func didTapZipError(_ sender: UIButton) {
        showTipView(sender, message: zipcodeErrorMsg)
    }
    
    @IBAction func didTapBackground(_ sender: Any) {
        
        if tipView != nil {
            tipView?.dismiss()
        }
    }
    
}


extension CreateProfileVC: UITextFieldDelegate {
 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if tipView != nil {
            tipView?.dismiss()
        }
   
        if textField == nameField {
            nameView.layer.borderWidth = 0
            nameErrorBtn.isHidden = true
            nameErrorMsg = ""
        }
        
        if textField == addressField1 {
            address1View.layer.borderWidth = 0
            address1ErrorBtn.isHidden = true
            address1ErrorMsg = ""
        }
        
        if textField == cityField {
            cityView.layer.borderWidth = 0
            cityErrorBtn.isHidden = true
            cityErrorMsg = ""
        }
        
        if textField == stateField {
            stateView.layer.borderWidth = 0
            stateErrorBtn.isHidden = true
            stateErrorMsg = ""
        }
        
        if textField == zipcodeField {
            zipcodeView.layer.borderWidth = 0
            zipcodeErrorBtn.isHidden = true
            zipcodeErrorMsg = ""
        }
        return true
    }
}
