

import Firebase
import FirebaseMessaging
import FirebaseFirestore
import UIKit
import UserNotifications
import FirebaseAuth
import CRNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
  

    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        
        if userID != "" {
             updateFirestorePushTokenIfNeeded()
        }       
    }

    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection(Constants.COLLECTION_USER).document(userID)
            usersRef.setData(["fcmToken": token], merge: true)
        }
    }

//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        print(remoteMessage.appData) // or do whatever
//    }
    
    
    

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if Auth.auth().currentUser != nil {
            let usersRef = Firestore.firestore().collection(Constants.COLLECTION_USER).document(Auth.auth().currentUser!.uid)
            usersRef.setData(["fcmToken": fcmToken! as String], merge: true)
        } 
    }
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)      
        
        let userInfo = response.notification.request.content.userInfo      
        
//        if userInfo["taskId"] != nil {
//
//            var data2 = [String:Any]()
//            data2["type"] = "reminder"
//            data2["channelId"] = userInfo["taskId"] as! String
//            data2["userId"] = Auth.auth().currentUser?.uid
//
//            FirestoreService.shared.saveNotification(uid: Auth.auth().currentUser!.uid, data: data2, success: { (notificationId) in
//
//            }, error: { (eee) in
//                CRNotifications.showNotification(type: CRNotifications.error, title: "Error", message: eee, dismissDelay: 2)
//            })
//
//
//        }else{
//            if userInfo["type"] as! String == "direct_message" {
//
//                var info = [String:Any]()
//                info[Constants.GROUP_ID] = userInfo["id"] as! String
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "directMessageReceived"), object: nil, userInfo: info)
//
//
//            }
//
//            if userInfo["type"] as! String == "group_message" {
//
//                var info = [String:Any]()
//                info[Constants.GROUP_ID] = userInfo["id"] as! String
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "groupMessageReceived"), object: nil, userInfo: info)
//
//            }
//
//            if userInfo["type"] as! String == "task" {
//
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taskMessageReceived"), object: nil, userInfo: nil)
//            }
//        }
        
        
        
        completionHandler()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       
        
        if UIApplication.shared.applicationState == .active && Auth.auth().currentUser != nil{
            
            let userInfo = notification.request.content.userInfo
            
//            if userInfo["taskId"] != nil {
//
//                var data2 = [String:Any]()
//                data2["type"] = "reminder"
//                data2["channelId"] = userInfo["taskId"] as! String
//                data2["userId"] = Auth.auth().currentUser?.uid
//
//                FirestoreService.shared.saveNotification(uid: Auth.auth().currentUser!.uid, data: data2, success: { (notificationId) in
//
//
//                }, error: { (eee) in
//                    CRNotifications.showNotification(type: CRNotifications.error, title: "Error", message: eee, dismissDelay: 2)
//                })
//
//            }else{
//                if userInfo["type"] as! String == "direct_message" {
//
//                    var info = [String:Any]()
//                    info[Constants.GROUP_ID] = userInfo["id"] as! String
//                    info[Constants.NOTIFICATION_ID] = userInfo[Constants.NOTIFICATION_ID] as! String
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "directMessageReceived"), object: nil, userInfo: info)
//
//
//                }
//
//                if userInfo["type"] as! String == "group_message" {
//
//                    var info = [String:Any]()
//                    info[Constants.GROUP_ID] = userInfo["id"] as! String
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "groupMessageReceived"), object: nil, userInfo: info)
//
//
//                }
//
//                if userInfo["type"] as! String == "task" {
//
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taskMessageReceived"), object: nil, userInfo: nil)
//                }
//            }
            
            
            completionHandler([.alert, .sound, .badge])
        }        
        
    }
   
   
}
