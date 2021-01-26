//
//  ResetLinkVC.swift
//  CameraApp
//
//  Created by developer on 12/1/20.
//

import UIKit

class ResetLinkVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func didTapReturnHome(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
