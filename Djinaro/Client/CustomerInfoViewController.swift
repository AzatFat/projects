//
//  CustomerInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 10.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class CustomerInfoViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource {

    
    var customer: Customer?
    var checkRecord: CheckRecord?
    private var datePicker: UIDatePicker!
    
    @IBOutlet var CustomerName: UITextField!
    
    @IBOutlet var CustomerMiddle: UITextField!
    
    @IBOutlet var CustomerSecondName: UITextField!
    
    @IBOutlet var CustomerEmail: UITextField!
    
    @IBOutlet var CustomerPhone: UITextField!
    
    @IBOutlet var CustomerDateBirth: UITextField!
    
    @IBOutlet var CreateCustomer: UIButton!
    
    @IBOutlet var addPhoto: UIButton!

    @IBOutlet var customerPhotos: UICollectionView!
    
    var customerImage : UIImage?
    
    @IBAction func addPhotoAction(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            selectImageFrom(.photoLibrary)
            return
        }
        selectImageFrom(.camera)
    }
    
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        
        DispatchQueue.main.async {
            self.customerPhotos.reloadData()
        }
        
       // UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    @IBAction func CreateCustomerAction(_ sender: Any) {
        
        createCustomer()
    }
    
    func createCustomer() {
        guard let name = CustomerName.text, name != "" else {
            error(title: "Имя обязательное поле")
            return
        }
        
        let customerSecondName = CustomerSecondName.text
        let middle_Name = CustomerMiddle.text
        let customerBirthDate = CustomerDateBirth.text ?? "" + "T00:00:00.0263+03:00"
        
        let phone = CustomerPhone.text
        let email = CustomerEmail.text
        print("customerBirthDate is \(customerBirthDate)")
        //print("customer is \(customer)")
        if customer != nil {
            let putCustomer = Customer.init(id: customer!.id, surname: customerSecondName, name: name, middle_Name: middle_Name, birth_Date: customerBirthDate, phone: phone, email: email, vK_Link: nil, iNSTA_Link: nil, is_Archive: nil)
            PUTCustomer(customer: putCustomer)
            
        } else {
            let postCustomer = Customer.init(id: 1, surname: customerSecondName, name: name, middle_Name: middle_Name, birth_Date: customerBirthDate, phone: phone, email: email, vK_Link: nil, iNSTA_Link: nil, is_Archive: nil)
            print(postCustomer)
            POSTCustomer(customer: postCustomer)
        }
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.CustomerName.delegate = self
        self.CustomerMiddle.delegate = self
        self.CustomerSecondName.delegate = self
        self.CustomerPhone.delegate = self
        self.CustomerEmail.delegate = self
        
        if customer != nil {
            CustomerName.text = customer?.name
            CustomerMiddle.text = customer?.middle_Name
            CustomerSecondName.text = customer?.surname
            CustomerEmail.text = customer?.email
            CustomerPhone.text = customer?.phone
            CustomerDateBirth.text = customer?.birth_Date?.components(separatedBy: "T")[0]
            CreateCustomer.setTitle("Редактировать клиента", for: .normal)
        }
        
        hideKeyboardWhenTappedAround() 
        
        let theDateToolBar = UIToolbar().ToolbarPiker(mySelect: #selector(CustomerInfoViewController.receiptDatedismissPicker), clear: #selector(CustomerInfoViewController.clearTheDatedismissPicker))
        CustomerDateBirth.inputAccessoryView = theDateToolBar
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        CustomerDateBirth.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(ArrivalInfoViewController.dateChanged(dateChanged:)), for: .valueChanged)
        getCustomerImage()
        // Do any additional setup after loading the view.
    }
    

    
    @objc func dateChanged(dateChanged: UIDatePicker) {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "yyyy-MM-dd"
        CustomerDateBirth.text = dateFormatted.string(from: datePicker.date)
    }
    
    @objc func receiptDatedismissPicker() {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "yyyy-MM-dd"
        CustomerDateBirth.text = dateFormatted.string(from: datePicker.date)
        //recieptDocument?.receipt_Date = dateFormatted.string(from: datePicker.date) + "T00:00:00.0263+03:00"
        //PUTReceiptDocument()
        view.endEditing(true)
    }
    
    @objc func clearTheDatedismissPicker() {
        CustomerDateBirth.text = ""
        //recieptDocument?.the_Date = nil
        //PUTReceiptDocument()
        view.endEditing(true)
    }
    
    
    func POSTCustomer(customer: Customer) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.POSTCustomer(token: token, post: customer) { (customer) in
            
            if let customer = customer, let checkRecord = self.checkRecord?.check_Id {
                DispatchQueue.main.async {
                    self.addCustomerToCheck(checkId: String(checkRecord), customerId: String(customer.id))
                    if self.goodUIImagesDict.count >= 2 {
                        for i in self.goodUIImagesDict {
                            if i.id == "new" {
                                self.uploadImageCustomer(image: i.image, customer: customer)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func PUTCustomer(customer: Customer) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.PUTCustomer(token: token, post: customer) { (customer) in
            DispatchQueue.main.async {
                self.error(title: "Клиент отредактирован")
            }
        }
    }
    
    func addCustomerToCheck(checkId: String, customerId: String) {
        let recieptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        recieptController.POSTCustomerToCheck(token: token, checkId: checkId, customerId: customerId) { (check) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "addCustomerToCheck", sender: self)
            }
        }
    }
    
    func uploadImageCustomer(image: UIImage, customer: Customer) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        addPreload(start_stop: true)
        receiptController.POSTCustomerImageAsData(token: token, image: image, customer: customer) { (postedImage) in
            if let posted = postedImage {
                DispatchQueue.main.async {
                    self.goodUIImagesDict.append(goodUIimages.init(id: String(posted.id), image: image, main: false))
                    self.customerPhotos.reloadData()
                    self.addPreload(start_stop: false)
                    // self.error(title: "товар добавлен")
                }
                print("sucess post image \(posted)")
            } else {
                DispatchQueue.main.async {
                    self.addPreload(start_stop: false)
                    self.error(title: "Одно из изображений не добавлено")
                }
            }
        }
    }
    
    func getCustomerImage() {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        if let customer = customer {
            addPreload(start_stop: true)
            receiptController.GetCustomerPhotoList(id: String(customer.id) , token: token) { (customerPhotos) in
                if let customerPhotos = customerPhotos {
                    let myGroup = DispatchGroup()
                    for i in customerPhotos {
                        myGroup.enter()
                        receiptController.getCustomerImage(customerId: String(customer.id), photoId: String(i.id) , completion: { (Image) in
                            if let image = Image {
                                print("full success get image")
                                self.goodUIImagesDict.append(goodUIimages.init(id: String(i.id), image: image, main: i.is_Main ?? false))
                                myGroup.leave()
                            }else {
                                myGroup.leave()
                            }
                        })
                    }
                    myGroup.notify(queue: .main) {
                        self.customerPhotos.reloadData()
                        self.addPreload(start_stop: false)
                    }
                }
            }
        }
    }
    
    func deleteCustomerImage(imageId: String, index: Int) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.DELETECustomerImage(token: token, imageId: imageId) { (answer) in
            if let answer = answer {
                if answer == "Товар удален" {
                    DispatchQueue.main.async {
                        self.goodUIImagesDict.remove(at: index)
                        self.customerPhotos.reloadData()
                        self.error(title: "товар удален")
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customerImageCell", for: indexPath) as! CustomerPhotosCollectionViewCell
        
        cell.customerImage.image = goodUIImagesDict[indexPath.row].image
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
        print("Selected Cell: \(indexPath.row)")
        
        if indexPath.row == 0 {
            // takeImage()
            
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                selectImageFrom(.photoLibrary)
                return
            }
            selectImageFrom(.camera)
            
        } else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (action) in
                print("delete")
                if self.customer != nil {
                        self.deleteCustomerImage(imageId: self.goodUIImagesDict[indexPath.row].id , index: indexPath.row)
                    
                } else {
                    self.customerPhotos.reloadData()
                    self.goodUIImagesDict.remove(at: indexPath.row)
                }
                //self.deleteGoodImage(imageId: self.goodUIImagesDict[indexPath.row].id, index: indexPath.row)
            }
            
            let image = goodUIImagesDict[indexPath.row].image
            alertController.addImage(image: image)
            
            
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
        var main: Bool
    }
    var goodUIImagesDict = [goodUIimages.init(id: "main", image: UIImage(named: "addPhoto")!, main: false)]
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    func addPreload(start_stop: Bool){
        if start_stop {
            activityIndicator.center = self.customerPhotos.center
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

extension CustomerInfoViewController: UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        customerImage = selectedImage
        if let customer = customer {
            uploadImageCustomer(image: selectedImage, customer: customer)
        } else {
            goodUIImagesDict.append(goodUIimages.init(id: "new", image: selectedImage, main: false))
            customerPhotos.reloadData()
        }
    }
}
