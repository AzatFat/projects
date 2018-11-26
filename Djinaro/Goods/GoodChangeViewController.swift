//
//  GoodChangeViewController.swift
//  Djinaro
//
//  Created by Azat on 20.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodChangeViewController: UIViewController {

    @IBOutlet var GoodName: UITextField!
    
    @IBOutlet var GoodLocation: UITextField!
    
    @IBOutlet var GoodPrice: UITextField!
    
    @IBOutlet var GoodType: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
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
         let newGood = Goods.init(id: 1, group_Goods_Id: nil, name: name, code: nil, description: nil, location: location, vendor_Code: nil, groupGoods: nil, type_Goods_Id: typeGoodId, type_Goods: nil, available_sizes: nil, price: Decimal(string: price))
           createGood(good:newGood)
        }
    }
    
    var good: Goods?
    var typeGoodId = 0
    private let pickerView = ToolbarPickerView()
    var pickerData: [TypeGoods] = []
    
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
        } else {
            saveButton.setTitle("Создать товар", for: .normal)
        }
        
        hideKeyboardWhenTappedAround()
        
        
        self.GoodType.inputView = self.pickerView
        self.GoodType.inputAccessoryView = self.pickerView.toolbar
        
        self.pickerView.dataSource = self as? UIPickerViewDataSource
        self.pickerView.delegate = self as? UIPickerViewDelegate
        self.pickerView.toolbarDelegate = self as? ToolbarPickerViewDelegate
        
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
                    self.error(title: "Товар успешно создан")
                    self.saveButton.setTitle("Изменить товар", for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.error(title: "Произjшла ошибка при создании товара")
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
