//
//  OrderBookEvent.swift
//  Binance Order Book
//
//  Created by sarfaraz.d.khan on 23/9/2021.
//

import Foundation

struct OrderBookEvent: Codable {
    let welcomeE: String
    let e: Int
    let s: String
    let U, u: Int
    let b: [[String]]
    let a: [[String]]

    enum CodingKeys: String, CodingKey {
        case welcomeE = "e"
        case e = "E"
        case s
        case U = "U"
        case u = "u"
        case b, a
    }
}

struct OrderBookSnapshot: Codable {
    let lastUpdateID: Int
    let bids: [[String]]
    let asks: [[String]]
    
    enum CodingKeys: String, CodingKey {
        case lastUpdateID = "lastUpdateId"
        case bids, asks
    }
}

