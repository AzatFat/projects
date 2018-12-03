//
//  GoodChangeViewController.swift
//  Djinaro
//
//  Created by Azat on 20.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodChangeViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    

    @IBOutlet var GoodName: UITextField!
    
    @IBOutlet var GoodLocation: UITextField!
    
    @IBOutlet var GoodPrice: UITextField!
    
    @IBOutlet var GoodType: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var printGoodLableShopOutlet: UIBarButtonItem!
    
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
        
        if var good = good {
            good.name = name
            good.location = location
            good.price = Decimal(string: price)
            good.type_Goods_Id = typeGoodId != 0 ? typeGoodId: good.type_Goods_Id
            changeGood(good: good)
        } else {
            let newGood = Goods.init(id: 1, group_Goods_Id: nil, name: name, code: nil, description: nil, location: location, vendor_Code: nil, groupGoods: nil, type_Goods_Id: typeGoodId, type_Goods: nil, available_sizes: nil, price: Decimal(string: price), priceReceipt: nil, images: nil)
           createGood(good:newGood)
        }
    }
    
    @IBAction func printGoodsLableShop(_ sender: Any) {
        let receiptController = ReceiptController()
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
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
            saveButton.setTitle("Изменить товар", for: .normal)
            getGoodImage()
        } else {
            saveButton.setTitle("Создать товар", for: .normal)
        }
        
        hideKeyboardWhenTappedAround()
        
        if let goodType = good?.type_Goods_Id, goodType != 6 {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.GoodType.inputView = self.pickerView
        self.GoodType.inputAccessoryView = self.pickerView.toolbar
        
        self.pickerView.dataSource = self as? UIPickerViewDataSource
        self.pickerView.delegate = self as? UIPickerViewDelegate
        self.pickerView.toolbarDelegate = self as? ToolbarPickerViewDelegate
        
     //   goodsImagesCollection.layer.insertSublayer(gradient(frame: goodsImagesCollection.backgroundView, left: UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor, right: UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor), at:0)
        goodsImagesCollection.backgroundColor = UIColor.init(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
//gradient(frame: goodsImagesCollection.bounds)
        
        imagePicker.delegate = self
        getGoodsType()
        
        //self.pickerView.reloadAllComponents()
        // Do any additional setup after loading the view.
    }
    
    
    func changeGood(good: Goods) {
        let receiptController = ReceiptController()
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
        receiptController.PUTGood(token: token, post: good) { (answer) in
            DispatchQueue.main.async {
                self.error(title: "Товар успешно изменен")
                self.good = good
            }
        }
    }
    
    func createGood(good: Goods) {
        let receiptController = ReceiptController()
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
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
        let receiptController = ReceiptController()
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
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
        object.layer.cornerRadius = object.frame.size.width / 4
        object.layer.cornerRadius = object.frame.size.height / 4
        object.layer?.masksToBounds = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodUIImagesDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goodImageCell", for: indexPath) as! GoodsImageCollectionViewCell
        cell.goodImage.image = goodUIImagesDict[indexPath.row].image
        cell.layer.insertSublayer(gradient(frame: cell.bounds, left: UIColor.white.cgColor, right: UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor), at:0)
        applyRoundCorner(cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Cell: \(indexPath.row)")

        if indexPath.row == 0 {
            takeImage()
        } else {
            let alertController = UIAlertController(title: "Фото", message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
               print("delete")
                self.deleteGoodImage(imageId: self.goodUIImagesDict[indexPath.row].id, index: indexPath.row)
            }
            alertController.addAction(cancelAction)
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
        print("didUnhighlightItemAt")
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
    }
    var goodUIImagesDict = [goodUIimages.init(id: "main", image: UIImage(named: "addPhoto")!)]
    
    
    func takeImage() {
       // let imagePicker = UIImagePickerController()
       // imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
       /* present(imagePicker, animated: true, completion: nil)*/
        let alertController = UIAlertController(title: "выберите фото", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { (action) in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(photoLibraryAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        //uiImages.append(image)
        //goodsImagesCollection.reloadData()
        if let good = good {
            uploadImagetoGood(image: image, good: good)
        }
        picker.dismiss(animated:true,completion:nil)
    }
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
         picker.dismiss(animated:true,completion:nil)
    }
    func uploadImagetoGood(image: UIImage, good: Goods) {
        if let imageBase64 = image.toBase64() {
            let base64image = postImage.init(base64: imageBase64)
            let receiptController = ReceiptController()
            let defaults = UserDefaults.standard
            let token = defaults.object(forKey:"token") as? String ?? ""
            receiptController.POSTGoodImage(token: token, base64: base64image, good: good) { (postedImage) in
                if let posted = postedImage {
                    DispatchQueue.main.async {
                         self.goodUIImagesDict.append(goodUIimages.init(id: String(posted.id), image: image))
                         self.goodsImagesCollection.reloadData()
                        self.error(title: "товар добавлен")
                    }
                    print("sucess post image \(posted)")
                }
            }
        }
    }
    
    func deleteGoodImage(imageId: String, index: Int) {
        let receiptController = ReceiptController()
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
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
        let receiptController = ReceiptController()
        if let goodImages = good?.images {
            let myGroup = DispatchGroup()
            for images in goodImages {
                myGroup.enter()
                if let imageUrl = images.url?.min {
                    receiptController.getGoodImage(url: imageUrl) { (image) in
                        if let image = image {
                            print("full success get image")
                            //self.uiImages.append(image)
                            self.goodUIImagesDict.append(goodUIimages.init(id: String(images.id), image: image))
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
        self.GoodType.resignFirstResponder()
    }
    
    func didTapCancel() {
        self.GoodType.text = nil
        self.GoodType.resignFirstResponder()
    }
}


extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}
