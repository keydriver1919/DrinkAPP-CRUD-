//
//  Order.swift
//  Drink1216
//
//  Created by change on 2021/12/22.
//

import Foundation

struct OrderRecords: Codable {
    var records: [DrinkOrder]
}

struct PostDrinkOrder: Codable {
    var fields: OrderData
}


struct OrderData: Codable {
    var ordererName: String
    var drinkName: String
    var temp: String
    var sugar: String
    var size: String
    var feed: String
    var quantity: Int
    var drinkImage: String
}

struct DrinkOrder: Codable {
    var id: String
    var fields: OrderData
    var createdTime: String
}

struct DeleteData: Codable {
    var deleted: Bool
}
