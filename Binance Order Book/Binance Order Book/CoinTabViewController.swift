//
//  ViewController.swift
//  Binance Order Book
//
//  Created by sarfaraz.d.khan on 22/9/2021.
//

import UIKit

class CoinTabViewController: UIViewController {

    private var vm: OrderBookViewModel?
    private let client = MarketService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = OrderBookViewModel(client: client.orderBookService)
    }
}

