//
//  CRUD.swift
//  Drink1216
//
//  Created by change on 2021/12/25.
//

import Foundation


extension MainVC {

// 取
func fetchData(urlStr: String, completionHandler: @escaping ([Record]?) -> Void) {
    print("fetch data...")
    
    let url = URL(string: urlStr)
    var urlRequest = URLRequest(url: url!)
    urlRequest.httpMethod = "Get"
    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
        let decoder = JSONDecoder()
        if let data = data {
            do {
                let result = try decoder.decode(ResponseData.self, from: data)
                print("decode success")
                self.menuData = result.records
                completionHandler(result.records)
                DispatchQueue.main.async {
                    self.menuCollectionView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }.resume()
}

}
