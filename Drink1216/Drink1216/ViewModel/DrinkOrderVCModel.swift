//
//  File2.swift
//  Drink1216
//
//  Created by change on 2021/12/25.
//

import Foundation

extension DrinkOrderVC{
    
    //更新
    func sentOrderRequest() {
        // 建立drinkOrder物件
        let orderData = OrderData(ordererName: ordererName!, drinkName: drinkName, temp: temp, sugar: sugar, size: size, feed: feedToString(), quantity: drinkQuantity, drinkImage: drinkImageURL)
        let drinkOrder = PostDrinkOrder(fields: orderData)
        
        // set request method ＆ content type
        let url: URL?
        if updateOrderData {
            guard let id = orderDataID else { return }
            let updateURL = urlStr + "/\(id)"
            url = URL(string: updateURL)!
        } else {
            url = URL(string: urlStr)!
        }
        
        var urlRequest = URLRequest(url: url!)
        if updateOrderData {
            urlRequest.httpMethod = "PUT"
        } else {
            urlRequest.httpMethod = "POST"
        }
        
        // set HTTPHeaderField
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 搭配jsonEncoder將自訂型別變成JSON格式的Data
        let jsonEncoder = JSONEncoder()
        print("bulid jsonEncoder")
        if let data = try? jsonEncoder.encode(drinkOrder) {
            print("try json encoder")
            URLSession.shared.uploadTask(with: urlRequest, from: data) { (retData, res, err) in
                // 檢查是否上傳成功
                if let response = res as? HTTPURLResponse,
                   response.statusCode == 200,
                   err == nil {
                    print("success")
                } else {
                    print(err)
                    
                }
            }.resume()
        }
    }
}
