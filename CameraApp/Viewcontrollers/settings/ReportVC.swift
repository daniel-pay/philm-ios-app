//
//  ExportVC.swift
//  CameraApp
//
//  Created by developer on 1/5/21.
//

import UIKit
import SwiftCSVExport
import WebKit
import LGButton
import CRNotifications
import FirebaseFirestore

class ReportVC: BaseViewController {

    @IBOutlet weak var lblReport1: UILabel!
    @IBOutlet weak var lblReport2: UILabel!
    @IBOutlet weak var lblReport3: UILabel!
    @IBOutlet weak var reportBtn1: LGButton!
    @IBOutlet weak var reportBtn2: LGButton!
    @IBOutlet weak var reportBtn3: LGButton!
    @IBOutlet weak var shareBtn1: UIButton!
    @IBOutlet weak var shareBtn2: UIButton!
    @IBOutlet weak var shareBtn3: UIButton!
    
    var userList = [User]()
    var currentIndex = 0
    var filePath1 = ""
    var filePath2 = ""
    var filePath3 = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        getUserData()
    }
    
    func getUserData(){
        showHUD()
        FirestoreService.shared.getUserLists { [self] (users) in
            self.dismissHUD()
            self.userList.removeAll()
            users.forEach { (user) in
                if user.userId != nil {
                    self.userList.append(user)
                }
            }            
        } error: { (err) in
            self.dismissHUD()
            self.showAlert("Error", msg: err) { _ in }
        }
    }
    
    func createPhotoCountsReport(user: User){
        
        FirestoreService.shared.getCompletePhotoCount(usrId: user.userId!) { [self] (count) in
            
            self.userList[currentIndex].photoCount = count
            currentIndex += 1
            if currentIndex == self.userList.count {
                createPhotoCountCSV()
            }else{
                self.createPhotoCountsReport(user: self.userList[currentIndex])
            }
        }
    }
    
    
    func createRollStatusReport(user: User){
        
        FirestoreService.shared.getCompleteRollStatus(usrId: user.userId!) { [self] (data) in
            
            self.userList[currentIndex].rolls = data
            
//            self.userList[currentIndex].isCompleted = data[Constants.COMPLETED_DATE] != nil
//            self.userList[currentIndex].rollNum = data[Constants.ROLL_NUM] as! Int
//
//            if data[Constants.COMPLETED_DATE] != nil {
//                self.userList[currentIndex].completedDate = data[Constants.COMPLETED_DATE] as? Timestamp
//            }
            
            currentIndex += 1
            if currentIndex == self.userList.count {
                createRollStatusCSV()
            }else{
                self.createRollStatusReport(user: self.userList[currentIndex])
            }
        }
    }
    
    func createPhotoCountCSV(){
        
        let exportData:NSMutableArray  = NSMutableArray()
        
        var no = 0
        self.userList.forEach { (user) in
            no += 1
            let data:NSMutableDictionary = NSMutableDictionary()
            data.setObject(no, forKey: "No" as NSCopying)
            data.setObject(user.userId!.replacingOccurrences(of: ",", with: ""), forKey: "userID" as NSCopying)
            data.setObject(user.name!.replacingOccurrences(of: ",", with: ""), forKey: "Name" as NSCopying)
            data.setObject(user.photoCount < 0 ? "No Roll" : "\(user.photoCount)", forKey: "Photos" as NSCopying)
            exportData.add(data)
        }
        
        let header = ["No","userID", "Name", "Photos"]
        // Create a object for write CSV
        let writeCSVObj = CSV()
        writeCSVObj.rows = exportData
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = "PhotoCountsReport"
        
        // Write File using CSV class object
        let output = CSVExport.export(writeCSVObj);
        print(CSVExport.export.directory)
        self.dismissHUD()
        if output.result.isSuccess {
            guard let filePath =  output.filePath else {
                print("Export Error: \(String(describing: output.message))")
                return
            }
            self.filePath1 = filePath
            CRNotifications.showNotification(textColor: .white, backgroundColor: UIColor(hex: 0x3A3A3E)!, image: UIImage(named: "success"), title: "Success!", message: "PhotoCountsReport created!", dismissDelay: 2.0)
            
            reportBtn1.borderColor = UIColor(hex: 0xE36D12)!
            lblReport1.textColor = UIColor(hex: 0xE36D12)!
            reportBtn1.leftImageColor = UIColor(hex: 0xE36D12)!
            shareBtn1.isEnabled = true
            print("File Path: \(filePath)")
        } else {
            print("Export Error: \(String(describing: output.message))")
            reportBtn1.borderColor = .white
            lblReport1.textColor = .white
            reportBtn1.leftImageColor = .white
            shareBtn1.isEnabled = false
        }
    }
    
    func createFulfillmentCSV(){
        
        let exportData:NSMutableArray  = NSMutableArray()
        var no = 0
        self.userList.forEach { (user) in
            no += 1
            let data:NSMutableDictionary = NSMutableDictionary()
            
            var deliveryAddress = ""
            
            if !user.address1!.isEmpty {
                if user.address2!.isEmpty {
                    deliveryAddress = "\(user.address1!) \(user.city!) \(user.state!) \(user.zipcode!)"
                }else{
                    deliveryAddress = "\(user.address1!) \(user.address2!) \(user.city!) \(user.state!) \(user.zipcode!)"
                }
                deliveryAddress = deliveryAddress.replacingOccurrences(of: ",", with: "")
            }
            data.setObject(no, forKey: "No" as NSCopying)
            data.setObject(user.userId!.replacingOccurrences(of: ",", with: ""), forKey: "userID" as NSCopying)
            data.setObject(user.email!.replacingOccurrences(of: ",", with: ""), forKey: "Email" as NSCopying)
            data.setObject(user.name!.replacingOccurrences(of: ",", with: ""), forKey: "Name" as NSCopying)
            data.setObject(deliveryAddress, forKey:"Delivery Address" as NSCopying)
            
            exportData.add(data)
        }
        
        let header = ["No","userID", "Email","Name","Delivery Address"]
        // Create a object for write CSV
        let writeCSVObj = CSV()
        writeCSVObj.rows = exportData
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = "FulfillmentReport"
        
        // Write File using CSV class object
        let output = CSVExport.export(writeCSVObj);
        print(CSVExport.export.directory)
        self.dismissHUD()
        if output.result.isSuccess {
            guard let filePath =  output.filePath else {
                print("Export Error: \(String(describing: output.message))")
                return
            }
            self.filePath2 = filePath
            print("File Path: \(filePath)")
            CRNotifications.showNotification(textColor: .white, backgroundColor: UIColor(hex: 0x3A3A3E)!, image: UIImage(named: "success"), title: "Success!", message: "FulfillmentReport created!", dismissDelay: 2.0)
            reportBtn2.borderColor = UIColor(hex: 0xE36D12)!
            lblReport2.textColor = UIColor(hex: 0xE36D12)!
            reportBtn2.leftImageColor = UIColor(hex: 0xE36D12)!
            shareBtn2.isEnabled = true
        } else {
            print("Export Error: \(String(describing: output.message))")
            reportBtn2.borderColor = .white
            lblReport2.textColor = .white
            reportBtn2.leftImageColor = .white
            shareBtn2.isEnabled = false
        }
    }
    
    func createRollStatusCSV(){
        
        let exportData:NSMutableArray  = NSMutableArray()
        var no = 0
        self.userList.forEach { (user) in
            
            var deliveryAddress = ""
            
            if !user.address1!.isEmpty {
                if user.address2!.isEmpty {
                    deliveryAddress = "\(user.address1!) \(user.city!) \(user.state!) \(user.zipcode!)"
                }else{
                    deliveryAddress = "\(user.address1!) \(user.address2!) \(user.city!) \(user.state!) \(user.zipcode!)"
                }
                deliveryAddress = deliveryAddress.replacingOccurrences(of: ",", with: "")
            }
            
            user.rolls.forEach { (roll) in
                no += 1
                let data:NSMutableDictionary = NSMutableDictionary()

                
                var completedDateStr = ""
                var isRollCompleted = false
                
                if roll[Constants.COMPLETED_DATE] as? Timestamp != nil {
                    let completedDate = (roll[Constants.COMPLETED_DATE] as? Timestamp)!.dateValue()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    completedDateStr = formatter.string(from: completedDate)
                    isRollCompleted = true
                }
                
                let rollNum = roll[Constants.ROLL_NUM] as? Int
                let photoCount = roll[Constants.CURRENT_ROLL_COUNT] as? Int
                
                data.setObject(no, forKey: "No" as NSCopying)
                data.setObject(user.userId!.replacingOccurrences(of: ",", with: ""), forKey: "userID" as NSCopying);
                data.setObject(user.name!.replacingOccurrences(of: ",", with: ""), forKey: "Name" as NSCopying);
                data.setObject(deliveryAddress, forKey:"Delivery Address" as NSCopying)
                data.setObject(rollNum! > 0 ? "\(rollNum!)" : "", forKey:"Roll Number" as NSCopying)
                data.setObject(photoCount! > -1 ? "\(photoCount!)" : "", forKey:"Photo Counts" as NSCopying)
                data.setObject(isRollCompleted ? "YES" : "NO", forKey:"Roll Completed" as NSCopying)
                data.setObject(completedDateStr, forKey:"Completed Date" as NSCopying)
                
                exportData.add(data)
            }
            
        }
        
        let header = ["No","userID", "Name","Delivery Address","Roll Number","Photo Counts","Roll Completed","Completed Date"]
        // Create a object for write CSV
        let writeCSVObj = CSV()
        writeCSVObj.rows = exportData
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = "RollStatusReport"
        
        
        // Write File using CSV class object
        let output = CSVExport.export(writeCSVObj);
        print(CSVExport.export.directory)
        self.dismissHUD()
        if output.result.isSuccess {
            guard let filePath =  output.filePath else {
                print("Export Error: \(String(describing: output.message))")
                return
            }
            self.filePath3 = filePath
            print("File Path: \(filePath)")
            CRNotifications.showNotification(textColor: .white, backgroundColor: UIColor(hex: 0x3A3A3E)!, image: UIImage(named: "success"), title: "Success!", message: "RollStatusReport created!", dismissDelay: 2.0)
            reportBtn3.borderColor = UIColor(hex: 0xE36D12)!
            lblReport3.textColor = UIColor(hex: 0xE36D12)!
            reportBtn3.leftImageColor = UIColor(hex: 0xE36D12)!
            shareBtn3.isEnabled = true
        } else {
            print("Export Error: \(String(describing: output.message))")
            reportBtn3.borderColor = .white
            lblReport3.textColor = .white
            reportBtn3.leftImageColor = .white
            shareBtn3.isEnabled = false
        }
    }
    
    func initUserList(){
        
        self.userList.forEach { (user) in
            user.isCompleted = false
            user.photoCount = -1
            user.rollNum = 0
            user.completedDate = nil
            user.rolls = []
        }
    }

    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
//    @IBAction func didTapShare(_ sender: Any) {
//
//        if filePath.isEmpty {
//            return
//        }
//
//        let items = [URL(fileURLWithPath: filePath) as URL] as [Any]
//        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//        ac.modalPresentationStyle = .fullScreen
//        present(ac, animated: true)
//    }

    
    @IBAction func didTapReport1(_ sender: Any) {
        currentIndex = 0
        initUserList()
        showHUD()
        self.createPhotoCountsReport(user: self.userList[currentIndex])
    }
    
    @IBAction func didTapReport2(_ sender: Any) {
        
        currentIndex = 0
        initUserList()
        showHUD()
        self.createFulfillmentCSV()
    }
    
    @IBAction func didTapReport3(_ sender: Any) {
        currentIndex = 0
        initUserList()
        showHUD()
        self.createRollStatusReport(user: self.userList[currentIndex])
    }
    
    @IBAction func didTapShare1(_ sender: Any) {
        
        if filePath1.isEmpty {
            return
        }
        shareCSV(filePath: filePath1)

    }
    
    @IBAction func didTapShare2(_ sender: Any) {
        
        if filePath2.isEmpty {
            return
        }
        shareCSV(filePath: filePath2)

    }
    
    @IBAction func didTapShare3(_ sender: Any) {
        
        if filePath3.isEmpty {
            return
        }

        shareCSV(filePath: filePath3)

    }
    
    func shareCSV(filePath: String){
        let items = [URL(fileURLWithPath: filePath) as URL] as [Any]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.modalPresentationStyle = .fullScreen
        present(ac, animated: true)
    }
}

