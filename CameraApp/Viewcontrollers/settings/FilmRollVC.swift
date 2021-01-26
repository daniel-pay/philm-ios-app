//
//  FilmRollVC.swift
//  CameraApp
//
//  Created by developer on 12/2/20.
//

import UIKit

class FilmRollVC: BaseViewController {

    @IBOutlet weak var cameraBtn: UIButton!{
        didSet{
            cameraBtn.layer.borderColor = UIColor(hex: 0xE36D12)?.cgColor
            cameraBtn.layer.borderWidth = 0.4
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    var rolls = [RollModel]()
    var isFromCamera = false
    override func viewDidLoad() {
        super.viewDidLoad()

        getMyRoll()
        
        if isFromCamera {
            showErrorAlert()
        }
    }
    
    func getMyRoll(){
        
        showHUD()
        
        FirestoreService.shared.getAllRolls { [self] (rolls) in
            self.dismissHUD()
            self.rolls = rolls
            self.tableView.reloadData()
        } error: { (err) in
            self.dismissHUD()
            
            if err == "no roll"{
                
            }else{
                self.showAlert("Error", msg: err) { _ in }
            }
            
            
        }
    }
    
    func showErrorAlert(){
        isFromCamera = false
//        self.showConfirmAlert("Warning", msg: "Please Purchase a Roll. Rolls of film are required to use Philm") { (purchase) in
//            if purchase {
//                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyRollVC") as! BuyRollVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }
    

    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapBuy(_ sender: Any) {
        
        if rolls.count == 0 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyRollVC") as! BuyRollVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if rolls.first!.currentCount! < 20 {
            
            self.showNewPurchaseAlert("Wait!", msg: "You haven't finished your current roll. If you buy a new one, your current roll will be completed.") { (success) in
                
                if success {
                    
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyRollVC") as! BuyRollVC
                    vc.rollId = self.rolls.first!.rollId!
                    self.navigationController?.pushViewController(vc, animated: true)

                }
            }
        }else{
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyRollVC") as! BuyRollVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        

    }
    
    @IBAction func didTapCamera(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}

extension FilmRollVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rolls.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RollTVCell", for: indexPath) as! RollTVCell
        cell.initCell(self.rolls[indexPath.row])
        cell.lblTitle.text = "Roll \(self.rolls.count - indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
    }
}
