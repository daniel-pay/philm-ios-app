//
//  SettingsTVCell.swift
//  CameraApp
//
//  Created by developer on 12/2/20.
//

import UIKit

class SettingsTVCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var dotView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
