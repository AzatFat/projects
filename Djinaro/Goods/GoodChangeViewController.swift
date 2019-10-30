//
//  GoodChangeViewController.swift
//  Djinaro
//
//  Created by Azat on 20.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker


class GoodChangeViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var GoodName: UITextField!
    
    @IBOutlet var GoodLocation: UITextField!
    
    @IBOutlet var GoodPrice: UITextField!
    
    @IBOutlet var GoodType: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var GoodDiscountPrice: UITextField!
    
    @IBOutlet var printGoodLableShopOutlet: UIBarButtonItem!
    
    @IBOutlet var archiveFlag: UISwitch!
    
    @IBOutlet var showOnSite: UISwitch!
    
    @IBOutlet var goodsImagesCollection: UICollectionView!
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        guard let name = GoodName.text, name != "" else {
            error(title: "Нименование обязательно")
            return
        }
        guard let location = GoodLocation.text, location != "" else {
            error(title: "Локация обязательна")
            return
        }
        guard let price = GoodPrice.text, price != "" else {
            error(title: "Цена обязательна")
            return
        }
        guard let type = GoodType.text, type != "" else {
            error(title: "Тип обязателен")
            return
        }
        
        let price_Discount = GoodDiscountPrice.text
        
        if var good = good {
            //print(good.broadcast_New)
            good.name = name
            good.location = location
            good.price = Decimal(string: price)
            good.type_Goods_Id = typeGoodId != 0 ? typeGoodId: good.type_Goods_Id
            good.isArchive = archiveFlag.isOn ? false : true
            good.broadcast_New = showOnSite.isOn ? true : false
            good.price_Discount = Decimal(string: price_Discount ?? "0")
            //print(good.broadcast_New)
            changeGood(good: good)
        } else {
            let newGood = Goods.init(id: 1, group_Goods_Id: nil, name: name, code: nil, description: nil, location: location, vendor_Code: nil, groupGoods: nil, type_Goods_Id: typeGoodId, type_Goods: nil, available_sizes: nil, price: Decimal(string: price), priceReceipt: nil, images: nil, image: nil, isArchive: false, price_Discount: Decimal(string: price_Discount ?? "0"), broadcast_New: true)
           createGood(good:newGood)
        }
    }
    
    @IBAction func printGoodsLableShop(_ sender: Any) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        if let good_id = good?.id,  good?.price != 0, good?.price != nil, GoodPrice.text != "" {
            print("print shop label")
            receiptController.POSTGoodPrintShopLabel(token: token, goodId: String(good_id)) { (answer) in
                DispatchQueue.main.async {
                    if let answer = answer {
                        self.error(title: answer)
                    }
                }
            }
        } else {
            error(title: "Цена товара равна нулю. Печать не возможна")
        }
    }
    
    var good: Goods?
    var typeGoodId = 0
    private let pickerView = ToolbarPickerView()
    var pickerData: [TypeGoods] = []
    let imagePicker = UIImagePickerController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if good != nil {
            GoodName.text = good?.name
            GoodLocation.text = good?.location
            if let price = good?.price {
                GoodPrice.text = price.formattedAmount
                GoodPrice.text = GoodPrice.text == ",00" ? "" : GoodPrice.text
            }
            GoodType.text = good?.type_Goods?.name
            archiveFlag.isOn = good?.isArchive ?? true ? false : true
            showOnSite.isOn = good?.broadcast_New ?? true ? true : false
            if let priceDiscount = good?.price_Discount {
                GoodDiscountPrice.text = priceDiscount.formattedAmount
                GoodDiscountPrice.text = GoodDiscountPrice.text == ",00" ? "" : GoodDiscountPrice.text
            }
            
            saveButton.setTitle("Изменить товар", for: .normal)
            getGoodImage()
        } else {
            saveButton.setTitle("Создать товар", for: .normal)
        }
        
        hideKeyboardWhenTappedAround()
        
        if let goodType = good?.type_Goods_Id, goodType != 6 && goodType != 10 {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.GoodType.inputView = self.pickerView
        self.GoodType.inputAccessoryView = self.pickerView.toolbar
        
        self.pickerView.dataSource = self as UIPickerViewDataSource
        self.pickerView.delegate = self as UIPickerViewDelegate
        self.pickerView.toolbarDelegate = self as ToolbarPickerViewDelegate
        
        goodsImagesCollection.backgroundColor = UIColor.init(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)

        imagePicker.delegate = self
        getGoodsType()
    }
    
    
    func changeGood(good: Goods) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.PUTGood(token: token, post: good) { (answer) in
            DispatchQueue.main.async {
                self.error(title: "Товар успешно изменен")
                self.good = good
            }
        }
    }
    
    func createGood(good: Goods) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.POSTGood(token: token, post: good) { (good) in
            if let good = good {
                DispatchQueue.main.async {
                    self.GoodName.text = good.name
                    self.GoodLocation.text = good.location
                    if let price = good.price {
                        self.GoodPrice.text = price.formattedAmount
                    }
                    self.good = good
                    self.error(title: "Товар успешно создан")
                    self.saveButton.setTitle("Изменить товар", for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.error(title: "Произошла ошибка при создании товара")
                }
            }
        }
    }
    
    func getGoodsType () {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.GETTypeGoods(token: token) { (typeGoods) in
            if let typeGoods = typeGoods {
                self.pickerData = typeGoods
                DispatchQueue.main.async {
                    self.pickerView.reloadAllComponents()
                    if self.good != nil {
                        for i in typeGoods {
                            if self.good?.type_Goods_Id == i.id {
                                self.GoodType.text = i.name
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func error(title : String) {
        //self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Collection view Image
    
    func gradient(frame:CGRect, left: CGColor, right: CGColor) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.colors = [
            UIColor.white.cgColor,UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor]
        layer.opacity = 0.2
        return layer
    }
    
    func applyRoundCorner (_ object: AnyObject) {
        if #available(iOS 13.0, *) {
            object.layer.cornerRadius = object.frame.size.width / 4
            object.layer.cornerRadius = object.frame.size.height / 4
            object.layer?.masksToBounds = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodUIImagesDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goodImageCell", for: indexPath) as! GoodsImageCollectionViewCell
        cell.goodImage.image = goodUIImagesDict[indexPath.row].image
        cell.layer.insertSublayer(gradient(frame: cell.bounds, left: UIColor.white.cgColor, right: UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor), at:0)
        applyRoundCorner(cell)
        
        if goodUIImagesDict[indexPath.row].main == true {
            print(goodUIImagesDict[indexPath.row].main, indexPath.row)
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.red.cgColor
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.white.cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.row == 0 {
           // takeImage()
            getImageFromPhotoLibrary()
           
        } else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
               print("delete")
                self.deleteGoodImage(imageId: self.goodUIImagesDict[indexPath.row].id, index: indexPath.row)
            }
            
            let makeMainAction = UIAlertAction(title: "Сделать главной", style: .default) { (action) in
                self.makeGoodImageMain(imageId: self.goodUIImagesDict[indexPath.row].id, index: indexPath.row)
            }
            
            let image = goodUIImagesDict[indexPath.row].image
            alertController.addImage(image: image)
            

            alertController.addAction(cancelAction)
            alertController.addAction(makeMainAction)
            alertController.addAction(deleteAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        print("didHighlightItemAt")
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cell?.layer.borderWidth = 0.0
            cell?.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    var uiImages: [UIImage] = [UIImage(named: "addPhoto")!]
    
    struct goodUIimages {
        var id: String
        var image: UIImage
        var main: Bool
    }
    var goodUIImagesDict = [goodUIimages.init(id: "main", image: UIImage(named: "addPhoto")!, main: false)]

    var SelectedAssets = [PHAsset]()
   // var PhotoArrray = [UIImage]()
    
    
    func showImagePickerWithSelectedAssets() {
        let allAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        var evenAssetIds = [String]()
        
        allAssets.enumerateObjects({ (asset, idx, stop) -> Void in
            if idx % 2 == 0 {
                evenAssetIds.append(asset.localIdentifier)
            }
        })
        
        let evenAssets = PHAsset.fetchAssets(withLocalIdentifiers: evenAssetIds, options: nil)
        
        let vc = BSImagePickerViewController()
        vc.defaultSelections = evenAssets
        
        
        bs_presentImagePickerController(vc, animated: true,
                                        select: { (asset: PHAsset) -> Void in
                                            print("Selected: \(asset)")
        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected: \(asset)")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel: \(assets)")
        }, finish: { (assets: [PHAsset]) -> Void in
            print("Finish: \(assets)")
        }, completion: nil)
    }
    
    func getImageFromPhotoLibrary() {
        let vc = BSImagePickerViewController()
        
        self.bs_presentImagePickerController(vc, animated: true, select: { (asset: PHAsset) -> Void in
        }, deselect: { (asset: PHAsset) -> Void in
        }, cancel: { (asset: [PHAsset]) -> Void in
        }, finish: { (asset: [PHAsset]) in
            for i in 0 ..< asset.count {
                self.SelectedAssets.append(asset[i])
            }
            self.convertAssetToImages()
        }, completion: nil)
    }
    
    func convertAssetToImages() {
        DispatchQueue.main.async {
            self.addPreload(start_stop: true)
        }
        if SelectedAssets.count != 0 {
            for i in 0 ..< SelectedAssets.count {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
               // var thumbnail = UIImage()
                var data = Data()
                option.isSynchronous = true
                
                manager.requestImageData(for: SelectedAssets[i], options: option, resultHandler: { (result, str, orientation, info) -> Void in
                    data = result!
                })
                
               // let data = thumbnail.jpegData(compressionQuality: 1)
                let newImage = UIImage(data: data)
                //self.PhotoArrray.append(newImage! as  UIImage)
                DispatchQueue.main.async {
                    let isMax = i == self.SelectedAssets.count - 1  ? true : false
                    self.uploadImagetoGood(image: newImage!, good: self.good!, isMaxI: isMax)
                    
                }
            }
        }
    }
    
    func uploadImagetoGood(image: UIImage, good: Goods, isMaxI: Bool) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        
        receiptController.POSTGoodImageAsData(token: token, image: image.fixOrientation()!, good: good) { (postedImage) in
            if let posted = postedImage {
                DispatchQueue.main.async {
                    self.goodUIImagesDict.append(goodUIimages.init(id: String(posted.id), image: image, main: false))
                        self.goodsImagesCollection.reloadData()
                    if isMaxI {
                        self.addPreload(start_stop: false)
                        self.error(title: "изображения добавлены")
                        self.SelectedAssets = []
                    }
                   // self.error(title: "товар добавлен")
                }
                print("sucess post image \(posted)")
            } else {
                DispatchQueue.main.async {
                    if isMaxI {
                        self.goodsImagesCollection.reloadData()
                        self.addPreload(start_stop: false)
                    }
                    self.error(title: "Одно из изображений не добавлено")
                }
            }
        }
    }
    
    func deleteGoodImage(imageId: String, index: Int) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.DELETEGoodsImage(token: token, imageId: imageId) { (answer) in
            if let answer = answer {
                if answer == "Товар удален" {
                    DispatchQueue.main.async {
                        self.goodUIImagesDict.remove(at: index)
                        self.goodsImagesCollection.reloadData()
                        self.error(title: "товар удален")
                    }
                }
            }
        }
    }
    
    func getGoodImage() {
        let receiptController = ReceiptController(useMultiUrl: true)
        if let goodImages = good?.images {
            let myGroup = DispatchGroup()
            for images in goodImages {
                myGroup.enter()
                if let imageUrl = images.url?.main {
                    receiptController.getGoodImage(url: imageUrl) { (image) in
                        if let image = image {
                            print("full success get image")
                            self.goodUIImagesDict.append(goodUIimages.init(id: String(images.id), image: image, main: images.is_Main ?? false))
                            myGroup.leave()
                        }else {
                            myGroup.leave()
                        }
                    }
                } else {
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                self.goodsImagesCollection.reloadData()
            }
        }
    }
    
    func makeGoodImageMain(imageId: String, index: Int) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.MakeGoodsImageMain(token: token, imageId: imageId) { (answer) in
            if let answer = answer {
                if answer == "Товар изменен" {
                    DispatchQueue.main.async {
                        for (i, n) in self.goodUIImagesDict.enumerated() {
                            if n.main {
                                self.goodUIImagesDict[i].main = false
                                break
                            }
                        }
                        self.goodUIImagesDict[index].main = true
                        self.goodsImagesCollection.reloadData()
                        self.error(title: "Изображение сделано главным")
                    }
                }
            }
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    func addPreload(start_stop: Bool){
        if start_stop {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
    }
}

extension GoodChangeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.GoodType.text = self.pickerData[row].name
        self.typeGoodId = self.pickerData[row].id
    }
}

extension GoodChangeViewController: ToolbarPickerViewDelegate {
    
    func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.GoodType.text = self.pickerData[row].name
        self.typeGoodId = self.pickerData[row].id
        self.GoodType.resignFirstResponder()
    }
    
    func didTapCancel() {
        self.GoodType.text = nil
        self.GoodType.resignFirstResponder()
    }
}


extension UIAlertController {
    func addImage(image: UIImage) {
        let maxSize = CGSize(width: 290, height: 360)
        let imageSize = image.size
        print(image.size)
        
        var ratio: CGFloat!
        if imageSize.width > imageSize.height {
            ratio = maxSize.width / imageSize.width
        } else {
            ratio = maxSize.height / imageSize.height
        }
        
        ratio = ratio > 1 ? 1 : ratio
        
        let scaledSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
        let resizedImage = image.resizeImage(targetSize: scaledSize)
        
        let alertViewPadding: CGFloat = 19.0 //Adjust this as per your need
        let left = -self.view.frame.size.width / 2 + resizedImage.size.width/2 + alertViewPadding
        
        print(self.view.frame.size.width, resizedImage.size.width, left)
        
        resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left:  0, bottom: 0, right: left))
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left:  left, bottom: 0, right: 0)).withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imgAction)
    }
}
