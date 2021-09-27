//
//  MarkerServices.swift
//  Binance Order Book
//
//  Created by sarfaraz.d.khan on 22/9/2021.
//

import Foundation

protocol MarketServicesDelegate {
    var orderBookService: OrderBookServiceDelegate { get }
//    var marketHistoryService: OrderBookServiceDelegate { get }
}

class MarketService: MarketServicesDelegate {
    
    private let MARKET_HISTORY = "https://www.binance.com/api/v1/aggTrades?limit=80&symbol=BTCUSDT"
    private(set) var orderBookService: OrderBookServiceDelegate
    
    init() {
        orderBookService = OrderBookClient()
//        marketHistoryService = WebSocketService(url: MARKET_HISTORY)
    }
}
