//
//  PaymentModel.swift
//  CameraApp
//
//  Created by developer on 12/13/20.
//


import UIKit
import FirebaseFirestore

class PaymentModel: NSObject {
    
    
    var paymentId: String?
    var cardHolder: String?
    var cardNumber: String?
    var expDate: String?
    var isApplePay: Bool?
    var cvv: String?
    var billingAddress1: String?
    var billingAddress2: String?
    var state: String?
    var city: String?
    var zipcode: String?


    init(_ json: [String: Any]) {
        paymentId = json[Constants.PAYMENTID] as? String ?? ""
        cardHolder = json[Constants.CARDHOLDER] as? String ?? ""
        cardNumber = json[Constants.CARDNUMBER] as? String ?? ""
        expDate = json[Constants.EXPDATE] as? String ?? ""
        isApplePay = json[Constants.ISAPPLEPAY] as? Bool ?? false
        cvv = json[Constants.CVV] as? String ?? ""
        billingAddress1 = json[Constants.BILLING_ADDRESS1] as? String ?? ""
        billingAddress2 = json[Constants.BILLING_ADDRESS2] as? String ?? ""
        state = json[Constants.STATE] as? String ?? ""
        city = json[Constants.CITY] as? String ?? ""
        zipcode = json[Constants.ZIPCODE] as? String ?? ""






    }
   
}
