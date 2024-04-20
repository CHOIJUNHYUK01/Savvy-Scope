//
//  Marketcap.swift
//  StockSavvy
//
//  Created by CHOIJUNHYUK on 4/14/24.
//

import Foundation

struct MarketcapCorp {
    var title: String
    var symbol: String
    var marketcap: String
    var currentPrice: String
    var arise: Bool
    var rank: Int32
    var date: Date
}

struct FirebaseData {
    var name: String
    var symbol: String
    var arise: Int
    var capital: String
    var price: String
}
