//
//  BuyRollVC.swift
//  CameraApp
//
//  Created by developer on 12/2/20.
//

import UIKit

class BuyRollVC: BaseViewController {

    @IBOutlet weak var cameraBtn: UIButton!{
        didSet{
            cameraBtn.layer.borderColor = UIColor(hex: 0xE36D12)?.cgColor
            cameraBtn.layer.borderWidth = 0.4
        }
    }
    @IBOutlet weak var dropDown1: DropDown!{
        didSet{
            dropDown1.attributedPlaceholder = NSAttributedString(string: "Select option here",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            dropDown1.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: dropDown1.frame.height))
            dropDown1.leftViewMode = .always
        }
    }
    
    @IBOutlet weak var dropDown2: DropDown!{
        didSet{
            dropDown2.attributedPlaceholder = NSAttributedString(string: "Select option here",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            dropDown2.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: dropDown2.frame.height))
            dropDown2.leftViewMode = .always
        }
    }
    
    @IBOutlet weak var dropDown3: DropDown!{
        didSet{
            dropDown3.attributedPlaceholder = NSAttributedString(string: "Select option here",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            dropDown3.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: dropDown3.frame.height))
            dropDown3.leftViewMode = .always
        }
    }
    
    let options = ["Option1","Option2","Option3","Option4","Option5"]
    let values: [Float] = [3.0,5.3,2.6,10.5,5.0]
    var rollId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        initDropDown()
    }
    

    func initDropDown(){
        dropDown1.optionArray = options
        dropDown1.valueDataArray = values
        dropDown1.selectedIndex = 0
       
        dropDown1.didSelect { (unit, index, id) in
            
        }
        
        dropDown2.optionArray = options
        dropDown2.valueDataArray = values
        dropDown2.selectedIndex = 0
       
        dropDown2.didSelect { (unit, index, id) in
            
        }
        
        dropDown3.optionArray = options
        dropDown3.valueDataArray = values
        dropDown3.selectedIndex = 0
       
        dropDown3.didSelect { (unit, index, id) in
            
        }
    }

    @IBAction func didTapBuy(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentMethodVC") as! PaymentMethodVC
        vc.rollId = self.rollId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapCamera(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
