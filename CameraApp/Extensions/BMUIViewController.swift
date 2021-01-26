//
//

import UIKit
import Photos
import SVProgressHUD

extension UIViewController {
    
    
    func showHUD(){
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
            SVProgressHUD.show()
        }
    }
    
  
    func dismissHUD(){
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    public func displayError(_ error: Error?, from function: StaticString = #function) {
          self.dismissHUD()
          guard let error = error else { return }
          print("ⓧ Error in \(function): \(error.localizedDescription)")
          let message = "\(error.localizedDescription)\n\n Ocurred in \(function)"
          let errorAlertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
          )
          errorAlertController.addAction(UIAlertAction(title: "OK", style: .default))
          present(errorAlertController, animated: true, completion: nil)
    }
    
    func isValidEmail(email:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidPhone(phoneNumber: String) -> Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  phoneNumber == filtered
    }
    
    func checkUpercase(text : String) -> Bool{
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: text)
        
        return capitalresult
    }
    
    func checkLowercase(text : String) -> Bool{
        
        let capitalLetterRegEx  = ".*[a-z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: text)
        
        return capitalresult
    }
    
    func appDelegate() -> AppDelegate {
        return (UIApplication.shared.delegate as? AppDelegate)!
    }
    
    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
        
        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }
        
        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }
        
        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
            
        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }
        
        return number
    }
    
   
    
    func showAlert(_ title: String, msg: String, completion: @escaping (_ ok: Bool) -> Void) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            completion(true)
        }))
        self.present(alert, animated: true)
    }
    
    func showConfirmAlert(_ title: String, msg: String, completion: @escaping (_ ok: Bool) -> Void) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Purchase", style: .default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showRollCompleteAlert(_ title: String, msg: String, completion: @escaping (_ ok: Bool) -> Void) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "New Roll", style: .default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showUpdateAlert(_ title: String, msg: String, completion: @escaping (_ ok: Bool) -> Void) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Never Mind", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }   

    func showNewPurchaseAlert(_ title: String, msg: String, completion: @escaping (_ ok: Bool) -> Void) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Buy New", style: .default, handler: { (action) in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    public func saveToTemporaryDirectory(imgData: Data, fileName: String)
    {
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(fileName, isDirectory: false)
            .appendingPathExtension("jpeg")

        do {
            try imgData.write(to: url)
        } catch {
            print("Handle the error, i.e. disk can be full")
        }
    }
}



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}

extension UIView {
    
    func fadeIn() {
        // Move our fade out code from earlier
        self.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
        }, completion: nil)
    }
    
    func fadeOut() {
        // Move our fade out code from earlier
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
            self.isHidden = true
        }, completion: nil)
    }
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension Array {
    func removingDuplicates<T: Equatable>(byKey key: KeyPath<Element, T>)  -> [Element] {
        var result = [Element]()
        var seen = [T]()
        for value in self {
            let key = value[keyPath: key]
            if !seen.contains(key) {
                seen.append(key)
                result.append(value)
            }
        }
        return result
    }

}

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}


extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}


extension Date {
    
    /// Returns the amount of days from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    /// Returns the amount of days from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    /// Returns the amount of days from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    func offsetFrom(date : Date) -> [Int] {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.year,.month,.weekOfYear,.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        var hour = hours(from: Date())
        var min = minutes(from:Date())
        var sec = seconds(from:Date())
        var week = weeks(from:Date())
        var month = months(from:Date())
        var year = years(from:Date())
        
        _ = hours(from: date) - hour
        _ = minutes(from:date) - min
        _ = seconds(from:date) - sec
        
        let days = abs(difference.day!)
        week = abs(difference.weekOfYear!)
        month = abs(difference.month!)
        year = abs(difference.year!)
        hour = abs(difference.hour!) % 24
        min = abs(difference.minute!) % (24 * 60)
        sec = abs(difference.second!) % (24 * 60 * 60)
        
        
        
        return [year,month,week,days,hour,min,sec]
    }
    
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    var isInTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    var isInTheFuture: Bool {
        return Date() < self
    }
    var isInThePast: Bool {
        return self < Date()
    }
    
    func getWeekDates() -> (thisWeek:[Date],nextWeek:[Date]) {
        var tuple: (thisWeek:[Date],nextWeek:[Date])
        var arrThisWeek: [Date] = []
        for i in 0..<7 {
            arrThisWeek.append(Calendar.current.date(byAdding: .day, value: i, to: startOfWeek)!)
        }
        var arrNextWeek: [Date] = []
        for i in 1...7 {
            arrNextWeek.append(Calendar.current.date(byAdding: .day, value: i, to: arrThisWeek.last!)!)
        }
        tuple = (thisWeek: arrThisWeek,nextWeek: arrNextWeek)
        return tuple
    }
    
    var startOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 1, to: sunday!)!
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
        
}

extension UITableView {
    
    func scrollToBottom(){
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}


extension UILabel {
    
    func setLineHeight(lineHeight: CGFloat) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            
            style.lineSpacing = lineHeight
            attributeString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, text.count))
            self.attributedText = attributeString
        }
    }
}

extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

extension FileManager {
    func deleteFromTmpDirectory(_ name: String) {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                let fileName = fileUrl.deletingPathExtension().lastPathComponent
                
                if fileName == name {
                    try removeItem(atPath: fileUrl.path)
                }                
                
            }
        } catch {
           //catch the error somehow
        }
    }
    
    func clearFromTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
                
            }
        } catch {
           //catch the error somehow
        }
    }
    
    func checkImageFromTmp() -> Bool{
        
        let tmpDirURL = FileManager.default.temporaryDirectory
        let tmpDirectory = try! contentsOfDirectory(atPath: tmpDirURL.path)
        return tmpDirectory.count > 0
    }
}


extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
    
    func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
       let rotatedSize: CGSize = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width).size

       //Create the bitmap context
       UIGraphicsBeginImageContext(rotatedSize)
       let bitmap: CGContext = UIGraphicsGetCurrentContext()!
       //Move the origin to the middle of the image so we will rotate and scale around the center.
       bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
       //Rotate the image context
       bitmap.rotate(by: (degrees * CGFloat.pi / 180))
       //Now, draw the rotated/scaled image into the context
       bitmap.scaleBy(x: 1.0, y: -1.0)
       bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))

       let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

       UIGraphicsEndImageContext()
       return newImage
    }
    
    func cropped(boundingBox: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: boundingBox) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
    
    func cropImage(rect: CGRect) -> UIImage {
        let cgImage = self.cgImage! // better to write "guard" in realm app
        let croppedCGImage = cgImage.cropping(to: rect)
        return UIImage(cgImage: croppedCGImage!)
    }
}

