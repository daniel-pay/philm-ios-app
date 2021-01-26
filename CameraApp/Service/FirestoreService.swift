//
//  FirestoreService.swift
//  Traction
//
//  Created by admin on 7/18/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirestoreService {

    static let shared = FirestoreService()
    
    private init() {}
    
    let userCollection = Firestore.firestore().collection(Constants.COLLECTION_USER)
    let rollCollection = Firestore.firestore().collection(Constants.COLLECTION_ROLL)

    
    func createUser(profile: [String:Any], success: ((User) -> Void)?, error: ((String) -> Void)?)  {       
  
        
        userCollection.document(Auth.auth().currentUser!.uid).setData(profile,merge: true) { (err) in
            if err == nil {
                success!(User(profile))
            }else{
                error!(err!.localizedDescription)
            }
        }
        
    }
    
    func createGoogleUser(email: String, username: String, profile_image: String, success: ((User) -> Void)?, error: ((String) -> Void)?)  {
        
        var data = [String:Any]()
        data[Constants.USER_NAME] = username
        data[Constants.USER_EMAIL] = email
        data[Constants.PROFILE_IMAGE] = profile_image
        data[Constants.USER_ID] = Auth.auth().currentUser?.uid
        
        userCollection.document(Auth.auth().currentUser!.uid).setData(data) { (err) in
            if err == nil {
                success!(User(data))
            }else{
                error!(err!.localizedDescription)
            }
        }
        
    }
    
    func getCurrentUser(success: ((User) -> Void)?, error: ((String) -> Void)?)  {
        print(Auth.auth().currentUser!.uid)
        userCollection.document(Auth.auth().currentUser!.uid).getDocument { (document, err) in
            
            if err == nil {
               if let document = document, document.exists {
                    success!(User(document.data()!))
               }else{
                    error!("The user does not exist.")
               }
            }else{
                 error!(err!.localizedDescription)
            }
            
        }
    }
    
    
    
    func getUser(uid: String, success: ((User) -> Void)?, error: ((String) -> Void)?)  {
       
        
        userCollection.document(uid).addSnapshotListener { (document, err) in
            
            if err == nil {
                if let document = document, document.exists {
                    success!(User(document.data()!))
                }else{
                    error!("The user does not exist.")
                }
            }else{
                error!(err!.localizedDescription)
            }
            
        }
    }
    
    func isExistUser(uid: String, success: ((User) -> Void)?, error: ((String) -> Void)?)  {
        
        
        userCollection.document(uid).getDocument { (document, err) in
            
            if err == nil {
                if let document = document, document.exists {
                    let user = User(document.data()!)
                    if user.userId == nil {
                        error!("The user does not exist.")
                    }else{
                        success!(User(document.data()!))
                    }
                    
                }else{
                    error!("The user does not exist.")
                }
            }else{
                error!(err!.localizedDescription)
            }
        }
    }
    
    func getUserProfileURL(uid: String, success: ((String) -> Void)?, error: ((String) -> Void)?)  {
        
        
        userCollection.document(uid).addSnapshotListener { (document, err) in
            
            if err == nil {
                if let document = document, document.exists {
                    success!(User(document.data()!).profileImage!)
                }else{
                    error!("The user does not exist.")
                }
            }else{
                error!(err!.localizedDescription)
            }
            
        }
    }
    
    func getAdminUserLists(success: (([User]) -> Void)?, error: ((String) -> Void)?)  {
        
        userCollection.whereField(Constants.ADMIN, isEqualTo: true).getDocuments { (queryShots, err) in
            if err == nil {
                var users = [User]()
                queryShots?.documents.forEach({ (snapshot) in
                    print(Auth.auth().currentUser!.uid)
                    if snapshot.documentID != Auth.auth().currentUser!.uid {
                        users.append(User.init(snapshot.data()))
                    }
                    
                })
                success!(users)
            }else{
                error!(err!.localizedDescription)
            }
        }
        
    }
    
    func getUserLists(success: (([User]) -> Void)?, error: ((String) -> Void)?)  {
        
        userCollection.getDocuments { (queryShots, err) in
            if err == nil {               
                
                var users = [User]()
                queryShots?.documents.forEach({ (snapshot) in
                    users.append(User.init(snapshot.data()))
                })
                success!(users)
            }else{
                error!(err!.localizedDescription)
            }
        }
        
    }
    
    func getCompletePhotoCount(usrId: String ,result: ((Int) -> Void)?)  {
        
        userCollection.document(usrId).collection(Constants.COLLECTION_ROLL).order(by: Constants.PURCHASED_DATE, descending: true).getDocuments { (querySnapshot, error) in
            
            if error == nil {
                
                if querySnapshot!.documents.isEmpty {
                    result!(-1)
                }else{
                    let roll = RollModel(querySnapshot!.documents.first!.data())
                    result!(roll.currentCount!)
                }
            }else{
                result!(-1)
            }
        }
    }
    
    func getCompleteRollStatus(usrId: String , result: (([[String : Any]]) -> Void)?)  {
        
        userCollection.document(usrId).collection(Constants.COLLECTION_ROLL).order(by: Constants.PURCHASED_DATE, descending: true).getDocuments { (querySnapshot, error) in
            
            var rolls = [[String:Any]]()
            
            if error == nil {
                
                if querySnapshot!.documents.isEmpty {
                    var data = [String:Any]()
                    data[Constants.COMPLETED_DATE] = nil
                    data[Constants.ROLL_NUM] = 0
                    data[Constants.CURRENT_ROLL_COUNT] = -1
                    rolls.append(data)
                    result!(rolls)
                }else{
                    var rollNum = querySnapshot!.documents.count
                    querySnapshot!.documents.forEach { (snapshot) in
                        let roll = RollModel(snapshot.data())
                        var data = [String:Any]()
                        data[Constants.COMPLETED_DATE] = roll.completedDate
                        data[Constants.ROLL_NUM] = rollNum
                        data[Constants.CURRENT_ROLL_COUNT] = roll.currentCount
                        rolls.append(data)
                        rollNum -= 1
                    }
                    result!(rolls)
                }
            }else{
                
                var data = [String:Any]()
                data[Constants.COMPLETED_DATE] = nil
                data[Constants.ROLL_NUM] = 0
                data[Constants.CURRENT_ROLL_COUNT] = -1
                rolls.append(data)
                result!(rolls)
            }
        }
    }
    
    func updateUser(data: [String:Any], success: ((Bool) -> Void)?, error: ((String) -> Void)?)  {       
        
        userCollection.document(Auth.auth().currentUser!.uid).updateData(data) { (err) in
            
            if err == nil {
                success!(true)
            }else{
                error!(err!.localizedDescription)
            }
        }
    }
    
    func updatePassword(newPassword: String, success: ((Bool) -> Void)?, error: ((String) -> Void)?)  {
        
        Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { [self] (err) in
            
            if err == nil {
                
                var data = [String:Any]()
                
                let utf8str = newPassword.data(using: .utf8)
                if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
                    
                    data[Constants.PASSWORD] = base64Encoded
                }
                
                userCollection.document(Auth.auth().currentUser!.uid).updateData(data) { (e) in
                    
                    if e == nil {
                        success!(true)
                    }else{
                        error!(e!.localizedDescription)
                    }
                }
            }else{
                error!(err!.localizedDescription)
            }
        })
        

    }
    
    func updateEmail(email: String, success: ((Bool) -> Void)?, error: ((String) -> Void)?)  {
        
        Auth.auth().currentUser?.updateEmail(to: email, completion: { [self] (err) in
            
            if err == nil {
                
                var data = [String:Any]()
                data[Constants.USER_EMAIL] = email
                
                userCollection.document(Auth.auth().currentUser!.uid).updateData(data) { (e) in
                    
                    if e == nil {
                        success!(true)
                    }else{
                        error!(e!.localizedDescription)
                    }
                }
            }else{
                error!(err!.localizedDescription)
            }
        })
        

    }
    
    
    func createRoll(_ amount: Int , result: ((Bool) -> Void)?)  {
        
        let ref: DocumentReference = userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_ROLL).document()
        
        
        var data = [String:Any]()
        data[Constants.ROLL_ID] = ref.documentID
        data[Constants.PURCHASED_DATE] = Timestamp(date: Date())
        data[Constants.COMPLETED_DATE] = nil
        data[Constants.ROLL_COUNT] = amount
        data[Constants.CURRENT_ROLL_COUNT] = 0
        
        ref.setData(data) { (err) in
            if err == nil {
                result!(true)
            }else{
                result!(false)
            }
        }
    }
    
    func updateRoll(rollId: String, data: [String:Any], success: ((Bool) -> Void)?, error: ((String) -> Void)?)  {
        
        userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_ROLL).document(rollId).updateData(data) { (err) in
            
            if err == nil {
                success!(true)
            }else{
                error!(err!.localizedDescription)
            }
        }
        
    }
    
    func completeRoll(rollId: String)  {
        
        var data = [String:Any]()
        data[Constants.COMPLETED_DATE] = Timestamp(date: Date())        
        userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_ROLL).document(rollId).setData(data, merge: true)
        
    }
    
    func getRoll(success: ((RollModel) -> Void)?, error: ((String) -> Void)?)  {
       
        userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_ROLL).order(by: Constants.PURCHASED_DATE, descending: true) .getDocuments { (snapshot, err) in
           
            if err == nil {
                var rolls = [RollModel]()
                snapshot?.documents.forEach({ (snap) in
                    
                    let roll = RollModel.init(snap.data())
                    roll.roll_num = snapshot?.documents.count
                    rolls.append(roll)
                })
                
                if rolls.isEmpty {
                    error!("no roll")
                }else{
                    success!(rolls.first!)
                }                
                
            }else{
                error!(err!.localizedDescription)
            }
        }
        
    }
    
    
    func getAllRolls(success: (([RollModel]) -> Void)?, error: ((String) -> Void)?)  {
       
        userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_ROLL).order(by: Constants.PURCHASED_DATE, descending: true) .addSnapshotListener { (snapshot, err) in
           
            if err == nil {
                var rolls = [RollModel]()
                snapshot?.documents.forEach({ (snap) in
                    
                    let roll = RollModel.init(snap.data())
                    rolls.append(roll)
                })
                
                if rolls.isEmpty {
                    error!("no roll")
                }else{
                    success!(rolls)
                }
                
            }else{
                error!(err!.localizedDescription)
            }
        }
        
    }
    
    
    
    func uploadRollImage(imageData:Data, path: String, fileName: String, onSuccess: @escaping (_ imageUrl: String, _ fileName: String) -> Void, onError:  @escaping (_ errorMessage: String?) -> Void){
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//        let path = "images/\(Auth.auth().currentUser!.uid)-\(num)-\(dateFormatter.string(from: Date()))/\(rollId)_\(num).jpeg"
        
        let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_ROOF_REF).child(path)
        
        storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if(error != nil){
                    onError(error?.localizedDescription);
                }else{
                    onSuccess((url?.absoluteString)!,fileName)
                }
            })
            
        })
        
    }
    
    func createPaymentInfo(_ paymentData: [String:Any] , result: ((Bool) -> Void)?)  {
                
        
        hasPayment { [self] (paymnetId) in
            
            userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_PAYMENT).document(paymnetId).updateData(paymentData) { (err) in
                
                if err == nil {
                    result!(true)
                }else{
                    result!(false)
                }
            }
            
        } error: { [self] (error) in
            
            let ref: DocumentReference = userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_PAYMENT).document()
            var data = paymentData
            data[Constants.PAYMENTID] = ref.documentID
            ref.setData(data) { (err) in
                if err == nil {
                    result!(true)
                }else{
                    result!(false)
                }
            }
        }

    }
    
    func hasPayment(result: ((String) -> Void)?, error: ((Bool) -> Void)?)  {
        
        userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_PAYMENT).getDocuments { (snapshot, err) in
            
            if err == nil {
                if snapshot?.count != 0 {
                    
                    let payment = PaymentModel.init(snapshot!.documents.first!.data())
                    result!(payment.paymentId!)
                }else{
                    error!(false)
                }
            }else{
                error!(false)
            }
        }
    }
    
    func getPayment(success: ((PaymentModel) -> Void)?, error: ((String) -> Void)?)  {
       
        userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_PAYMENT).getDocuments { (snapshot, err) in
            if err == nil {
                var payments = [PaymentModel]()
                snapshot?.documents.forEach({ (snap) in
                    
                    let payment = PaymentModel.init(snap.data())
                    payments.append(payment)
                })
                
                if payments.isEmpty {
                    error!("no paymentInfo")
                }else{
                    success!(payments.first!)
                }
                
            }else{
                error!(err!.localizedDescription)
            }
        }
        
    }
    
    func isApplePay(result: ((Bool) -> Void)?)  {
       
        userCollection.document(Auth.auth().currentUser!.uid).collection(Constants.COLLECTION_PAYMENT).whereField(Constants.ISAPPLEPAY, isEqualTo: true) .addSnapshotListener { (snapshot, err) in
            if err == nil {
                
                if (snapshot?.documents.count)! > 0 {
                    result!(true)
                }else{
                    result!(false)
                }
                
            }else{
                result!(false)
            }
        }
    }
}

