//
//  CardPayVC.swift
//  CameraApp
//
//  Created by developer on 12/3/20.
//

import UIKit
import FormTextField
import Stripe
import LGButton
import PassKit
import EasyTipView


class CardPayVC: BaseViewController {
    
    

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
    @IBOutlet weak var payBtn: LGButton!
    
    var stripePublishableKey = Constants.STRIPE_PUBLISHABLEKEY
    var backendBaseURL: String? = Constants.backendBaseURL
    let companyName = "Philm"
    var country: String = ""
    var paymentCurrency: String = ""
    var rollId: String?
    var paymentId = String()
    var paymentContext: STPPaymentContext?
    var apiClient: STPAPIClient = STPAPIClient.shared
    
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    self.payBtn.isEnabled = false
                } else {
                    self.payBtn.isEnabled = true
                }
            }, completion: nil)
        }
    }
    
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
        cardNumberField.becomeFirstResponder()
        cardNumberField.resignFirstResponder()
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
    
    func initStripe(){
        
        let backendBaseURL = self.backendBaseURL
        
        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL

        // This code is included here for the sake of readability, but in your application you should set up your configuration and theme earlier, preferably in your App Delegate.
        StripeAPI.defaultPublishableKey = self.stripePublishableKey
        let config = STPPaymentConfiguration.shared
//        config.appleMerchantIdentifier = self.appleMerchantID
        config.companyName = self.companyName
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = .none
        config.shippingType = .shipping
        config.applePayEnabled = false
        config.fpxEnabled = false
        config.cardScanningEnabled = false
        self.country = "us"
        self.paymentCurrency = "usd"
        
        if Pref.shared.customerId.isEmpty {
            MyAPIClient.sharedClient.createNewCustomer(withAPIVersion: STPAPIClient.apiVersion) { [self] (customerId) in
               
                let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
                let paymentContext = STPPaymentContext(customerContext: customerContext,
                                                       configuration: config,
                                                       theme: .defaultTheme)
                let userInformation = STPUserInformation()
                paymentContext.prefilledInformation = userInformation
                paymentContext.paymentAmount = 1
                paymentContext.paymentCurrency = self.paymentCurrency

                self.paymentContext = paymentContext
                self.paymentContext!.delegate = self
        //        paymentContext.hostViewController = self
                
                paymentContextDidChange(self.paymentContext!)
            } error: { (err) in
                self.showAlert("Error", msg: err) { _ in }
            }
        }else{
            let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
            let paymentContext = STPPaymentContext(customerContext: customerContext,
                                                   configuration: config,
                                                   theme: .defaultTheme)
            let userInformation = STPUserInformation()
            paymentContext.prefilledInformation = userInformation
            paymentContext.paymentAmount = 1
            paymentContext.paymentCurrency = self.paymentCurrency

            self.paymentContext = paymentContext
            self.paymentContext!.delegate = self
    //        paymentContext.hostViewController = self
            
            paymentContextDidChange(self.paymentContext!)
        }
                



    }
    
    func initView(_ paymentInfo: PaymentModel){
        
        self.cardNumberField.text = paymentInfo.cardNumber
        self.cardHolderField.text = paymentInfo.cardHolder
        self.expireField.text = paymentInfo.expDate
        self.securityField.text = paymentInfo.cvv
        self.addressField1.text = paymentInfo.billingAddress1
        self.addressField2.text = paymentInfo.billingAddress2
        self.stateField.text = paymentInfo.state
        self.cityField.text = paymentInfo.city
        self.zipcodeField.text = paymentInfo.zipcode

    }
    
    func getPaymentInfo(){
        self.showHUD()
        FirestoreService.shared.getPayment { [self] (paymentInfo) in
            self.dismissHUD()
            self.initView(paymentInfo)
            initStripe()
        } error: { (err) in
            self.dismissHUD()
            self.initStripe()
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
    
    @IBAction func didTapPay(_ sender: Any) {
        
        if !cardNumberField.validate() {
            cardNumView.layer.borderColor = UIColor(hex: 0xF33535)?.cgColor
            cardNumView.layer.borderWidth = 1
            cardNumErrBtn.isHidden = false
            cardNumErrorMsg = "Card Number is invalid."
            cardNumberField.becomeFirstResponder()
            return
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
        
        if !securityField.validate() {
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
        
        
        let cardParams = STPPaymentMethodCardParams()
        
        cardParams.number = cardNumberField.text?.replacingOccurrences(of: " ", with: "")
        cardParams.expMonth = Int((expireField.text?.split(separator: "/").first)!) as NSNumber?
        cardParams.expYear = Int((expireField.text?.split(separator: "/").last)!) as NSNumber?
        cardParams.cvc = securityField.text

        // Create and return a Payment Method
        let billingDetails = STPPaymentMethodBillingDetails()
        let address = STPAddress()
        address.country = "US"
        billingDetails.address = STPPaymentMethodAddress(address: address)
        billingDetails.email = nil
        billingDetails.name = nil
        billingDetails.phone = nil
        
        let paymentMethodParams = STPPaymentMethodParams(
          card: cardParams,
          billingDetails: billingDetails,
          metadata: nil)
        if self.paymentContext == nil {
            return
        }
        self.paymentInProgress = true
        self.showHUD()
        apiClient.createPaymentMethod(with: paymentMethodParams) { [self]
          paymentMethod, createPaymentMethodError in
          if let createPaymentMethodError = createPaymentMethodError {
            self.showAlert("Error", msg: createPaymentMethodError.localizedDescription) { _ in }
            self.paymentInProgress = false
            self.dismissHUD()
          } else {
            if let paymentMethod = paymentMethod {

                DispatchQueue.main.async {
                    self.paymentId =  paymentMethod.stripeId
                    self.paymentContext!.paymentOptionsViewController(STPPaymentOptionsViewController.init(), didSelect: paymentMethod)
                    self.paymentContext!.requestPayment()
                }

            }else{
                self.dismissHUD()
                self.paymentInProgress = false
            }
          }
        }


    }
}

// MARK: STPPaymentContextDelegate
extension CardPayVC: STPPaymentContextDelegate {
    enum CheckoutError: Error {
        case unknown

        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error"
            }
        }
    }
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        // Create the PaymentIntent on the backend
        // To speed this up, create the PaymentIntent earlier in the checkout flow and update it as necessary (e.g. when the cart subtotal updates or when shipping fees and taxes are calculated, instead of re-creating a PaymentIntent for every payment attempt.
        MyAPIClient.sharedClient.createPaymentIntent(shippingMethod: paymentContext.selectedShippingMethod, country: self.country, paymentId: self.paymentId) { result in
            switch result {
            case .success(let clientSecret):
                // Confirm the PaymentIntent
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.configure(with: paymentResult)
                paymentIntentParams.returnURL = "payments-example://stripe-redirect"
                STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: paymentContext) { status, _, error in
                    switch status {
                    case .succeeded:
                        // Our example backend asynchronously fulfills the customer's order via webhook
                        // See https://stripe.com/docs/payments/payment-intents/ios#fulfillment
                        completion(.success, nil)
                    case .failed:
                        completion(.error, error)
                    case .canceled:
                        completion(.userCancellation, nil)
                    @unknown default:
                        completion(.error, nil)
                    }
                }
            case .failure(let error):
                // A real app should retry this request if it was a network error.
                print("Failed to create a Payment Intent: \(error)")
                completion(.error, error)
                break
            }
        }
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        self.paymentInProgress = false
       
        let title: String
        let message: String
        switch status {
        case .error:
            self.dismissHUD()
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            self.paymentInProgress = false
            
            FirestoreService.shared.createRoll(20) { [self] (success) in
                self.dismissHUD()
                if success {
                    
                    var data = [String:Any]()
                    data[Constants.CARDHOLDER] = cardHolderField.text
                    data[Constants.CARDNUMBER] = cardNumberField.text
                    data[Constants.EXPDATE] = expireField.text
                    data[Constants.ISAPPLEPAY] = false
                    data[Constants.CVV] = securityField.text
                    data[Constants.BILLING_ADDRESS1] = addressField1.text
                    data[Constants.BILLING_ADDRESS2] = addressField2.text
                    data[Constants.STATE] = stateField.text
                    data[Constants.CITY] = cityField.text
                    data[Constants.ZIPCODE] = zipcodeField.text


                    FirestoreService.shared.createPaymentInfo(data) { (success) in
                        
                    }
                    
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentSuccessVC") as! PaymentSuccessVC
                    vc.rollId = self.rollId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }          

            
            return
            
        case .userCancellation:
            self.dismissHUD()
            return()
        @unknown default:
            self.dismissHUD()
            return()
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        guard isViewLoaded else {
            return
        }
//        payBtn.isEnabled = paymentContext.selectedPaymentOption != nil && (paymentContext.selectedShippingMethod != nil || self.shippingRow == nil)
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        self.dismissHUD()
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self.paymentContext!.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }

    // Note: this delegate method is optional. If you do not need to collect a
    // shipping method from your user, you should not implement this method.
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0.1
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        let upsWorldwide = PKShippingMethod()
        upsWorldwide.amount = 10.99
        upsWorldwide.label = "UPS Worldwide Express"
        upsWorldwide.detail = "Arrives in 1-3 days"
        upsWorldwide.identifier = "ups_worldwide"
        let fedEx = PKShippingMethod()
        fedEx.amount = 5.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if address.country == nil || address.country == "US" {
                completion(.valid, nil, [upsGround, fedEx], fedEx)
            } else if address.country == "AQ" {
                let error = NSError(domain: "ShippingError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Invalid Shipping Address",
                                                                                   NSLocalizedFailureReasonErrorKey: "We can't ship to this country."])
                completion(.invalid, error, nil, nil)
            } else {
                fedEx.amount = 20.99
                fedEx.identifier = "fedex_world"
                completion(.valid, nil, [upsWorldwide, fedEx], fedEx)
            }
        }
    }

}

extension CardPayVC: UITextFieldDelegate {
 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if tipView != nil {
            tipView?.dismiss()
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
}
