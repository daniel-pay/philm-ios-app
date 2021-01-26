//
//  CustomField.swift
//  CameraApp
//
//  Created by developer on 12/11/20.
//

import UIKit

class CustomField: UITextField {

    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }
    
    //common func to init our view
    private func setupView() {
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!,
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
}
