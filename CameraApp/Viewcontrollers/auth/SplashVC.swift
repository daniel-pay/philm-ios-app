//
//  SplashVC.swift
//  CameraApp
//
//  Created by developer on 12/1/20.
//

import UIKit
import FirebaseAuth

class SplashVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
            
            if Auth.auth().currentUser != nil && !Pref.shared.uid.isEmpty {                
                
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
                self.view.window?.rootViewController = vc

            }else{
                let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "AuthNav")
                self.view.window?.rootViewController = vc
            }
        }
    }

}
