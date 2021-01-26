
import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "priority": "high",
                                           "content-available" : 1,
                                           "notification" : ["title" : title, "body" : body,"badge": 1,"sound": "default"],
                                           "data" : [:]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAnjSEVSE:APA91bGUCy0I5H1-J2lYpQoipYqOOt1BDqycHWnYkfyfAMLpdHq6hv5S0KBYWP1a8gVd6PMw8oMz8p1ka32vPHB-d7GA05_AL9tYeaCdG1egeOB0IgksrYgx3RRBe7ueKoRVhROHw3tB", forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
        
        
    }
}
