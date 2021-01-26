//
//  RollTVCell.swift
//  CameraApp
//
//  Created by developer on 12/2/20.
//

import UIKit

class RollTVCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPurchased: UILabel!
    @IBOutlet weak var lblCompleted: UILabel!
    @IBOutlet weak var lblRollCount: UILabel!
    
    var roll: RollModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(_ roll: RollModel){
        self.roll = roll
        let purchasedDate = self.roll?.purchasedDate!.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        self.lblPurchased.text = formatter.string(from: purchasedDate!)
        
        if let completedDate = self.roll?.completedDate?.dateValue() {
            self.lblCompleted.text = formatter.string(from: completedDate)
        }else{
            self.lblCompleted.text = ""
        }
        
        lblRollCount.text = "\(self.roll!.currentCount!)/\(self.roll!.totalCount!)"
    }

}
