//
//  TutorialVC.swift
//  CameraApp
//
//  Created by developer on 12/16/20.
//

import UIKit

protocol TutorialVCDelegate {
    func next()
}

class TutorialVC: UIViewController {

    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    var delegate: TutorialVCDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()


        let firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(hex: 0xE36D12)!, NSAttributedString.Key.font: UIFont(name: "BrandonGrotesque-Bold", size: 29)!]
        let secondAttributes = [.foregroundColor: UIColor(hex: 0xE36D12)!, NSAttributedString.Key.font: UIFont(name: "Digital-7", size: 40)!]

        let firstString = NSMutableAttributedString(string: "Welcome to ", attributes: firstAttributes)
        let secondString = NSAttributedString(string: "Philm",attributes: secondAttributes)

        firstString.append(secondString)
        self.lblTitle.attributedText = firstString
        
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapNext(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.next()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
