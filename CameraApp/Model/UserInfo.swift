

import Foundation

enum Field {
    case uid
    case username
    case isFirstRun
    case rollCount
    case customerId

}

class Pref: NSObject {
    
    static let shared = Pref()
    
    var uid: String = ""
    var username: String = ""
    var isFirstRun: Bool = false
    var rollCount: Int = 0
    var customerId: String = ""

    override init() {
        super.init()
        
        initialize()
    }
    
    func initialize() {
        let defaults = UserDefaults.standard
        if let uid = defaults.string(forKey: "uid") {
            self.uid = uid
        }
        if let username = defaults.string(forKey: "username") {
            self.username = username
        }
        self.isFirstRun = defaults.bool(forKey: "isFirstRun")
        self.rollCount = defaults.integer(forKey: "rollCount")

        if let customerId = defaults.string(forKey: "customerId") {
            self.customerId = customerId
        }
    }
    
    func setPref(_ key: Field, value: Any) {
        let defaults = UserDefaults.standard
        
        switch key {
        case .uid:
            uid = value as? String ?? ""
            defaults.set(uid, forKey: "uid")
        case .username:
            username = value as? String ?? ""
            defaults.set(username, forKey: "username")
        case .isFirstRun:
            isFirstRun = value as? Bool ?? false
            defaults.set(isFirstRun, forKey: "isFirstRun")
        case .rollCount:
            rollCount = value as? Int ?? 0
            defaults.set(rollCount, forKey: "rollCount")
        case .customerId:
            customerId = value as? String ?? ""
            defaults.set(customerId, forKey: "customerId")
        }
        
        
    }
    
}
