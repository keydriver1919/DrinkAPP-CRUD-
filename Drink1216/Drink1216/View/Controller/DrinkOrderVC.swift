//
//  DrinkOrderViewController.swift
//  Drink1216
//
//  Created by change on 2021/12/24.
//

import UIKit
private let reuseIdentifier = "DrinkOrderTableViewCell"

class DrinkOrderVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var customSelectionTableView: UITableView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkDescribeLabel: UILabel!
    @IBOutlet weak var orderPriceLabel: UILabel!
    @IBOutlet weak var drinkQuantityLabel: UILabel!
    @IBOutlet weak var addToOrderListButton: UIButton!
    
    var delegate: OrderListVC?
    
    var menuData: Array<Record> = []
    var ordererName: String?
    var drinkName: String!
    var drinkDescribe: String?
    var sugar: String!
    var temp: String!
    var feed = ["",""]
    var size: String!
    var drinkPrice: Int!
    var mediumPrice: Int!
    var largePrice: Int?
    var drinkQuantity = 1
    var drinkImageURL: String!
    var updateOrderData = false
    var orderDataID: String?
    
    var orderPrice: Int?
    var feedPrice = 0
    
    var sizeChecked = Array(repeating: false, count: Size.allCases.count)
    var tempChecked = Array(repeating: false, count: Temp.allCases.count)
    var sugarChecked = Array(repeating: false, count: Sugar.allCases.count)
    var feedChecked = Array(repeating: false, count: Feed.allCases.count)
    
    let apiKey = "keyeTqOp10kNwpVIp"
    let urlStr = "https://api.airtable.com/v0/appn2v5vLq94npVwP/OrderData"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDrinkData()
        display()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        OrderInfo.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let orderInfoType = OrderInfo.allCases[section]
        switch orderInfoType {
        case .size:
            return "容量"
        case .sugar :
            return "甜度"
        case .temp :
            return "溫度"
        case .feed :
            return "加料"
        case .orderer:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let orderInfoType = OrderInfo.allCases[section]
        switch orderInfoType {
        case .orderer:
            return 1
        case .size :
            return Size.allCases.count
        case .sugar :
            return Sugar.allCases.count
        case .temp :
            return Temp.allCases.count
        case .feed :
            return Feed.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let orderInfoType = OrderInfo.allCases[indexPath.section]
        
        switch orderInfoType {
        case .orderer :
            let cell = customSelectionTableView.dequeueReusableCell(withIdentifier: "OrdererTableViewCell") as! OrdererTCell
            cell.ordererLabel.text = "訂購人"
            cell.ordererNameTextField.placeholder = "請輸入名字"
            cell.ordererNameTextField.delegate = self
            guard let ordererName = ordererName else { return cell }
            cell.ordererNameTextField.text = ordererName
            return cell
        case .size :
            let cell = customSelectionTableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! DrinkOrderTCell
            cell.addPriceLabel.isHidden = true
            cell.addFeedPriceLabel.isHidden = true
            cell.selectionLabel.text = Size.allCases[indexPath.row].rawValue
            
            if sizeChecked[indexPath.row] {
                cell.radioButtonImage.image = UIImage(systemName: "checkmark.rectangle.fill")
            } else {
                cell.radioButtonImage.image = UIImage(systemName: "rectangle")
            }
            return cell
        case .sugar :
            let cell = customSelectionTableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! DrinkOrderTCell
            cell.addPriceLabel.isHidden = true
            cell.addFeedPriceLabel.isHidden = true
            cell.selectionLabel.text = Sugar.allCases[indexPath.row].rawValue
            
            if sugarChecked[indexPath.row] {
                cell.radioButtonImage.image = UIImage(systemName: "checkmark.rectangle.fill")
            } else {
                cell.radioButtonImage.image = UIImage(systemName: "rectangle")
            }
            return cell
        case .temp :
            let cell = customSelectionTableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! DrinkOrderTCell
            cell.addPriceLabel.isHidden = true
            cell.addFeedPriceLabel.isHidden = true
            cell.selectionLabel.text = Temp.allCases[indexPath.row].rawValue
            
            if tempChecked[indexPath.row] {
                cell.radioButtonImage.image = UIImage(systemName: "checkmark.rectangle.fill")
            } else {
                cell.radioButtonImage.image = UIImage(systemName: "rectangle")
            }
            return cell
        case .feed :
            let cell = customSelectionTableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! DrinkOrderTCell 
            cell.selectionLabel.text = Feed.allCases[indexPath.row].rawValue
            
            if feedChecked[indexPath.row] {
                cell.radioButtonImage.image = UIImage(systemName: "checkmark.rectangle.fill")
            } else {
                cell.radioButtonImage.image = UIImage(systemName: "rectangle")
            }
            
            cell.addPriceLabel.isHidden = false
            cell.addFeedPriceLabel.isHidden = false
            if cell.selectionLabel.text == Feed.white.rawValue {
                cell.addFeedPriceLabel.text = String(FeedPrice.white.rawValue)
            } else {
                cell.addFeedPriceLabel.text = String(FeedPrice.black.rawValue)
            }
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderInfoType = OrderInfo.allCases[indexPath.section]
        switch orderInfoType {
        case .orderer :
            return
        case .size:
            sizeChecked = Array(repeating: false, count: Size.allCases.count)
            sizeChecked[indexPath.row] = !sizeChecked[indexPath.row]
            size = Size.allCases[indexPath.row].rawValue
            if sizeChecked[indexPath.row] {
                if indexPath.row == 0 {
                    drinkPrice = mediumPrice
                } else {
                    guard let largePrice = largePrice else { return drinkPrice = mediumPrice }
                    drinkPrice = largePrice
                }
            }
            showOrderPrice()
        case .sugar:
            sugarChecked = Array(repeating: false, count: Sugar.allCases.count)
            sugarChecked[indexPath.row] = !sugarChecked[indexPath.row]
            sugar = Sugar.allCases[indexPath.row].rawValue
        case .temp:
            tempChecked = Array(repeating: false, count: Temp.allCases.count)
            tempChecked[indexPath.row] = !tempChecked[indexPath.row]
            temp = Temp.allCases[indexPath.row].rawValue
        case .feed:
            feedChecked[indexPath.row] = !feedChecked[indexPath.row]
            print(feedChecked[indexPath.row])
            if feedChecked[indexPath.row] {
                feedPrice += FeedPrice.allCases[indexPath.row].rawValue
                feed[indexPath.row] = Feed.allCases[indexPath.row].rawValue
            } else {
                feedPrice -= FeedPrice.allCases[indexPath.row].rawValue
                feed[indexPath.row] = ""
            }
            showOrderPrice()
        }
        tableView.reloadData()
    }
    
    // MARK: Display UI
    func display() {
        print("Display UI")
        if updateOrderData {
            addToOrderListButton.setTitle("修改訂單", for: .normal)
            optionCheckForUpdateMode()
        } else {
            addToOrderListButton.setTitle("加入訂單", for: .normal)
            drinkPrice = mediumPrice
        }
        showOrderPrice()
        drinkNameLabel.text = drinkName
        drinkDescribeLabel.text = drinkDescribe
    }
    
    // 設定修改模式時的optionCheck
    func optionCheckForUpdateMode() {
        sizeChecked[Size.allCases.firstIndex(of: Size(rawValue: size)!)!] = true
        sugarChecked[Sugar.allCases.firstIndex(of: Sugar(rawValue: sugar)!)!] = true
        tempChecked[Temp.allCases.firstIndex(of: Temp(rawValue: temp)!)!] = true
        for index in 0...1 {
            if let feedString = Feed(rawValue: feed[index]),
               let index = Feed.allCases.firstIndex(of: feedString) {
                feedChecked[Int(index)] = true
            }
        }
    }
    
    // 取得對應飲料的資料
    func getDrinkData() {
        guard let data = Record.readDrinkDataFromFile() else { return }
        menuData = data
        guard let drinkName = drinkName else { return }
        menuData.forEach { (Record) in
            if drinkName == Record.fields.drinkName {
                print(Record.fields)
                print("drinkName:\(drinkName)")
                self.drinkDescribe = Record.fields.describe
                self.drinkImageURL = Record.fields.drinkImage[0].url
                self.mediumPrice = Record.fields.mediumPrice
                guard let largePrice = Record.fields.largePrice else { return }
                self.largePrice = largePrice
            }
        }
    }
    
    // update mode selected size & feed will error
    func showOrderPrice() {
        print("show Order Price")
        orderPrice = (drinkPrice + feedPrice) * drinkQuantity
        drinkQuantityLabel.text = drinkQuantity.description
        orderPriceLabel.text = orderPrice?.description
    }
    
    @IBAction func addDrinkNumber(_ sender: Any) {
        drinkQuantity += 1
        drinkQuantityLabel.text = drinkQuantity.description
        showOrderPrice()
    }
    
    @IBAction func reduceDrinkNumber(_ sender: Any) {
        if drinkQuantity > 1 {
            drinkQuantity -= 1
        } else {
            drinkQuantity = 1
        }
        drinkQuantityLabel.text = drinkQuantity.description
        showOrderPrice()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        ordererName = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
    // create String for add feed label
    func feedToString() -> String {
        var feedStr = ""
        for feed in feed {
            feedStr += feed+" "
        }
        return feedStr
    }
    
    
    @IBAction func addToOrderList(_ sender: Any) {
        var addToOrderListtButtonTitle: String!
        if addToOrderListButton.titleLabel?.text == "加入訂單" {
            addToOrderListtButtonTitle = "加入訂單"
        } else {
            addToOrderListtButtonTitle = "修改訂單"
        }
        let controller = UIAlertController(title: addToOrderListtButtonTitle, message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確定", style: .default) { (_) in
            // 檢查選項
            guard self.checkOption() else { return }
            
            // 將訂單上傳至Database
            self.sentOrderRequest()
            self.dismiss(animated: true) {
                self.delegate?.updateUI()
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(confirmAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    // check option should be selected
    func checkOption() -> Bool {
        print(sizeChecked,sugarChecked,tempChecked,ordererName)
        var check = false
        sizeChecked.forEach {
            guard $0 == true else { return }
            sugarChecked.forEach {
                guard $0 == true else { return }
                tempChecked.forEach {
                    guard $0 == true else { return }
                    guard let _ = ordererName else { return }
                    check = true
                }
            }
        }
        
        if check == false {
            let controller = UIAlertController(title: "", message: "資料未填寫完全", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
        }
        return check
    }
    
}
