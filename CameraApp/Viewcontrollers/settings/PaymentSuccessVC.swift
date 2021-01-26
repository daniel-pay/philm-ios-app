//
//  PaymentSuccessVC.swift
//  CameraApp
//
//  Created by developer on 12/3/20.
//

import UIKit
import FirebaseAuth

class PaymentSuccessVC: BaseViewController {

    @IBOutlet weak var cameraBtn: UIButton!{
        didSet{
            cameraBtn.layer.borderColor = UIColor(hex: 0xE36D12)?.cgColor
            cameraBtn.layer.borderWidth = 0.4
        }
    }
    var rollId: String?
    let sender = PushNotificationSender()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.rollId != nil {
            var data = [String:Any]()
            data[Constants.CURRENT_ROLL_COUNT] = 20
            self.showHUD()
            FirestoreService.shared.updateRoll(rollId: self.rollId!, data: data) { (success) in
                self.dismissHUD()
                FirestoreService.shared.completeRoll(rollId: self.rollId!)
                FirestoreService.shared.getAdminUserLists { (admins) in                    
                    admins.forEach { (admin) in
                        self.sender.sendPushNotification(to: admin.fcmToken! , title: "Roll Completed", body: "\(Pref.shared.username) completes the Roll")
                    }
                    
                } error: { (error) in
                    
                }
                
            } error: { (err) in
                self.dismissHUD()
                self.showAlert("Error", msg: err) { _ in }
            }
        }
        

    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.viewControllers.forEach({ (vc) in
            if vc is FilmRollVC {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        })
    }

    @IBAction func didTapReturn(_ sender: Any) {
        
        self.navigationController?.viewControllers.forEach({ (vc) in
            if vc is FilmRollVC {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        })
        
        
    }
    
    @IBAction func didTapCamera(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
