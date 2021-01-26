//
//  PaymentInfoVC.swift
//  CameraApp
//
//  Created by developer on 12/13/20.
//

import UIKit
import FormTextField
import Stripe
import LGButton
import PassKit
import EasyTipView

class PaymentInfoVC: BaseViewController {
    
    
    
    @IBOutlet weak var cardNumView: UIView!
    @IBOutlet weak var cardNumErrBtn: UIButton!
    @IBOutlet weak var cardholderView: UIView!
    @IBOutlet weak var cardholderErrBtn: UIButton!
    @IBOutlet weak var expDateView: UIView!
    @IBOutlet weak var expDateErrBtn: UIButton!
    @IBOutlet weak var securityErrBtn: UIButton!
    @IBOutlet weak var securityView: UIView!
    @IBOutlet weak var addressField1: CustomField!
    @IBOutlet weak var addressField2: CustomField!
    @IBOutlet weak var cityField: CustomField!
    @IBOutlet weak var stateField: CustomField!
    @IBOutlet weak var zipcodeField: CustomField!
    @IBOutlet weak var address1View: UIView!
    @IBOutlet weak var address1ErrorBtn: UIButton!
    @IBOutlet weak var cityErrorBtn: UIButton!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var stateErrorBtn: UIButton!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var zipcodeErrorBtn: UIButton!
    @IBOutlet weak var zipcodeView: UIView!
    
    @IBOutlet weak var cameraBtn: UIButton!{
        didSet{
            cameraBtn.layer.borderColor = UIColor(hex: 0xE36D12)?.cgColor
            cameraBtn.layer.borderWidth = 0.4
        }
    }
    
    @IBOutlet weak var cardNumberField: FormTextField!{
        didSet{
            cardNumberField.attributedPlaceholder = NSAttributedString(string: "XXXX XXXX XXXX XXXX",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    @IBOutlet weak var cardHolderField: FormTextField!
    @IBOutlet weak var expireField: FormTextField!{
        didSet{
            expireField.attributedPlaceholder = NSAttributedString(string: "MM/YY",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    
    @IBOutlet weak var securityField: FormTextField!{
        didSet{
            securityField.attributedPlaceholder = NSAttributedString(string: "---",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    @IBOutlet weak var saveBtn: LGButton!
    
    var preferences = EasyTipView.Preferences()
    var tipView: EasyTipView?
    var address1ErrorMsg = ""
    var cityErrorMsg = ""
    var stateErrorMsg = ""
    var zipcodeErrorMsg = ""
    var cardNumErrorMsg = ""
    var cardHolerErrorMsg = ""
    var expDateErrorMsg = ""
    var securityErrorMsg = ""
    var cardNum = ""
    var securityCode = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        initTextField()
        initTipPreferences()
        getPaymentInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if tipView != nil {
            tipView?.dismiss()
        }
        self.view.endEditing(true)
    }
    
    func initTextField(){
        
        cardNumberField.inputType = FormTextFieldInputType.integer
        cardNumberField.formatter = CardNumberFormatter()
        cardNumberField.activeTextColor = .white
        cardNumberField.inactiveTextColor = .white
        cardNumberField.clearButtonColor = .clear
        cardNumberField.validTextColor = .white
        var validation = Validation()
        validation.maximumLength = "1234 5678 1234 5678".count
        validation.minimumLength = "1234 5678 1234 5678".count
        let characterSet = NSMutableCharacterSet.decimalDigit()
        characterSet.addCharacters(in: " ")
        validation.characterSet = characterSet as CharacterSet
        cardNumberField.inputValidator = InputValidator(validation: validation)
        
        
        cardHolderField.inputType = .name
        cardHolderField.activeTextColor = .white
        cardHolderField.inactiveTextColor = .white
        cardHolderField.clearButtonColor = .clear
        cardHolderField.validTextColor = .white
        var validation1 = Validation()
        validation1.minimumLength = 1
        cardHolderField.inputValidator = InputValidator(validation: validation1)
        
        expireField.inputType = .integer
        expireField.formatter = CardExpirationDateFormatter()
        expireField.activeTextColor = .white
        expireField.inactiveTextColor = .white
        expireField.clearButtonColor = .clear
        expireField.validTextColor = .white
        var validation2 = Validation()
        validation2.minimumLength = 1
        expireField.inputValidator = CardExpirationDateInputValidator(validation: validation2)
        
        securityField.inputType = .integer
        securityField.activeTextColor = .white
        securityField.inactiveTextColor = .white
        securityField.clearButtonColor = .clear
        securityField.validTextColor = .white
        var validation3 = Validation()
        validation3.maximumLength = 3
        validation3.minimumLength = 3
        validation3.characterSet = CharacterSet.decimalDigits
        securityField.inputValidator = InputValidator(validation: validation3)
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
    
    func initView(_ paymentInfo: PaymentModel){
        
        
        let subString = paymentInfo.cardNumber!.dropFirst(15)
        
        self.cardNumberField.text = "**** **** **** \(String(subString))"
        self.cardHolderField.text = paymentInfo.cardHolder
        self.expireField.text = paymentInfo.expDate
        self.securityField.text = "***"
        self.addressField1.text = paymentInfo.billingAddress1
        self.addressField2.text = paymentInfo.billingAddress2
        self.stateField.text = paymentInfo.state
        self.cityField.text = paymentInfo.city
        self.zipcodeField.text = paymentInfo.zipcode
        self.securityCode = paymentInfo.cvv!
        self.cardNum = paymentInfo.cardNumber!

    }
    
    func getPaymentInfo(){
        self.showHUD()
        FirestoreService.shared.getPayment { (paymentInfo) in
            self.dismissHUD()
            self.initView(paymentInfo)
        } error: { (err) in
            self.dismissHUD()
        }
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
    
    @IBAction func didTapAddress1Error(_ sender: UIButton) {
        showTipView(sender, message: address1ErrorMsg)
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
    
    @IBAction func didTapCardNumErr(_ sender: UIButton) {
        showTipView(sender, message: cardNumErrorMsg)
    }
    
    @IBAction func didTapCardholderErr(_ sender: UIButton) {
        showTipView(sender, message: cardHolerErrorMsg)
    }
    
    @IBAction func didTapExpErr(_ sender: UIButton) {
        showTipView(sender, message: expDateErrorMsg)
    }
    
    @IBAction func didTapSecurityErr(_ sender: UIButton) {
        showTipView(sender, message: securityErrorMsg)
        
    }
    @IBAction func didTapBackground(_ sender: Any) {
        
        if tipView != nil {
            tipView?.dismiss()
        }
    }

    @IBAction func didTapCamera(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        
        if !cardNumberField.text!.contains(find: "****") {
            if !cardNumberField.validate() {
                cardNumView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
                cardNumView.layer.borderWidth = 1
                cardNumErrBtn.isHidden = false
                cardNumErrorMsg = "Card Number is invalid."
                cardNumberField.becomeFirstResponder()
                return
            }
        }
        

        
        if cardHolderField.text!.isEmpty {
            cardholderView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            cardholderView.layer.borderWidth = 1
            cardholderErrBtn.isHidden = false
            cardNumErrorMsg = "Cardholder is empty, please try again."
            cardHolderField.becomeFirstResponder()
            return
        }
        
        if !expireField.validate() {
            expDateView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            expDateView.layer.borderWidth = 1
            expDateErrBtn.isHidden = false
            expDateErrorMsg = "Exp date is invalid."
            expireField.becomeFirstResponder()
            return
        }
        
        if  !securityField.validate() && securityField.text != "***" {
            securityView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            securityView.layer.borderWidth = 1
            securityErrBtn.isHidden = false
            securityErrorMsg = "CVV is invalid."
            securityField.becomeFirstResponder()
            return
        }
        
        
        if addressField1.text!.isEmpty {
            address1View.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            address1View.layer.borderWidth = 1
            address1ErrorBtn.isHidden = false
            address1ErrorMsg = "Mailing Address1 is empty, please try again."
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
        
        
        self.showHUD()
        var data = [String:Any]()
        data[Constants.CARDHOLDER] = cardHolderField.text
        data[Constants.CARDNUMBER] = self.cardNum
        data[Constants.EXPDATE] = expireField.text
        data[Constants.ISAPPLEPAY] = false
        data[Constants.CVV] = self.securityCode
        data[Constants.BILLING_ADDRESS1] = addressField1.text
        data[Constants.BILLING_ADDRESS2] = addressField2.text
        data[Constants.STATE] = stateField.text
        data[Constants.CITY] = cityField.text
        data[Constants.ZIPCODE] = zipcodeField.text


        FirestoreService.shared.createPaymentInfo(data) { (success) in
            self.dismissHUD()
            self.navigationController?.popViewController(animated: true)
        }


    }
    
    func substring(string: String, fromIndex: Int, toIndex: Int) -> String? {
        if fromIndex < toIndex && toIndex < string.count /*use string.characters.count for swift3*/{
            let startIndex = string.index(string.startIndex, offsetBy: fromIndex)
            let endIndex = string.index(string.startIndex, offsetBy: toIndex)
            return String(string[startIndex..<endIndex])
        }else{
            return nil
        }
    }
}

extension PaymentInfoVC: UITextFieldDelegate {
 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if tipView != nil {
            tipView?.dismiss()
        }
        
        if let str = textField.text,
            let textRange = Range(range, in: str) {
            let updatedText = str.replacingCharacters(in: textRange,
                                                       with: string)
           
            if textField == cardNumberField {
                self.cardNum = updatedText
            }
            if textField == securityField {
                self.securityCode = updatedText
            }
        }
        
        if textField == cardNumberField {
            cardNumView.layer.borderWidth = 0
            cardNumErrBtn.isHidden = true
            cardNumErrorMsg = ""
        }
        
        if textField == cardHolderField {
            cardholderView.layer.borderWidth = 0
            cardholderErrBtn.isHidden = true
            cardHolerErrorMsg = ""
        }
        
        if textField == expireField {
            expDateView.layer.borderWidth = 0
            expDateErrBtn.isHidden = true
            expDateErrorMsg = ""
        }
        
        if textField == securityField {
            securityView.layer.borderWidth = 0
            securityErrBtn.isHidden = true
            securityErrorMsg = ""
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == cardNumberField {
            cardNumberField.text = self.cardNum
        }
        
        if textField == securityField {
            securityField.text = self.securityCode
        }
        
        return true
    }
}

