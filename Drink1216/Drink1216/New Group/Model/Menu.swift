//
//  Response.swift
//  Drink1216
//
//  Created by change on 2021/12/16.
//

import Foundation

struct ResponseData: Codable {
    let records: [Record]
}

struct Record: Codable {
    let id: String
    let fields: Field
    
    //儲存一個臨時擋
    static func saveToFile(records: [Record]) {
        print("save Drink Data")
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(records) {
            // 產生一個UserDefaults物件
            let userDefault = UserDefaults.standard
            userDefault.set(data, forKey: "records")
        }
    }

    static func readDrinkDataFromFile() -> [Record]? {
        print("read Drink Data")
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: "records"),
           let records = try? decoder.decode([Record].self, from: data) {
            return records
        } else {
            return nil
        }
    }
}

struct Field: Codable {
    let drinkName: String
    let mediumPrice: Int
    let largePrice: Int?
    let describe: String?
    
    let drinkImage: [DrinkImage]
    struct DrinkImage: Codable {
        let url: String
    }
}


