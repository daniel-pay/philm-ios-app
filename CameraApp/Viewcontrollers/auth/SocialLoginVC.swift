//
//  SocialLoginVC.swift
//  CameraApp
//
//  Created by developer on 12/1/20.
//

import UIKit
import AuthenticationServices

protocol SocialLoginVCDelegate {
    func googleSign()
    func facebookSign()
    func appleSign()
}

class SocialLoginVC: UIViewController {
    @IBOutlet weak var btnGoogle: UIButton!{
        didSet{
            btnGoogle.layer.borderWidth = 1.6
            btnGoogle.layer.borderColor = UIColor.init(white: 1, alpha: 0.1).cgColor
        }
    }
    
    @IBOutlet weak var btnFacebook: UIButton!{
        didSet{
            btnFacebook.layer.borderWidth = 1.6
            btnFacebook.layer.borderColor = UIColor.init(white: 1, alpha: 0.1).cgColor
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    
    var delegate: SocialLoginVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        stackView.addArrangedSubview(authorizationButton)
    }
    

    @IBAction func didTapGoogleSign(_ sender: Any) {
        
        delegate?.googleSign()

    }
    
    @IBAction func didTapFacebookSign(_ sender: Any) {
        delegate?.facebookSign()
    }
    
    @objc private func handleLogInWithAppleIDButtonPress() {
        
        delegate?.appleSign()
    }
    
}


