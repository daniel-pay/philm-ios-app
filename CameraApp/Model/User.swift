

import UIKit
import FirebaseFirestore

class User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }    
    
    
    var userId: String?
    var name: String?
    var email: String?
    var address1: String?
    var address2: String?
    var city: String?
    var state: String?
    var zipcode: String?
    var paymentInfo: String?
    var password: String?
    var profileImage: String?
    var fcmToken: String?
    var socialLogin: Bool?
    var admin: Bool?
    var isCompleted: Bool = false
    var photoCount = 0
    var rollNum = 0
    var completedDate: Timestamp?
    var rolls: [[String : Any]] = []

    
    init(_ json: [String: Any]) {
        userId = json[Constants.USER_ID] as? String
        name = json[Constants.USER_NAME] as? String
        email = json[Constants.USER_EMAIL] as? String
        address1 = json[Constants.ADDRESS1] as? String ?? ""
        address2 = json[Constants.ADDRESS2] as? String ?? ""
        city = json[Constants.CITY] as? String ?? ""
        state = json[Constants.STATE] as? String ?? ""
        zipcode = json[Constants.ZIPCODE] as? String ?? ""
        paymentInfo = json[Constants.PAYMENTINFO] as? String ?? ""

        profileImage = json[Constants.PROFILE_IMAGE] as? String ?? ""
        fcmToken = json[Constants.FCM_TOKEM] as? String ?? ""
        password = json[Constants.PASSWORD] as? String ?? ""
        socialLogin = json[Constants.SSO] as? Bool ?? false
        admin = json[Constants.ADMIN] as? Bool ?? false


    }
    
    init(id: String, email: String){
        self.userId = id
        self.email = email
    }
}
