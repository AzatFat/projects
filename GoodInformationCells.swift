//
//  GoodInformationCells.swift
//  Djinaro
//
//  Created by azat fatykhov on 08/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//
import UIKit
import Foundation
import BSImagePicker
import Photos


class GoodInfoCell: BaseTableViewCell <GooodsCellRepresentation>, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var delegate: ViewForImagePresenting? = nil
    var delegateForChangingData:  changeValue? = nil
    var delegateForReloadTable: ReloadData? = nil
    var bindType: goodChangeBind? = nil
    var switchPos: Bool = false
     
    override var item: GooodsCellRepresentation? {
        didSet {
            //print("cell edited")
            self.subviews.forEach({ $0.removeFromSuperview() })
            switch item?.cellType {
            case .bool:
                bindType = item?.goodChangeBind
                switchPos = item?.boolValue ?? false
                delegateForChangingData = item?.delegateForUISwitch
                self.addSubview(setCellDescription(description: item?.description ?? ""))
                self.addSubview(setCellTitile(description: item?.title ?? ""))
                self.addSubview(setUISwitch(isOn: item?.boolValue ?? false))
            case .save:
                bindType = item?.goodChangeBind
                delegateForChangingData = item?.delegateForUISwitch
                self.addSubview(setSaveButton())
            case .imagesCollection:
                imagePicker.delegate = self
                self.addSubview(setImages())
                // goodUIImagesDict = item?.goodUIImagesDict ?? []
                setImages().reloadData()
                delegate = item?.delegate
                delegateForReloadTable = item?.delegateForReloadingTable
                good = item?.goods
                //getGoodImage()
            default:
                
                self.addSubview(setCellDescription(description: item?.description ?? ""))
                self.addSubview(setCellTitile(description: item?.title ?? ""))
            }
        }
    }
    
    
        
    func setCellDescription(description: String ) -> UILabel {
        let label = UILabel(frame: CGRect(x:  20, y: self.frame.height - 22, width: 200, height: 20))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.text = description
        label.textColor = .gray
        return label
    }
    
    
    func setCellTitile(description: String ) -> UILabel {
        let label = UILabel(frame: CGRect(x:  20, y: 8, width: self.frame.width, height: 44))
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = description
        label.textColor = .black
        return label
    }
    
    
    func setUISwitch(isOn: Bool) -> UISwitch {
        let switchView = UISwitch(frame: CGRect(x: self.frame.width - 80, y: self.frame.height/4, width: 20, height: 10))
        switchView.setOn(isOn, animated: true)
        switchView.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        return switchView
    }
    
    @objc func switchValueDidChange(_ sender:UISwitch!)
    {
        
        if let bind = bindType {
            delegateForChangingData?.changeGoodsValues(newValue: !switchPos, bind: bind)
        }
       // print(item?.boolValue)
        //item?.boolValue = !(item?.boolValue ?? true)
    }
    
    func setSaveButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width , height: self.frame.height))
        button.setTitle(item?.title, for: .normal)
        button.backgroundColor = .lightGray
      //  button.
        button.addTarget(self, action: #selector(saveData), for: .touchUpInside)
        return button
    }
    
    @objc func saveData(_ sender:UIButton!)
       {
           
           if let bind = bindType {
               delegateForChangingData?.changeGoodsValues(newValue: "save", bind: bind)
           }
          // print(item?.boolValue)
           //item?.boolValue = !(item?.boolValue ?? true)
       }
       
    
    func image(size: CGRect) -> UIImageView {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image.contentMode = UIView.ContentMode.scaleToFill
        return image
    }
 
    
    func setImages() -> UICollectionView {
        let collectionView = UICollectionView(frame: CGRect(x: 5, y: 5, width: self.frame.width - 10, height: self.frame.height - 10), collectionViewLayout: UICollectionViewFlowLayout.init())
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(GoodsImageCollectionViewCell.self, forCellWithReuseIdentifier: "goodImageCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.init(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        return collectionView
    }
    
    

    /// Futher it is copy past from goodChangeViewController
    var good: Goods?
    //var typeGoodId = 0
    private let pickerView = ToolbarPickerView()
   // var pickerData: [TypeGoods] = []
    let imagePicker = UIImagePickerController()
    
    //var uiImages: [UIImage] = [UIImage(named: "addPhoto")!]
    
    //var goodUIImagesDict: [goodUIimages] = []

    
    
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
        return item?.goodUIImagesDict?.count ?? 0// goodUIImagesDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goodImageCell", for: indexPath) as! GoodsImageCollectionViewCell
        
        let image = self.image(size: cell.frame)
        image.image = item?.goodUIImagesDict?[indexPath.row].image//goodUIImagesDict[indexPath.row].image
        cell.addSubview(image)
        
        cell.layer.insertSublayer(gradient(frame: cell.bounds, left: UIColor.white.cgColor, right: UIColor.init(red: 49.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor), at:0)
        applyRoundCorner(cell)
        
        if item?.goodUIImagesDict?[indexPath.row].main == true {
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.red.cgColor
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.white.cgColor
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            print("Click")
           if indexPath.row == 0 {
              // takeImage()
               getImageFromPhotoLibrary()
              
           } else {
               let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
               
               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
               let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
                  print("delete")
                self.deleteGoodImage(imageId: (self.item?.goodUIImagesDict?[indexPath.row].id)!, index: indexPath.row)
               }
               
               let makeMainAction = UIAlertAction(title: "Сделать главной", style: .default) { (action) in
                self.makeGoodImageMain(imageId: (self.item?.goodUIImagesDict?[indexPath.row].id)!, index: indexPath.row)
               }
               
            let image = item?.goodUIImagesDict?[indexPath.row].image
               alertController.addImage(image: image!)
               

               alertController.addAction(cancelAction)
               alertController.addAction(makeMainAction)
               alertController.addAction(deleteAction)
               delegate?.present(alertController, animated: true, completion: nil)
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
    
    var SelectedAssets = [PHAsset]()
    
    
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
        
        if let vc_1 = delegate {
            vc_1.bs_presentImagePickerController(vc, animated: true,
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
           
       }
       
       func getImageFromPhotoLibrary() {
           let vc = BSImagePickerViewController()
                if let vc_1 = delegate {
                vc_1.bs_presentImagePickerController(vc, animated: true, select: { (asset: PHAsset) -> Void in
                }, deselect: { (asset: PHAsset) -> Void in
                }, cancel: { (asset: [PHAsset]) -> Void in
                }, finish: { (asset: [PHAsset]) in
                    for i in 0 ..< asset.count {
                        self.SelectedAssets.append(asset[i])
                    }
                    self.convertAssetToImages()
                }, completion: nil)
            
            }
       }
       
       func convertAssetToImages() {
           DispatchQueue.main.async {
              // self.addPreload(start_stop: true)
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
                   
                   let newImage = UIImage(data: data)
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
                       self.item?.goodUIImagesDict?.append(goodUIimages.init(id: String(posted.id), image: image, main: false))
                       self.reloadCollectionDataAndTableViewData()
                       if isMaxI {
                          // self.addPreload(start_stop: false)
                           self.error(title: "изображения добавлены")
                           self.SelectedAssets = []
                       }
                      // self.error(title: "товар добавлен")
                   }
                   print("sucess post image \(posted)")
               } else {
                   DispatchQueue.main.async {
                       if isMaxI {
                           self.reloadCollectionDataAndTableViewData()
                          // self.addPreload(start_stop: false)
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
                           self.item?.goodUIImagesDict?.remove(at: index)
                           self.reloadCollectionDataAndTableViewData()
                           self.error(title: "товар удален")
                       }
                   }
               }
           }
       }
    
    func reloadCollectionDataAndTableViewData () {
        self.setImages().reloadData()
        //delegateForReloadTable?.reloadData()
    }
       
    
       /*func getGoodImage() {
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
                   self.setImages().reloadData()
               }
           }
       }*/
       
       func makeGoodImageMain(imageId: String, index: Int) {
           let receiptController = ReceiptController(useMultiUrl: true)
           let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
           let token = defaults?.value(forKey:"token") as? String ?? ""
           receiptController.MakeGoodsImageMain(token: token, imageId: imageId) { (answer) in
               if let answer = answer {
                   if answer == "Товар изменен" {
                       DispatchQueue.main.async {
                        for (i, n) in (self.item?.goodUIImagesDict?.enumerated())! {
                               if n.main {
                                   self.item?.goodUIImagesDict?[i].main = false
                                   break
                               }
                           }
                           self.item?.goodUIImagesDict?[index].main = true
                           self.reloadCollectionDataAndTableViewData()
                           self.error(title: "Изображение сделано главным")
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
        
        self.delegate?.present(alert, animated: true, completion: nil)
    }
    
}


extension GoodInfoCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.frame.height - 10, height: self.frame.height - 10)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
