//
//  OrderListViewController.swift
//  Drink1216
//
//  Created by change on 2021/12/24.
//

import UIKit
private let reuseIdentifier = "OrderListTableViewCell"

class OrderListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {
    
    @IBOutlet weak var orderListTableView: UITableView!
    @IBOutlet weak var totalQuatityLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    let urlStr = "https://api.airtable.com/v0/appn2v5vLq94npVwP/OrderData"

    var menuData: Array<Record> = []
    var orderDrinkData = [DrinkOrder]()
    var loadingActivityIndicator: UIActivityIndicatorView!
    
    var mediumPrice: Int?
    var largePrice: Int?
    var feedArr = ["",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoadingView()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("enter viewWillAppear")
        updateUI()
    }
    
    // MARK: Setting TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orderDrinkData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! OrderListTCell
        
        // 取得orderData
        let orderData = orderDrinkData[indexPath.row].fields
        let orderName = orderData.ordererName
        let drinkName = orderData.drinkName
        let drinkSize = orderData.size
        let drinkSugar = orderData.sugar
        let drinkTemp = orderData.temp
        let addFeed = orderData.feed
        let quantity = orderData.quantity
        
        // 取得對應的飲料資訊
        getDrinkData(drinkName: drinkName)
        
        let orderPrice = getOrderPrice(drinkSize: drinkSize, feed: addFeed, drinkQuantity: quantity)
       
        // 設定cell顯示
        cell.ordererNameLabel.text = orderName
        cell.drinkNameLabel.text = drinkName
        cell.drinkSizeLabel.text = drinkSize
        cell.drinkSugarLabel.text = drinkSugar
        cell.drinkTempLabel.text = drinkTemp
        cell.drinkAddFeedLabel.text = "加料：" + addFeed
        cell.drinkPriceLabel.text = orderPrice.description
        cell.drinkQuantityLabel.text = quantity.description
        
        if let imageUrl = URL(string: orderData.drinkImage) {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.drinkImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let controller = UIAlertController(title: "確定要刪除嗎?", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                let dataID = self.orderDrinkData[indexPath.row].id
                self.deleteData(urlStr: self.urlStr, id: dataID) {
                    print("remove arr Data")
                    self.orderDrinkData.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.initTotal()
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: UPDATE UI
    func updateUI() {
        print("updateUI")
        // get all Drink Data
        guard let data = Record.readDrinkDataFromFile() else { return }
        menuData = data
        
        // get drinkOrder Data
        fetchData(urlStr: urlStr) { (orderData) in
            print("fetch success")
            guard let orderData = orderData else { return }
            self.orderDrinkData = orderData
            DispatchQueue.main.async {
                print("enter main queue")
                self.loadingActivityIndicator.stopAnimating()
                self.initTotal()
                self.orderListTableView.reloadData()
            }
        }
    }
    
    func createLoadingView() {
        loadingActivityIndicator = UIActivityIndicatorView(style: .medium)
        loadingActivityIndicator.center = view.center
        view.addSubview(loadingActivityIndicator)
    }
    
    // 計算總杯數與總金額
    func initTotal() {
        var totalQuantity = 0
        var totalPrice = 0
        
        // 計算總杯數
        orderDrinkData.forEach { (DrinkOrder) in
            totalQuantity += DrinkOrder.fields.quantity
        }
        
        // 計算總金額
        if orderDrinkData.count > 0 {
            for index in 0...(orderDrinkData.count - 1) {
                getDrinkData(drinkName: orderDrinkData[index].fields.drinkName)
                let drinkSzie = orderDrinkData[index].fields.size
                let feed = orderDrinkData[index].fields.feed
                let drinkQuantity = orderDrinkData[index].fields.quantity
                totalPrice += getOrderPrice(drinkSize: drinkSzie, feed: feed, drinkQuantity: drinkQuantity)
            }
        }
        
        self.totalQuatityLabel.text = totalQuantity.description
        self.totalPriceLabel.text = totalPrice.description
    }
    
    // 取得飲料資料
    func getDrinkData(drinkName: String) {
        menuData.forEach { (Record) in
            if drinkName == Record.fields.drinkName {
                self.mediumPrice = Record.fields.mediumPrice
                guard let largePrice = Record.fields.largePrice else { return }
                self.largePrice = largePrice
            }
        }
    }
    
    // 取得飲料價格
    func getDrinkPrice(drinkSize: String) -> Int {
        var drinkPrice = 0
        if drinkSize == "中杯" {
            drinkPrice = mediumPrice!
        } else {
            drinkPrice = largePrice!
        }
        return drinkPrice
    }
    
    // 取得加料價格
    func getFeedPrice(feed: String) -> Int {
        var feedPrice = 0
        
        // 將feed由String轉為Array
        if feed == "  " {
            feedArr = ["",""]
        } else {
            feedArr = feed.components(separatedBy: " ")
        }
        
        return feedPrice
    }
    
    // 取得每筆訂單價格
    func getOrderPrice(drinkSize: String, feed: String, drinkQuantity: Int) -> Int {
        let feedPrice = getFeedPrice(feed: feed)
        let drinkPrice = getDrinkPrice(drinkSize: drinkSize)
        let orderPrice = (drinkPrice + feedPrice) * drinkQuantity
        return orderPrice
    }
    

    

    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let row = orderListTableView.indexPathForSelectedRow?.row,
           let controller = segue.destination as? DrinkOrderVC {
            controller.delegate = self
            let selectedOrderDrinkData = self.orderDrinkData[row]
            let drinkSize = selectedOrderDrinkData.fields.size
            let addFeed = selectedOrderDrinkData.fields.feed
            
            // 將DrinkOrderView改為修改訂單模式
            controller.updateOrderData = true
            
            controller.orderDataID = selectedOrderDrinkData.id
            controller.ordererName = selectedOrderDrinkData.fields.ordererName
            controller.drinkName = selectedOrderDrinkData.fields.drinkName
            controller.size = drinkSize
            controller.temp = selectedOrderDrinkData.fields.temp
            controller.sugar = selectedOrderDrinkData.fields.sugar
            controller.drinkPrice = getDrinkPrice(drinkSize: drinkSize)
            controller.feedPrice = getFeedPrice(feed: addFeed)
            controller.drinkQuantity = selectedOrderDrinkData.fields.quantity
            
            // 將feed從String轉為[String]
            let feed = selectedOrderDrinkData.fields.feed
            print(feed)
            guard feed != "  " else {
                print("enter guard")
                return controller.feed = ["",""]
            }
            controller.feed = feed.components(separatedBy: " ")
        }
    }
}
