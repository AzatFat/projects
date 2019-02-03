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
import PopMenu

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
    
    @IBOutlet var scannedItem: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var lightButton: UIButton!
    @IBAction func inventotyRegimeButton(_ sender: Any) {
        
        timer.invalidate()
        
        if needInventory == false && frontInventory == false {
            inventoryType(title: "Выберите режим инвентаризации")
            InventoryButtonOutlet.tintColor = .red
        } else {
            needInventory = false
            frontInventory = false
            InventoryButtonOutlet.tintColor = .blue
            self.view.sendSubviewToBack(viewGoodsTable)
            self.view.sendSubviewToBack(scannedItem)
            getAVCapture(size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height))
        }
    }
    
    @IBOutlet var InventoryButtonOutlet: UIBarButtonItem!
    @IBOutlet var viewGoodsTable: UIView!
    
    @IBOutlet var stockSettingsButton: UIBarButtonItem!
    @IBAction func stockSettings(_ sender: Any) {
        presentMenu()
    }
    
    var selectedGoodType = 0
    var selectedtypeName = "Все товары"
    @objc private func presentMenu() {
        
        // The manual way
        
        let actions = [PopMenuDefaultAction(title: "Выбрать тип товара", image: nil,didSelect: { (action) in
            DispatchQueue.main.async {
                self.presentTypeMenuForView()
                self.tableInventory.userId = ""
            }
        }),PopMenuDefaultAction(title: "Загрузить данные", image: nil,didSelect: { (action) in
            DispatchQueue.main.async {
                self.presentTypeMenuForLoad()
                self.tableInventory.userId = ""
            }
        }), PopMenuDefaultAction(title: "Очистить результаты", image: nil, didSelect: { (action) in
            DispatchQueue.main.async {
                self.clearStockInventoryResults()
                self.tableInventory.userId = ""
                
                
            }
        }), PopMenuDefaultAction(title: "Провести инвентаризацию", image: nil, didSelect: { (action) in
            DispatchQueue.main.async {
                print("finish stock")
                //self.finishStockInventoryResults()
                self.GetStockInventoryResult()
            }
        }), PopMenuDefaultAction(title: "Отсканированые мной товары", image: nil, didSelect: { (action) in
            DispatchQueue.main.async {
                self.tableInventory.getStockInventorybyUser(typeGood: 0, typeName: "Все товары", userId: self.userId)
                self.tableInventory.userId = self.userId
            }
        })]
        
        // Pass the UIView in init
        let menu = PopMenuViewController(sourceView: stockSettingsButton, actions: actions)
        present(menu, animated: true, completion: nil)
    }

    
    @objc private func presentTypeMenuForLoad() {
        if typeGoods.count > 0 {
            var actions = [PopMenuDefaultAction(title: "Все товары", image: nil, didSelect: { (action) in
                self.selectedGoodType = 0
                self.selectedtypeName = "Все товары"
                self.loadStockInventoryResults(typeId: 0)
                self.tableInventory.typeGood = self.selectedGoodType
                self.tableInventory.typeName = self.selectedtypeName
                
            })]
            for i in typeGoods {
                if i.id != 0 {
                    actions.append(PopMenuDefaultAction(title: i.name, image: nil,didSelect: { (action) in
                        self.selectedGoodType = i.id
                        self.selectedtypeName = i.name ?? ""
                        self.loadStockInventoryResults(typeId: i.id)
                        self.tableInventory.typeGood = self.selectedGoodType
                        self.tableInventory.typeName = self.selectedtypeName
                        
                    }))
                }
            }
            // Pass the UIView in init
            let menu2 = PopMenuViewController(actions: actions)
            present(menu2, animated: true, completion: nil)
        }
    }
    
    @objc private func presentTypeMenuForView() {
        if typeGoods.count > 0 {
            var actions = [PopMenuDefaultAction(title: "Все товары", image: nil, didSelect: { (action) in
                self.selectedGoodType = 0
                self.selectedtypeName = "Все товары"
                self.tableInventory.typeGood = self.selectedGoodType
                self.tableInventory.typeName = self.selectedtypeName
                self.tableInventory.getStockInventory(typeGood: self.selectedGoodType, typeName: self.selectedtypeName, user_id: "")
            })]
            for i in typeGoods {
                if i.id != 0 {
                    actions.append(PopMenuDefaultAction(title: i.name, image: nil,didSelect: { (action) in
                        self.selectedGoodType = i.id
                        self.selectedtypeName = i.name ?? ""
                        self.tableInventory.typeGood = self.selectedGoodType
                        self.tableInventory.typeName = self.selectedtypeName
                        self.tableInventory.getStockInventory(typeGood: self.selectedGoodType, typeName: self.selectedtypeName, user_id: "")
                    }))
                }
            }
            // Pass the UIView in init
            let menu2 = PopMenuViewController(actions: actions)
            present(menu2, animated: true, completion: nil)
        }
    }
    
    
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
    var scanAreaView = UIView()
    var togleON = false
    
    var receiptController = ReceiptController(useMultiUrl: true)
    var qrReceiptDocument: QRReceiptDocument?
    var token = ""
    var userId = ""
    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
    
    var objPlayer: AVAudioPlayer?
    
    var typeGoods = [TypeGoods]()
    
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
        //needInventory = false
        if frontInventory == true {
            scheduledTimerWithTimeInterval()
        }
        //frontInventory = false
        //InventoryButtonOutlet.tintColor = .blue
        //self.view.sendSubviewToBack(viewGoodsTable)
        found_bar = 0
    }
    override func viewDidDisappear(_ animated: Bool) {
        captureSession.stopRunning()
        qrCodeFrameView?.frame = CGRect.zero
        toggleTorch(on: false)
        timer.invalidate()
    }
    

    override func viewDidLoad() {
        
        self.title = "Camera"
        tableInventory.delegate = self
        
        token = defaults?.value(forKey:"token") as? String ?? ""
        userId = defaults?.value(forKey:"userId") as? String ?? ""
        
        super.viewDidLoad()
        
        //Get type Goods to stock Inventory settings
        getGoodsType()
        self.navigationItem.leftBarButtonItem = nil
        // Start video capture.
        captureSession.startRunning()

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        getAVCapture(size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
        //view.bringSubviewToFront(viewGoodsTable)
        view.bringSubviewToFront(lightButton)
        //view.bringSubviewToFront(scanAreaView)
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    func getAVCapture(size: CGSize) {
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        let height = size.height
        let width = size.width
        
        let scanRect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: width, height: height))
        
        let ramRect = CGRect(origin: CGPoint(x:  0,y : size.height / 3), size: CGSize(width: self.view.frame.size.width, height: size.height / 3))
        
        
        scanAreaView.layer.borderColor = UIColor.cyan.cgColor
        scanAreaView.layer.borderWidth = 2
        
        videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: scanRect)
        
        
        let inputs = captureSession.inputs
        print("inputs is \(inputs)")
        for oldInput:AVCaptureInput in inputs {
            captureSession.removeInput(oldInput)
        }
        let outPuts = captureSession.outputs
        print("outPuts is \(outPuts)")
        for oldOutPut: AVCaptureOutput in outPuts {
            captureSession.removeOutput(oldOutPut)
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            
            captureMetadataOutput.rectOfInterest =   videoPreviewLayer!.metadataOutputRectConverted(fromLayerRect: scanRect)
            scanAreaView.frame = ramRect
            captureSession.addOutput(captureMetadataOutput)
            
            view.addSubview(scanAreaView)
            scanAreaView.translatesAutoresizingMaskIntoConstraints = true
            //scanAreaView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            scanAreaView.autoresizingMask = [UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin]
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        view.bringSubviewToFront(scanAreaView)
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
    
    // Витринная и продажная инвентаризаця
    func POSTFrontInventoryShop(url: String) {
        let inventoryCode = InventoryCode.init(code: full_found_text)
        print(inventoryCode)
        receiptController.POSTInventoryEnter(url: url, token: token,  code: found_text, post: inventoryCode) { (answer) in
            //print("answer is  \(answer)")
            if let answer = answer {
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
                                        // выводим последний отсканированный товар
                                        let cnt = answer.cnt ?? 0
                                        let size_min = answer.sizes_Min?.name ?? ""
                                        let size = answer.sizes?.name ?? ""
                                        let goodName = answer.goods?.name ?? ""
                                        self.scannedItem.text = "  \(cnt) | \(size_min) | \(size) | \(goodName)"
                                        self.scannedItem.textColor = UIColor.cyan
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
    
    // Складская инвентаризация
    func POSTInventoryCode() {
        let inventoryCode = InventoryCode.init(code: full_found_text)
        print(inventoryCode)
        receiptController.POSTInventoryCode(token: token,  code: found_text, post: inventoryCode) { (answer) in
            if let answer = answer{
                print(answer)
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
                        self.tableInventory.getStockInventory(typeGood: self.selectedGoodType, typeName: self.selectedtypeName, user_id: "")
                        UIView.animate(withDuration: 0.1, animations: {newImageView.alpha = 0.4},
                                       completion: {(value: Bool) in
                                        self.found_bar = 0
                                        // self.view.removeFromSuperview()
                                        newImageView.removeFromSuperview()
                                        let remain = answer.remain
                                        let remain_fact = answer.remain_fact
                                        self.scannedItem.text = "\(remain_fact ?? 0) | \(remain ?? 0) \(answer.goods?.name ?? "")"
                                        if remain_fact == remain {
                                            self.scannedItem.textColor = UIColor.cyan
                                        } else {
                                            self.scannedItem.textColor = UIColor.red
                                        }
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
            self.navigationItem.leftBarButtonItem = self.stockSettingsButton
            self.needInventory = true
             self.getAVCapture(size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 0.7))
            self.view.bringSubviewToFront(self.scannedItem)
            self.view.bringSubviewToFront(self.viewGoodsTable)
            self.view.bringSubviewToFront(self.lightButton)
            self.tableInventory.getStockInventory(typeGood: self.selectedGoodType, typeName: self.selectedtypeName, user_id: "")
            self.tableInventory.typeGood = self.selectedGoodType
            self.tableInventory.typeName = self.selectedtypeName
        }))
        
        alert.addAction(UIAlertAction(title: "Витрина", style: .default, handler: { action in
           self.getAVCapture(size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 0.7))
            self.frontURL = "InventoryFrontShop"
            self.tableInventory.getFrontInventoryShop(url: self.frontURL)
            self.frontInventory = true
            self.view.bringSubviewToFront(self.scannedItem)
            self.view.bringSubviewToFront(self.viewGoodsTable)
            self.view.bringSubviewToFront(self.lightButton)
            self.scheduledTimerWithTimeInterval()
        }))
        
        alert.addAction(UIAlertAction(title: "Продажи", style: .default, handler: { action in
            self.getAVCapture(size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 0.7))
            self.frontURL = "InventorySales"
            self.tableInventory.getFrontInventoryShop(url: self.frontURL)
            self.frontInventory = true
            self.view.bringSubviewToFront(self.scannedItem)
            self.view.bringSubviewToFront(self.viewGoodsTable)
            self.view.bringSubviewToFront(self.lightButton)
            self.scheduledTimerWithTimeInterval()
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
    
    var timer = Timer()
    func scheduledTimerWithTimeInterval(){
        timer.invalidate()
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(getFrontInventoryShops), userInfo: nil, repeats: true)
    }
    
    func getGoodsType () {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.GETTypeGoods(token: token) { (typeGoods) in
            if let typeGoods = typeGoods {
                self.typeGoods = typeGoods
            }
        }
    }
    func clearStockInventoryResults() {
        let alert = UIAlertController(title: "Вы действительно хотите удалить все данные по отсканированным товарам", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.receiptController.POSTClearStockInventoryResults(token: self.token) { (answer) in
                DispatchQueue.main.async {
                    if let answer = answer {
                        self.error(title: answer)
                        self.tableInventory.getStockInventory(typeGood: self.selectedGoodType, typeName: self.selectedtypeName, user_id: "")
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func loadStockInventoryResults(typeId: Int) {
        
        receiptController.POSTLoadStockInventoryResults(token: token, typeId: String(typeId) ) { (answer) in
            DispatchQueue.main.async {
                if let answer = answer {
                    self.error(title: answer)
                    self.tableInventory.getStockInventory(typeGood: self.selectedGoodType, typeName: self.selectedtypeName, user_id: "")
                }
            }
        }
    }

    func GetStockInventoryResult() {
        self.receiptController.GetResultInventoryStock(token: self.token) { (answer) in
            DispatchQueue.main.async {
                if let answer = answer {
                    
                    var message = ""
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .left
                    message = "Будет списано:      \(answer.records_off_sale ?? 0)"
                    message += "\nБудет добавлено: \(answer.records_receipts ?? 0)"
                    
                    let messageText = NSMutableAttributedString(
                        string: message,
                        attributes: [
                            NSAttributedString.Key.paragraphStyle: paragraphStyle,
                            NSAttributedString.Key.foregroundColor: UIColor.black
                        ]
                    )
    
                    let alert = UIAlertController(title: "Вы действительно хотите создать поступление", message: nil, preferredStyle: UIAlertController.Style.alert)
                    alert.setValue(messageText, forKey: "attributedMessage")
                    alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
                        self.receiptController.POSTFinish(token: self.token) { (answer) in
                            DispatchQueue.main.async {
                                if let answer = answer {
                                    self.error(title: answer)
                                }
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: { action in
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func getFrontInventoryShops() {
        self.tableInventory.getFrontInventoryShop(url: frontURL)
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
