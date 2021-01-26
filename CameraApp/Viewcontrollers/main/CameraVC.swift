//
//  CameraVC.swift
//  CameraApp
//
//  Created by developer on 12/1/20.
//

import UIKit
import EasyTipView
import SwiftyGif
import AVFoundation
import MediaPlayer
import FirebaseAuth

class CameraVC: BaseViewController,AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet weak var tutorialView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var tempImgView: UIImageView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var counterView: UIView!
    @IBOutlet weak var counterBtn: UIButton!
    @IBOutlet weak var lblDate1: UILabel!
    @IBOutlet weak var lblDate2: UILabel!
    @IBOutlet weak var lblDate3: UILabel!
    @IBOutlet weak var lblDate4: UILabel!

    @IBOutlet weak var lblRollCount: UILabel!
    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var focusImgView: UIImageView!
    @IBOutlet weak var lblCapture: UILabel!
    
    enum Orientation : String {
        case Portrait = "Portrait"
        case LandscapeLeft = "LandscapeLeft"
        case LandscapeRight = "LandscapeRight"
        case UpsideDown = "UpsideDown"
    }
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var currentDevice: AVCaptureDevice!
    var preferences = EasyTipView.Preferences()
    var toastView: EasyTipView?
   
    var filterIndex = -1
    var counterTimer: Timer?
    var counter = 5
    var roll: RollModel?
    var isFlashMode = false
    var rollCount = 0
    var shutterPlayer: AVAudioPlayer?
    
    var isNoRoll = false
    var isCounter = false
    var isFilter = true
    let sender = PushNotificationSender()
    private var deviceOrientationHelper = DeviceOrientationHelper()
    var isLandscape = false
    
    var curOrientation : Orientation? = .Portrait{
        didSet {
            changeState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
        initTutorialView()
        initTipPreferences()
        checkTemDirectory()
        curOrientation = .Portrait
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getMyRoll()
        initBottomBar()
        initDateLabel()
        flashBtn.isSelected = true
        
        deviceOrientationHelper.startDeviceOrientationNotifier { (deviceOrientation) in
            self.orientationChanged(deviceOrientation: deviceOrientation)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.captureSession != nil {
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
        deviceOrientationHelper.stopDeviceOrientationNotifier()
    }
    
    private func orientationChanged(deviceOrientation: UIDeviceOrientation) {
        print(deviceOrientation.rawValue)
        isLandscape = deviceOrientation.isLandscape
        
        lblDate1.isHidden = true
        lblDate2.isHidden = true
        lblDate3.isHidden = true
        lblDate4.isHidden = true

        switch deviceOrientation.rawValue {
        case 1:
            curOrientation = .Portrait
            lblDate1.isHidden = !isFilter
            break
        case 2:
            curOrientation = .UpsideDown
            lblDate2.isHidden = !isFilter
            break
        case 3:
            curOrientation = .LandscapeLeft
            lblDate3.isHidden = !isFilter
            break
        case 4:
            curOrientation = .LandscapeRight
            lblDate4.isHidden = !isFilter
            break
        default:
            break
        }
    }
    
    private func changeState() {
        if let orientation : Orientation = curOrientation {
            
            DispatchQueue.main.async { [self] in
                switch orientation {
                case .Portrait:
                    break
                case .LandscapeLeft:
                    break
                case .LandscapeRight:
                    break
                case .UpsideDown:
                    break
                }
            }
        }
    }
    
    func checkTemDirectory(){
        
        let manager = FileManager.default
        
        if manager.checkImageFromTmp() {
            self.uploadTempImage()
        }
        
    }
    
    func initView(){        
        
        lblRollCount.text = "\(roll!.currentCount!)/\(roll!.totalCount!)"
        self.rollCount = roll!.currentCount!
        Pref.shared.setPref(.rollCount, value: self.rollCount)

    }
    
    func initDateLabel(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        lblDate1.text = dateFormatter.string(from: Date())
        lblDate2.text = dateFormatter.string(from: Date())
        lblDate3.text = dateFormatter.string(from: Date())
        lblDate4.text = dateFormatter.string(from: Date())

        self.lblDate2.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.lblDate3.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        self.lblDate4.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        
        showLabel()

    }
    
    func showLabel(){
        
        lblDate1.isHidden = true
        lblDate2.isHidden = true
        lblDate3.isHidden = true
        lblDate4.isHidden = true

        switch curOrientation {
        case .Portrait:
            lblDate1.isHidden = !isFilter
            break
        case .UpsideDown:
            lblDate2.isHidden = !isFilter
            break
        case .LandscapeLeft:
            lblDate3.isHidden = !isFilter
            break
        case .LandscapeRight:
            lblDate4.isHidden = !isFilter
            break
        default:
            break
        }
    }
    
    func initTutorialView(){
        
        self.tutorialView.isHidden = Pref.shared.isFirstRun
        
        let gif = try? UIImage(gifName: "hand.gif")
        self.gifView.setGifImage(gif!, loopCount: -1)
    }
    
    func setupSession(){
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            currentDevice = backCamera
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.cameraView.bounds
            }
        }
    }
    
    func getMyRoll(){
        
//        showHUD()
        
        FirestoreService.shared.getRoll { [self] (roll) in
            self.dismissHUD()
            self.roll = roll
            self.isNoRoll = false
            initView()
        } error: { [self] (err) in
            self.dismissHUD()
            lblRollCount.text = "20/20"
            if err == "no roll"{
                
                self.isNoRoll = true
                
                
//                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilmRollVC") as! FilmRollVC
//                vc.isFromCamera = true
//                self.navigationController?.pushViewController(vc, animated: true)

            }else{
                self.showAlert("Error", msg: err) { _ in }
            }
            
            
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        self.updateRoll()
        
        
        var image = UIImage(data: imageData)
        
        let ratioX = (image?.size.width)! / self.view.frame.width
        let ratioY = (image?.size.height)! / self.view.frame.height

        
        var point = CGPoint(x: self.lblDate1.frame.origin.x * ratioX, y: image!.size.height - ratioY * self.lblDate1.frame.height - 40)
        var fontSize = ratioX * 17
        
        switch curOrientation {
        case .Portrait:
            image = image!.cropImage(rect: CGRect(x: 0, y: 0, width: image!.size.height, height: image!.size.width))
            image = image?.imageRotatedByDegrees(degrees: 90)
            break
        case .UpsideDown:
            image = image!.cropImage(rect: CGRect(x: 0, y: 0, width: image!.size.height, height: image!.size.width))
            image = image?.imageRotatedByDegrees(degrees: 90)
            image = image?.imageRotatedByDegrees(degrees: 90)
            image = image?.imageRotatedByDegrees(degrees: 90)
            break
        case .LandscapeRight:
            image = image!.cropImage(rect: CGRect(x: 0, y: 0, width: image!.size.height, height: image!.size.width))
            point = CGPoint(x: (image?.size.width)! - self.lblDate1.frame.width * ratioX - 40, y: image!.size.height - ratioY * self.lblDate1.frame.height - 40)
            fontSize = ratioX * 17
            break
        case .LandscapeLeft:
            image = image!.cropImage(rect: CGRect(x: 0, y: 0, width: image!.size.height, height: image!.size.width))
            image = image?.imageRotatedByDegrees(degrees: 90)
            image = image?.imageRotatedByDegrees(degrees: 90)
            point = CGPoint(x: (image?.size.width)! - self.lblDate1.frame.width * ratioX - 40, y: image!.size.height - ratioY * self.lblDate1.frame.height - 40)
            fontSize = ratioX * 17
            break
        default:
            break
        }

        

        
        
        var dateStr = ""
        if isFilter {
            dateStr = self.lblDate1.text!
        }
        
        let newImage = self.textToImage(drawText: dateStr, inImage: image!, atPoint: point, fontSize: fontSize)
        let filteredData = newImage.jpegData(compressionQuality: 1.0)
        
//        UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        self.uploadPhoto(filteredData!)
        
//        let image = UIImage(data: imageData)
//        captureImageView.image = image
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
   func uploadTempImage() {
        
        var tmpImgCount = 0
        do {
            let manager = FileManager.default
            let tmpDirURL = manager.temporaryDirectory
            let tmpDirectory = try manager.contentsOfDirectory(atPath: tmpDirURL.path)
            tmpDirectory.forEach { (file) in
                
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                let fileName = fileUrl.deletingPathExtension().lastPathComponent
                
                let dirs = fileName.split(separator: "-")
                
                if dirs.count == 4 {
                    tmpImgCount += 1
                }
            }
            
            if tmpImgCount < 1 {
                return
            }
            
            
            
            tmpDirectory.forEach { (file) in
                self.indicator.isHidden = false
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                let fileName = fileUrl.deletingPathExtension().lastPathComponent
                let image = UIImage(contentsOfFile: fileUrl.path)
                
                let dirs = fileName.split(separator: "-")
                
                if dirs.count == 4 {
                    
                    let dir = "\(dirs[0])-\(dirs[1])-\(dirs[2])"
                    let name = "\(dirs[3])"
                    
                    let path = "images/\(dir)/\(name).jpeg"
                    
                    let imgData = image!.jpegData(compressionQuality: 1.0)
                    FirestoreService.shared.uploadRollImage(imageData: imgData!, path: path, fileName: fileName) { [self] (imgUrl, fName) in
                        
                        self.indicator.isHidden = true
                        let manager = FileManager.default
                        manager.deleteFromTmpDirectory(fName)
                        
                    } onError: { [self] (err) in
                        self.indicator.isHidden = true
                    }
                }else{
                    self.indicator.isHidden = true
                }
                

                
            }
         
        } catch {
           //catch the error somehow
        }

    }
    
    func uploadPhoto(_ imgData: Data){
//        showHUD()
        
        if self.rollCount > 20 {
            self.indicator.isHidden = true
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let purchasedDate = self.roll?.purchasedDate!.dateValue()

        
        let file_name = "\(Auth.auth().currentUser!.uid)-\(self.roll!.roll_num!)-\(dateFormatter.string(from: purchasedDate!))-\(self.rollCount)"
        self.saveToTemporaryDirectory(imgData: imgData, fileName: file_name)
        
        let path = "images/\(Auth.auth().currentUser!.uid)-\(self.roll!.roll_num!)-\(dateFormatter.string(from: purchasedDate!))/\(self.rollCount).jpeg"
        
        FirestoreService.shared.uploadRollImage(imageData: imgData, path: path, fileName: file_name) { [self] (imgUrl, name) in
            print(imgUrl)
            self.indicator.isHidden = true
            let manager = FileManager.default
            manager.deleteFromTmpDirectory(name)
        } onError: { [self] (err) in
            self.indicator.isHidden = true
        }

        
    }
    
    func updateRoll(){
        
        if self.rollCount == 20 {
            return
        }
        
        self.rollCount += 1
        
        if self.rollCount < 21 {
            lblRollCount.text = "\(self.rollCount)/\(roll!.totalCount!)"
        }
        self.lblCapture.text = "\(self.rollCount)"
        self.lblCapture.isHidden = false
        UIView.animate(withDuration: 0.8, delay: 0.3, options: .curveEaseIn, animations: {
            self.lblCapture.transform = CGAffineTransform.identity.scaledBy(x: 0.3, y: 0.3)
         }) { (finished) in
            self.lblCapture.isHidden = true
            self.lblCapture.transform = CGAffineTransform.identity
             
        }
        
        var data = [String:Any]()
        data[Constants.CURRENT_ROLL_COUNT] = self.rollCount
        
        FirestoreService.shared.updateRoll(rollId: self.roll!.rollId!, data: data) { (success) in
            self.dismissHUD()
            
            if data[Constants.CURRENT_ROLL_COUNT] as! Int == 20 {
                
                FirestoreService.shared.completeRoll(rollId: self.roll!.rollId!)
                
                FirestoreService.shared.getAdminUserLists { (admins) in
                    
                    admins.forEach { (admin) in
                        self.sender.sendPushNotification(to: admin.fcmToken! , title: "Roll Completed", body: "\(Pref.shared.username) completes the Roll")
                    }
                    
                } error: { (error) in
                    
                }

            }
            
        } error: { [self] (err) in
            self.dismissHUD()
            self.showAlert("Error", msg: err) { _ in }
            self.rollCount -= 1
            lblRollCount.text = "\(self.rollCount)/\(roll!.totalCount!)"
        }
    }
    
    func playCaptureSound(){
        
        let path = Bundle.main.path(forResource: "camera_shutter.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            

            shutterPlayer = try AVAudioPlayer(contentsOf: url)
            shutterPlayer?.volume = 0.0
            shutterPlayer?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    
    func startCounterTimer(){
        counter = 5
        counterView.isHidden = false
        lblCounter.text = "\(counter)"
        counterTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)

    }
    
    @objc func countDown() {
        
        if counter < 2 {
            counterView.isHidden = true
            counterTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
                self.captureRoll()
            }

        }else{
            counter -= 1
            lblCounter.text = "\(counter)"
        }
        
    }

    
    func initTipPreferences(){
        
        preferences.drawing.font = UIFont(name: "BrandonGrotesque-Light", size: 14)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor(hex: 0x000000, alpha: 0.74)!
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        preferences.drawing.arrowHeight = 0
        preferences.drawing.arrowWidth = 0
        preferences.drawing.cornerRadius = 27
        preferences.positioning.contentHInset = 30
        preferences.positioning.contentVInset = 16
    }

    func initBottomBar(){
     
        let maskLayer = CALayer()
        maskLayer.frame = bottomBar.bounds
        let circleLayer = CAShapeLayer()
       //assume the circle's radius is 150
        circleLayer.frame = CGRect(x:0 , y:0,width: bottomBar.frame.size.width,height: bottomBar.frame.size.height)
        let finalPath = UIBezierPath(roundedRect: CGRect(x:0 , y:0,width: bottomBar.frame.size.width,height: bottomBar.frame.size.height), cornerRadius: 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(x:bottomBar.center.x - 38, y:-38, width: 76, height: 76))
        finalPath.append(circlePath.reversing())
        circleLayer.path = finalPath.cgPath
        maskLayer.addSublayer(circleLayer)
        bottomBar.layer.mask = maskLayer
        topView.round(corners: [.bottomLeft,.bottomRight], cornerRadius: 16)
    }
    
    
    @IBAction func didTapFlash(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected    
        
        isFlashMode = sender.isSelected ? false : true
        
        if toastView != nil {
            toastView?.dismiss()
        }
        let message = sender.isSelected ? "Flash is now OFF" : "Flash is now ON"
        
        toastView = EasyTipView(text: message, preferences: preferences, delegate: nil)
        toastView!.show(forView: sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [unowned self] in
            toastView?.dismiss()
        }
    }
    
    @IBAction func didTapSwithCamera(_ sender: Any) {
        if captureSession == nil {
            return
        }
//        camera.switchCameraPosition()
        let currentCameraInput: AVCaptureInput = captureSession.inputs[0]
        captureSession.removeInput(currentCameraInput)
        var newCamera: AVCaptureDevice
        newCamera = AVCaptureDevice.default(for: AVMediaType.video)!

        if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
            UIView.transition(with: self.cameraView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                newCamera = self.cameraWithPosition(.front)!
            }, completion: nil)
        } else {
            UIView.transition(with: self.cameraView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                newCamera = self.cameraWithPosition(.back)!
            }, completion: nil)
        }
        do {
            try self.captureSession?.addInput(AVCaptureDeviceInput(device: newCamera))
            currentDevice = newCamera
        }
        catch {
            print("error: \(error.localizedDescription)")
        }

    }
    
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)

        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    
    @IBAction func didTapSettings(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func didTapCounter(_ sender: Any) {
        
        isCounter = !isCounter
        
        if isCounter {
            self.counterBtn.setImage(UIImage(named: "time"), for: .normal)
        }else{
            self.counterBtn.setImage(UIImage(named: "time_no"), for: .normal)
        }
        
        if toastView != nil {
            toastView?.dismiss()
        }
        let message = isCounter ? "Time Delay is now ON" : "Time Delay is now OFF"
        
        toastView = EasyTipView(text: message, preferences: preferences, delegate: nil)
        toastView!.show(forView: flashBtn)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [unowned self] in
            toastView?.dismiss()
        }
    }
    @IBAction func didTapCapture(_ sender: Any) {
        
        if self.isNoRoll {
            self.showConfirmAlert("Please Purchase a Roll", msg: "Rolls of film are required to use Philm.") { (purchase) in
                if purchase {
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilmRollVC") as! FilmRollVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return
        }
        
        
        if rollCount == 20 {
            self.showRollCompleteAlert("Roll Complete!", msg: "Please confirm your Delivery Information via Settings. If that information is complete, we will print and mail you this roll ASAP. Would you like to buy a new roll?") { (purchase) in
                if purchase {
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilmRollVC") as! FilmRollVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            return
        }

        if isCounter {
            startCounterTimer()
        }else{
            captureRoll()
        }
       
        
    }
    
    func captureRoll(){
        
        playCaptureSound()
        self.indicator.isHidden = false
        if isFlashMode {
            
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            settings.flashMode = .on
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }else{
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            settings.flashMode = .off
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    
    @IBAction func tutorialSwipe(_ sender: Any) {
        Pref.shared.setPref(.isFirstRun, value: true)
        tutorialView.isHidden = true
        
        if self.isNoRoll{
            self.showConfirmAlert("Please Purchase a Roll", msg: "Rolls of film are required to use Philm.") { (purchase) in
                if purchase {
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilmRollVC") as! FilmRollVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        

    }
    
    @IBAction func tutorialSwipe1(_ sender: Any) {
        Pref.shared.setPref(.isFirstRun, value: true)
        tutorialView.isHidden = true
        
        if self.isNoRoll{
            self.showConfirmAlert("Please Purchase a Roll", msg: "Rolls of film are required to use Philm.") { (purchase) in
                if purchase {
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilmRollVC") as! FilmRollVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func swipeCameraView(_ sender: UISwipeGestureRecognizer) {
        isFilter = !isFilter
        showLabel()

       
    }
    
    
    @IBAction func swipeCameraViewRight(_ sender: UISwipeGestureRecognizer) {
        
        isFilter = !isFilter
        showLabel()
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint, fontSize: CGFloat) -> UIImage {
        let textColor = UIColor(hex: 0xe36d12)
        let textFont = UIFont(name: "Digital-7", size: fontSize)!

        let angle: CGFloat = 0
        let size = CGSize(width: image.size.width, height: image.size.height)
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.rotate(by: angle * CGFloat.pi / 180)
        }
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor as Any,
            ] as [NSAttributedString.Key : Any]
        
    
        let rect = CGRect(origin: .zero, size: size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let rotatedImageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        rotatedImageWithText?.draw(in: CGRect(origin: point, size: size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

 
    
    @IBAction func pinchCamera(_ sender: UIPinchGestureRecognizer) {

        
        guard let device = currentDevice else {return}
        let zoom = device.videoZoomFactor * sender.scale
        sender.scale = 1.0
        let error = NSError()
        do{
            try device.lockForConfiguration()
            defer {device.unlockForConfiguration()}
            if zoom >= device.minAvailableVideoZoomFactor && zoom <= device.maxAvailableVideoZoomFactor {
                device.videoZoomFactor = zoom
            }else{
                NSLog("Unable to set videoZoom: (max %f, asked %f)", device.activeFormat.videoMaxZoomFactor, zoom);
            }
        }catch error as NSError{
            NSLog("Unable to set videoZoom: %@", error.localizedDescription);
        }catch _{
        }
    }
    
    @IBAction func tapCameraView(_ sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.location(in: self.cameraView)
        let screenSize = cameraView.bounds.size
        let focusPoint = CGPoint(x: touchPoint.y / screenSize.height, y: 1.0 - touchPoint.x / screenSize.width)

        if let device = currentDevice {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureDevice.FocusMode.autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
                }
                device.unlockForConfiguration()
                self.focusImgView.frame.origin = CGPoint(x: touchPoint.x - 32, y: touchPoint.y - 32)
                self.focusImgView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.focusImgView.isHidden = true
                })

            } catch {
                // Handle errors here
            }
        }
    }
    
}

