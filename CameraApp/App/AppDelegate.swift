//
//  AppDelegate.swift
//  CameraApp
//
//  Created by developer on 11/30/20.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import Stripe
import GoogleSignIn
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        

        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        
        let db = Firestore.firestore()
        db.settings = settings
        
        if Auth.auth().currentUser != nil {
            let pushManager = PushNotificationManager(userID: Auth.auth().currentUser!.uid)
            pushManager.registerForPushNotifications()
        }else{
            let pushManager = PushNotificationManager(userID: "")
            pushManager.registerForPushNotifications()
        }
        
       
        
        StripeAPI.defaultPublishableKey = Constants.STRIPE_PUBLISHABLEKEY
        GIDSignIn.sharedInstance().clientID = "com.googleusercontent.apps.679485920545-m8js76t2pj63u0taj8dchke4mpeecdop"
//        Thread.sleep(forTimeInterval: 3.0)
        window = UIWindow(frame: UIScreen.main.bounds)

        for family in UIFont.familyNames {
            print("\(family)")

            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
        
        window?.makeKeyAndVisible()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }


    
    // MARK: UISceneSession Lifecycle
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
  
  
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        
    }
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//
//        return ApplicationDelegate.shared.application(application,
//                                                         open: url,
//                                                         sourceApplication: sourceApplication,
//                                                         annotation: annotation)
//    }
    

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {

        return ApplicationDelegate.shared.application(application, open: url, options: options)
   }
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//
//        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//        )
//    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert,.badge,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    
  
}
