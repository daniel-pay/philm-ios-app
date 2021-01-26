

import Foundation
import FirebaseAuth

class AuthService {  
    
  
    static let shared = AuthService()
    
    var user: User?
    private init() {}
    
    
    func signup(email: String, password: String, success: ((Bool) -> Void)?, error: ((String) -> Void)?)  {

        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if err == nil{
                
                success!(true)
                
            }else{
                error!(err!.localizedDescription)
            }
        }
     }
    
    
    func createUser(email: String, password: String,username: String, success: ((User) -> Void)?, error: ((String) -> Void)?)  {

        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if err == nil{
                
//                FirestoreService.shared.createUser(email: email, username: username, success: { (user) in
//                    self.user = user
//                    success!(user)
//                }, error: { (err) in
//                    error!(err)
//                })
                
            }else{
                error!(err!.localizedDescription)
            }
        }
     }
    
    func signIn(email: String, password: String,success: ((User) -> Void)?, error: ((String) -> Void)?)  {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            
            if err == nil {
                
                FirestoreService.shared.isExistUser(uid: result!.user.uid) { (_) in
                    
                    if result!.user.isEmailVerified {
                        FirestoreService.shared.getCurrentUser(success: { (user) in
                            self.user = user
                            success!(user)
                        }, error: { (_err) in
                            error!(_err)
                        })
                    }else{
                        error!("The email was not verified.")
                    }
                    
                } error: { (err1) in
                    
                    error!(err1)
                }

            }else{
                error!(err!.localizedDescription)
            }
        }
    }
    
    func resetPassword(email: String,success: ((String) -> Void)?, error: ((String) -> Void)?)  {
        
        Auth.auth().sendPasswordReset(withEmail: email) { err in
            if err == nil {
                success!("Success")
            }else{
                error!(err!.localizedDescription)
            }
        }
    }

    
    func signout()  {
        try! Auth.auth().signOut()        
    }

}
