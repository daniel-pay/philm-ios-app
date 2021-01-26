//
//  RollModel.swift
//  CameraApp
//
//  Created by developer on 12/4/20.
//

import UIKit
import FirebaseFirestore

class RollModel: Equatable {
    static func == (lhs: RollModel, rhs: RollModel) -> Bool {
        return lhs.rollId == rhs.rollId
    }
    
    
    var rollId: String?
    var totalCount: Int?
    var currentCount: Int?
    var purchasedDate: Timestamp?
    var completedDate: Timestamp?
    var roll_num: Int?

    
    init(_ json: [String: Any]) {
        rollId = json[Constants.ROLL_ID] as? String
        totalCount = json[Constants.ROLL_COUNT] as? Int ?? 0
        currentCount = json[Constants.CURRENT_ROLL_COUNT] as? Int ?? 0
        purchasedDate = json[Constants.PURCHASED_DATE] as? Timestamp
        completedDate = json[Constants.COMPLETED_DATE] as? Timestamp
    }
   
}
