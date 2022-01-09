//
//  File.swift
//  Drink1216
//
//  Created by change on 2021/12/25.
//

import Foundation


extension OrderListVC{

// 取
func fetchData(urlStr: String, completionHandler: @escaping ([DrinkOrder]?) -> Void) {
    print("fetch data...")
    if let url = URL(string: urlStr) {
        loadingActivityIndicator.startAnimating()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "Get"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let result = try decoder.decode(OrderRecords.self, from: data)
                    
                    // 將訂單資料陣列依建立時間排序
                    let records = result.records.sorted {
                        $0.createdTime < $1.createdTime
                    }
                    print("decode success")
                    completionHandler(records)
                } catch {
                    completionHandler(nil)
                    print(error)
                }
            }
        }.resume()
    }
}

// 刪
func deleteData(urlStr: String, id: String,completionHandler: @escaping () -> Void) {
    print("delete Data")
    let deleteUrlStr = urlStr + "/\(id)"
    if let url = URL(string: deleteUrlStr) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, res, err) in
            if let data = data {
                do {
                    let dic = try JSONDecoder().decode(DeleteData.self, from: data)
                    print(dic)
                    print("delete down")
                    completionHandler()
                } catch {
                        print(error)
                }
            }
        }.resume()
    }
}
}
