//
//  QRScannerController.swift
//  Djinaro
//
//  Created by Azat on 23.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


struct QRReceiptDocument: Codable {
    var type: String
    var id: Int

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case id = "Id"
    }
    
}

protocol SpyDelegate: class {
    func getFrontInventoryShop(url: String)
}



class QRScannerController: UIViewController, InventoryCellTapped {

    @IBAction func lightButton(_ sender: Any) {
        if togleON {
            toggleTorch(on: false)
            togleON = false
        } else {
            toggleTorch(on: true)
            togleON = true
        }
        
    }
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var lightButton: UIButton!
    @IBAction func inventotyRegimeButton(_ sender: Any) {
        
        
        if needInventory == false && frontInventory == false {
            inventoryType(title: "Выберите режим инвентаризации")
            InventoryButtonOutlet.tintColor = .red
        } else {
            needInventory = false
            frontInventory = false
            InventoryButtonOutlet.tintColor = .blue
            self.view.sendSubviewToBack(viewGoodsTable)
        }
        
    }
    
    @IBOutlet var InventoryButtonOutlet: UIBarButtonItem!
    @IBOutlet var viewGoodsTable: UIView!
    
    
    var captureSession = AVCaptureSession()
    var checkRecord: CheckRecord?
    
    // Переменные для инвентаризации
    var needInventory = false
    var frontInventory = false
    var frontURL = ""
    var tableInventory = InventoryViewController()
    weak var delegate : SpyDelegate?
    
    // Переменные найденного QR илил BAR
    var found_bar = 0
    var found_text = ""
    var full_found_text = "'"
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var togleON = false
    
    var receiptController = ReceiptController(useMultiUrl: true)
    var qrReceiptDocument: QRReceiptDocument?
    var token = ""
    var userId = ""
    let defaults = UserDefaults.standard
    
    var objPlayer: AVAudioPlayer?
    
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession.startRunning()
        needInventory = false
        //frontInventory = false
        //InventoryButtonOutlet.tintColor = .blue
        //self.view.sendSubviewToBack(viewGoodsTable)
        found_bar = 0
    }
    override func viewDidDisappear(_ animated: Bool) {
        captureSession.stopRunning()
        toggleTorch(on: false)
    }
    override func viewDidLoad() {
        
        self.title = "Camera"
        tableInventory.delegate = self
        
        token = defaults.object(forKey:"token") as? String ?? ""
        userId = defaults.object(forKey:"userId") as? String ?? ""
        
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        //delegate = self
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
        //view.bringSubviewToFront(viewGoodsTable)
        view.bringSubviewToFront(lightButton)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
       //performSegue(withIdentifier: "BarCodeSearch", sender: nil)
        
        let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
 
    }

    func segueToItemList(decodedString: String, searchType: String ) {
        
        switch searchType {
        case "ReceiptDocument":
            receiptDocument()
        case "findGood":
            findGood()
        case "addCustomerToCheck":
            addCustomerToCheck()
        case "addCheckRecordToCheckFromBarCode":
            addCheckRecordToCheckFromBarCode()
        case "addCheckRecordToCheck":
            addCheckRecordToCheck()
        case "POSTInventoryCode":
            POSTInventoryCode()
        case "POSTFrontInventoryShop":
            POSTFrontInventoryShop(url: frontURL)
        case "findGoodFromInventory":
            findGoodFromInventory(goodId: decodedString)
        case "POSTsalesFontInventoryShop":
            POSTsalesFontInventoryShop()
        default:
            findGood()
        }
    
    }
    
    func receiptDocument() {
        performSegue(withIdentifier: "findReceiptInfo", sender: nil)
    }
    
    func POSTsalesFontInventoryShop() {
        
    }
    
    
    func POSTFrontInventoryShop(url: String) {
        let inventoryCode = InventoryCode.init(code: full_found_text)
        print(inventoryCode)
        receiptController.POSTInventoryEnter(url: url, token: token,  code: found_text, post: inventoryCode) { (answer) in
            //print("answer is  \(answer)")
            if answer == answer, answer != "-1" {
                
                DispatchQueue.main.async {
                    self.playOkSound()
                    // делаем скриншот
                    let newImage = UIApplication.shared.screenShot
                    
                    let newImageView = UIImageView(image: newImage)
                    newImageView.frame = UIScreen.main.bounds
                    newImageView.backgroundColor = .black
                    newImageView.contentMode = .scaleAspectFit
                    newImageView.isUserInteractionEnabled = true
                    self.view.addSubview(newImageView)
                    

                /*    if self.delegate != nil {
                        self.delegate?.getFrontInventoryShop(url: )
                    } else {
                        print("Delegate is null")
                    }*/
                    self.tableInventory.getFrontInventoryShop(url: url)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        //newImageView.removeFromSuperview()
                        
                        UIView.animate(withDuration: 0.1, animations: {newImageView.alpha = 0.4},
                                       completion: {(value: Bool) in
                                        self.found_bar = 0
                                        // self.view.removeFromSuperview()
                                        newImageView.removeFromSuperview()
                        })
                        
                    }
                }
            } else {
                self.error(title: "Сканирование не прошло")
            }
        }
    }
    
    func findGood() {
        let inventoryCode = InventoryCode.init(code: full_found_text)
        receiptController.POSTSearchGoods(token: token, post: inventoryCode) { (good) in
            if let good = good {
                DispatchQueue.main.async {
                    self.found_text = String(good.id)
                    self.performSegue(withIdentifier: "findGood", sender: nil)
                }
            }
        }
    }
    
    func addCheckRecordToCheck() {
        receiptController.GetReceipt(token: token, id: found_text) { (receipt) in
            if let receipt = receipt {
                self.checkRecord?.goods_Id = receipt.goods_Id
                self.checkRecord?.sizes_Id = receipt.sizes_Id
                self.checkRecord?.cost = receipt.cost
                self.checkRecord?.discount = 0
                self.checkRecord?.total_Cost = receipt.cost
                
                self.receiptController.POSTCheckRecord(token: self.token, post: self.checkRecord!) { (checkRecord) in
                    if let checkRecord = checkRecord {
                        print("added checkRecord is \(checkRecord)")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "addCheckRecordToCheck", sender: self)
                        }
                    } else {
                        print("error in add checkRecord \(String(describing: checkRecord))")
                    }
                }
            }
        }
    }
    
    func addCustomerToCheck() {
        if let checkRecord = checkRecord, let checkId = checkRecord.check_Id {
            receiptController.POSTCustomerToCheck(token: token, checkId: String(checkId), customerId: found_text) { (check) in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "addCheckRecordToCheck", sender: self)
                }
            }
        }
    }


    
    func POSTInventoryCode() {
        let inventoryCode = InventoryCode.init(code: full_found_text)
        print(inventoryCode)
        receiptController.POSTInventoryCode(token: token,  code: found_text, post: inventoryCode) { (answer) in
            if answer == answer, answer == "true"{
                DispatchQueue.main.async {
                    self.playOkSound()
                    // делаем скриншот
                    let newImage = UIApplication.shared.screenShot
                    
                    let newImageView = UIImageView(image: newImage)
                    newImageView.frame = UIScreen.main.bounds
                    newImageView.backgroundColor = .black
                    newImageView.contentMode = .scaleAspectFit
                    newImageView.isUserInteractionEnabled = true
                    self.view.addSubview(newImageView)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        //newImageView.removeFromSuperview()
                        
                        UIView.animate(withDuration: 0.1, animations: {newImageView.alpha = 0.4},
                                       completion: {(value: Bool) in
                                        self.found_bar = 0
                                        // self.view.removeFromSuperview()
                                        newImageView.removeFromSuperview()
                        })
                        
                    }
                }
            } else {
                self.error(title: "Сканирование не прошло")
            }
        }
    }
    
    func addCheckRecordToCheckFromBarCode() {
        receiptController.GetBarCodeFind(barcode: found_text, token: token) { (barCode) in
            if let barCode = barCode {
                self.checkRecord?.goods_Id = barCode.goods_id
                self.checkRecord?.sizes_Id = barCode.sizes_id
                self.checkRecord?.cost = barCode.receipt?.cost
                self.checkRecord?.discount = 0
                self.checkRecord?.total_Cost = barCode.receipt?.cost
                
                self.receiptController.POSTCheckRecord(token: self.token, post: self.checkRecord!) { (checkRecord) in
                    if let checkRecord = checkRecord {
                        print("added checkRecord is \(checkRecord)")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "addCheckRecordToCheck", sender: self)
                        }
                    } else {
                        print("error in add checkRecord \(String(describing: checkRecord))")
                    }
                }
            }
        }
    }
    
    
    func findGoodFromInventory(goodId: String) {
        found_text = goodId
        performSegue(withIdentifier: "findGood", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       /* страя версия поиска товара по 1С
            if segue.identifier == "BarCodeSearch" {
            let controller = segue.destination as! ItemsInfoTableViewController
            controller.id = found_text
            controller.type = "1"
        }*/
        
        if segue.identifier == "findReceiptInfo" {
            let controller = segue.destination as! ArrivalInfoViewController
            controller.receiptId = found_text
        }
        
        if segue.identifier == "findGood" {
            let controller = segue.destination as! GoodViewController
            controller.goodId = found_text
        }
        
        if segue.identifier == "addCheckRecordToCheck" {
            let controller = segue.destination as! CheckRecordViewController
            controller.checkId = checkRecord?.check_Id
        }
    
        if let controller = segue.destination as? InventoryViewController, segue.identifier == "GoodList" {
            self.tableInventory = controller
            //controller.labelString = self.stringToPass
        }
        
    }
    func playOkSound() {
        
        guard let url = Bundle.main.url(forResource: "ok", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            objPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let aPlayer = objPlayer else { return }
            aPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func error(title : String) {
        //self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.found_bar = 0
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func inventoryType(title : String) {
        //self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Склад", style: .default, handler: { action in
            //self.found_bar = 0
            self.needInventory = true
        }))
        
        alert.addAction(UIAlertAction(title: "Витрина", style: .default, handler: { action in
            //self.found_bar = 0
            self.frontURL = "InventoryFrontShop"
            self.tableInventory.getFrontInventoryShop(url: self.frontURL)
            self.frontInventory = true
            self.view.bringSubviewToFront(self.viewGoodsTable)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Продажи", style: .default, handler: { action in
            //self.found_bar = 0
            //self.frontInventory = true
            self.frontURL = "InventorySales"
            self.tableInventory.getFrontInventoryShop(url: self.frontURL)
            self.frontInventory = true
            self.view.bringSubviewToFront(self.viewGoodsTable)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    //// фонарик
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
}




extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil && found_bar == 0{
                found_bar += 1
             //   launchApp(decodedURL: metadataObj.stringValue!)
                
                found_text = metadataObj.stringValue!
                full_found_text = found_text
                print("found_text is \(found_text)")
////// Working with segue type
                let urlText = found_text.components(separatedBy: "/")
                var searchType = ""

                if needInventory == true {
                    found_text = (urlText[0] == "https:" || urlText[0] == "http:") ? urlText[urlText.count - 1] : found_text
                    searchType = "POSTInventoryCode"
                    
                }else if frontInventory == true {
                    found_text = (urlText[0] == "https:" || urlText[0] == "http:") ? urlText[urlText.count - 1] : found_text
                    searchType = "POSTFrontInventoryShop"
                    
                } else if urlText[0] == "https:" && checkRecord == nil{
                    
                    searchType = "findGood"
                    found_text = urlText[urlText.count - 1]
                    
                }else if (urlText[0] == "https:" || urlText[0] == "http:") && checkRecord != nil && urlText[urlText.count - 2] == "receipt"{
                    
                    searchType = "addCheckRecordToCheck"
                    found_text = urlText[urlText.count - 1]
                
                }else if (urlText[0] == "https:" || urlText[0] == "http:") && checkRecord != nil && urlText[urlText.count - 2] == "Customer"{
                    
                    searchType = "addCustomerToCheck"
                    found_text = urlText[urlText.count - 1]
                    
                }else if checkRecord != nil {
                    
                    searchType = "addCheckRecordToCheckFromBarCode"
                    
                }  else {
                    
                    let documentReceiptId = found_text.data(using: .utf8)
                    if let data = documentReceiptId {
                        do {
                            let decoder = JSONDecoder()
                            let product = try decoder.decode(QRReceiptDocument.self, from: data)
                            found_text = String(product.id)
                            searchType = "ReceiptDocument"
                        } catch let error {
                            print("error in getting code")
                            print(error)
                        }
                    }
                    
                }
                print(searchType)
                segueToItemList(decodedString: metadataObj.stringValue!, searchType: searchType)
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.videoPreviewLayer?.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                }
            }
        }
    }
}

extension UIApplication {
    
    var screenShot: UIImage?  {
        return keyWindow?.layer.screenShot
    }
}

extension CALayer {
    
    var screenShot: UIImage?  {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}
