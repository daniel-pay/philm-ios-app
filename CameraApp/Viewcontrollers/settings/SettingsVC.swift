//
//  SettingsVC.swift
//  CameraApp
//
//  Created by developer on 12/2/20.
//

import UIKit
import FirebaseAuth
import MessageUI

class SettingsVC: BaseViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var images = [UIImage(named: "ic_user"),UIImage(named: "ic_payment"),UIImage(named: "ic_delivery"),UIImage(named: "ic_order_history"),UIImage(named: "ic_logout")]
    var titles = ["Account Information","Payment Information","Delivery Information","Philm Rolls","Log Out"]
    var isApplePay = false
    var isAdmin = false
    var isMissingInfo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.hasApplePay()
        self.getUser()
    }
    
    func getUser(){
        FirestoreService.shared.getCurrentUser { [self] (user) in
            
            self.isMissingInfo = user.name!.isEmpty || user.address1!.isEmpty || user.city!.isEmpty || user.state!.isEmpty || user.zipcode!.isEmpty

            if user.admin! && titles[4] != "Reports"{
                images.insert(UIImage(named: "export"), at: 4)
                titles.insert("Reports", at: 4)
                isAdmin = true
            }
            tableView.reloadData()
            
            
        } error: { (err) in
        }

    }
    
    func hasApplePay(){
        
        FirestoreService.shared.isApplePay { (isApplePay) in
            self.isApplePay = isApplePay
        }
    }


    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
       
    }
    
}

extension SettingsVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTVCell", for: indexPath) as! SettingsTVCell
        cell.lblTitle.text = titles[indexPath.row]
        cell.imgView.image = images[indexPath.row]
        
        if indexPath.row == 2 {
            cell.dotView.isHidden = !isMissingInfo
        }else{
            cell.dotView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isAdmin {
            switch indexPath.row {
            case 0:
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountInfoVC") as! AccountInfoVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                
                if !isApplePay {
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentInfoVC") as! PaymentInfoVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case 2:
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryInfoVC") as! DeliveryInfoVC
                self.navigationController?.pushViewController(vc, animated: true)

            case 3:
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilmRollVC") as! FilmRollVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 4:
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 5:
                
                let alert = UIAlertController(title: "Log Out", message: "Are you sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (action) in
                    
                    do {
                        try Auth.auth().signOut()
                        Pref.shared.setPref(.uid, value: "")
                        let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "AuthNav")
                        self.view.window?.rootViewController = vc
                    } catch {
                        print(error)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                }))
                self.present(alert, animated: true)

            default:
                break
            }
            
        }else{
            switch indexPath.row {
            case 0:
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountInfoVC") as! AccountInfoVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                
                if !isApplePay {
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentInfoVC") as! PaymentInfoVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case 2:
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliveryInfoVC") as! DeliveryInfoVC
                self.navigationController?.pushViewController(vc, animated: true)

            case 3:
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilmRollVC") as! FilmRollVC
                self.navigationController?.pushViewController(vc, animated: true)
            case 4:
                
                let alert = UIAlertController(title: "Log Out", message: "Are you sure?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { (action) in
                    
                    do {
                        try Auth.auth().signOut()
                        Pref.shared.setPref(.uid, value: "")
                        let vc = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "AuthNav")
                        self.view.window?.rootViewController = vc
                    } catch {
                        print(error)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                }))
                self.present(alert, animated: true)

            default:
                break
            }
            
        }
        
        
        
    }
}


