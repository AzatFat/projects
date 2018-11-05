//
//  QRScannerController.swift
//  Djinaro
//
//  Created by Azat on 23.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit
import AVFoundation



struct QRReceiptDocument: Codable {
    var type: String
    var id: Int

    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case id = "Id"
    }
    
}


class QRScannerController: UIViewController {

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
    
    var captureSession = AVCaptureSession()
    var checkRecord: CheckRecord?
    var found_bar = 0
    var found_text = ""
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var togleON = false
    var receiptController = ReceiptController()
    var qrReceiptDocument: QRReceiptDocument?
    var token = ""
    let defaults = UserDefaults.standard
    
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
        found_bar = 0
    }
    override func viewDidDisappear(_ animated: Bool) {
        toggleTorch(on: false)
    }
    override func viewDidLoad() {
        
        token = defaults.object(forKey:"token") as? String ?? ""
        print(checkRecord)
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
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
        view.bringSubviewToFront(lightButton)
      //  view.bringSubviewToFront(topbar)
        
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
        performSegue(withIdentifier: "BarCodeSearch", sender: nil)
        
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
        if searchType == "ReceiptDocument" {
            performSegue(withIdentifier: "findReceiptInfo", sender: nil)
        } else if searchType == "findGood"  {
            receiptController.GetReceipt(token: token, id: found_text) { (receipt) in
                if let receipt = receipt {
                    DispatchQueue.main.async {
                        self.found_text = String(receipt.goods_Id!)
                        self.performSegue(withIdentifier: "findGood", sender: nil)
                    }
                }
            }
        }else if searchType == "addCheckRecordToCheck" {
            receiptController.GetReceipt(token: token, id: found_text) { (receipt) in
                if let receipt = receipt {
                    // let checkRecord = CheckRecord.init(id: 1, check_Id: check.id, goods_Id: nil, sizes_Id: nil, employees_Id: Int(userId), customer_Id: 0, count: 1, cost: nil, discount: nil, total_Cost: nil, stockRemainsCount: nil, check: nil, goods: nil, sizes: nil, employees: nil, customer: nil)
                    
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
                            print("error in add checkRecord \(checkRecord)")
                        }
                    }
                }
            }
            
        } else {
            performSegue(withIdentifier: "BarCodeSearch", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BarCodeSearch" {
            let controller = segue.destination as! ItemsInfoTableViewController
            controller.id = found_text
            controller.type = "1"
        }
        
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
////// Working with segue type
                let urlText = found_text.components(separatedBy: "/")
                var searchType = ""

                if urlText[0] == "https:" && checkRecord == nil{
                    searchType = "findGood"
                    found_text = urlText[urlText.count - 1]
                }else if urlText[0] == "https:" && checkRecord != nil{
                    searchType = "addCheckRecordToCheck"
                    found_text = urlText[urlText.count - 1]
                } else {
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
