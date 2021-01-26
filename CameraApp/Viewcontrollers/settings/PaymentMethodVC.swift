//
//  PaymentMethodVC.swift
//  CameraApp
//
//  Created by developer on 12/2/20.
//

import UIKit
import LGButton
import Stripe
import PassKit

class PaymentMethodVC: BaseViewController {

    @IBOutlet weak var cameraBtn: UIButton!{
        didSet{
            cameraBtn.layer.borderColor = UIColor(hex: 0xE36D12)?.cgColor
            cameraBtn.layer.borderWidth = 0.4
        }
    }
    
    @IBOutlet weak var payPalBtn: LGButton!
    @IBOutlet weak var cardBtn: LGButton!
    @IBOutlet weak var applePayBtn: LGButton!
    @IBOutlet weak var lblPayPal: UILabel!
    @IBOutlet weak var lblCard: UILabel!
    @IBOutlet weak var lblApplePay: UILabel!
    @IBOutlet weak var payBtn: LGButton!
    
    var stripePublishableKey = Constants.STRIPE_PUBLISHABLEKEY
    var backendBaseURL: String? = Constants.backendBaseURL
    let companyName = "Philm"
    var country: String = ""
    var paymentCurrency: String = ""
    var rollId: String?

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
    var selectedIndex = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonInit()
        initStripe()
    }
    
    func initStripe(){
        
        let backendBaseURL = self.backendBaseURL
        
        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL

        // This code is included here for the sake of readability, but in your application you should set up your configuration and theme earlier, preferably in your App Delegate.
        StripeAPI.defaultPublishableKey = self.stripePublishableKey
        let config = STPPaymentConfiguration.shared
        config.appleMerchantIdentifier = "merchant.com.philm"
        config.companyName = self.companyName
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = .none
        config.shippingType = .shipping
        config.applePayEnabled = true
        config.fpxEnabled = false
        config.cardScanningEnabled = false
        self.country = "US"
        self.paymentCurrency = "USD"
        
        if Pref.shared.customerId.isEmpty {
            MyAPIClient.sharedClient.createNewCustomer(withAPIVersion: STPAPIClient.apiVersion) { [self] (customerId) in
                let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
                let paymentContext = STPPaymentContext(customerContext: customerContext,
                                                       configuration: config,
                                                       theme: .defaultTheme)
                let userInformation = STPUserInformation()
                paymentContext.prefilledInformation = userInformation
                paymentContext.paymentAmount = 2000
                paymentContext.paymentCurrency = self.paymentCurrency

                self.paymentContext = paymentContext
                self.paymentContext!.delegate = self
                paymentContext.hostViewController = self
                
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
            paymentContext.paymentAmount = 2000
            paymentContext.paymentCurrency = self.paymentCurrency

            self.paymentContext = paymentContext
            self.paymentContext!.delegate = self
            paymentContext.hostViewController = self
            
            paymentContextDidChange(self.paymentContext!)
        }

       
        

    }
    
    func buttonInit(){
        
        payPalBtn.borderColor = UIColor(hex: 0x47474B)!
        cardBtn.borderColor = UIColor(hex: 0x47474B)!
        applePayBtn.borderColor = UIColor(hex: 0x47474B)!
        
        payPalBtn.leftImageColor = UIColor(hex: 0x9B9B9B)
        payPalBtn.rightImageColor = UIColor(hex: 0x47474B)
        cardBtn.leftImageColor = UIColor.white
        cardBtn.rightImageColor = UIColor(hex: 0x47474B)
        applePayBtn.leftImageColor = UIColor.white
        applePayBtn.rightImageColor = UIColor(hex: 0x47474B)
        
        payPalBtn.rightImageSrc = UIImage(named: "ic_deselect")
        cardBtn.rightImageSrc = UIImage(named: "ic_deselect")
        applePayBtn.rightImageSrc = UIImage(named: "ic_deselect")
        
//        applePayButton = BUYPaymentButton.init(type: .buy, style: .white)
        let payButton = PKPaymentButton.init(paymentButtonType: .plain, paymentButtonStyle: .black)
        payButton.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        payButton.backgroundColor = .clear
        payButton.center.y = applePayBtn.frame.height / 2
        payButton.frame.origin.x = 20
        payButton.isUserInteractionEnabled = false
        applePayBtn.addSubview(payButton)
    }
    
    
    @IBAction func didTapPayPal(_ sender: Any) {
        buttonInit()
        payPalBtn.borderColor = UIColor(hex: 0xE36D12)!
        payPalBtn.leftImageColor = UIColor(hex: 0xE36D12)
        payPalBtn.rightImageColor = UIColor(hex: 0xE36D12)
        payPalBtn.rightImageSrc = UIImage(named: "ic_select")
        selectedIndex = 0


    }
    
    @IBAction func didTapCard(_ sender: Any) {
        buttonInit()
        cardBtn.borderColor = UIColor(hex: 0xE36D12)!
        cardBtn.leftImageColor = UIColor(hex: 0xE36D12)
        cardBtn.rightImageColor = UIColor(hex: 0xE36D12)
        cardBtn.rightImageSrc = UIImage(named: "ic_select")
        selectedIndex = 1
    }
    
    @IBAction func didTapApplePay(_ sender: Any) {
        buttonInit()
        applePayBtn.borderColor = UIColor(hex: 0xE36D12)!
        applePayBtn.leftImageColor = UIColor.white
        applePayBtn.rightImageColor = UIColor(hex: 0xE36D12)
        applePayBtn.rightImageSrc = UIImage(named: "ic_select")
        selectedIndex = 2
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        
        if self.selectedIndex == 1 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardPayVC") as! CardPayVC
            vc.rollId = self.rollId
            self.navigationController?.pushViewController(vc, animated: true)
        }else if self.selectedIndex == 2{
            
            if self.paymentContext == nil {
                return
            }
            
            self.showHUD()
            self.paymentInProgress = true
            self.paymentContext!.requestPayment()
        }
 
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapCamera(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: STPPaymentContextDelegate
extension PaymentMethodVC: STPPaymentContextDelegate {
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
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
        MyAPIClient.sharedClient.createApplePaymentIntent(shippingMethod: paymentContext.selectedShippingMethod, country: self.country) { result in
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
            
            FirestoreService.shared.createRoll(20) { (success) in
                self.dismissHUD()
                if success {
                    
                    var data = [String:Any]()
                    data[Constants.ISAPPLEPAY] = true
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
            return()
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
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
        upsGround.amount = 20
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
