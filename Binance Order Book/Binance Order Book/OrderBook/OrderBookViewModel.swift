//
//  OrderBookViewModel.swift
//  Binance Order Book
//
//  Created by sarfaraz.d.khan on 23/9/2021.
//

import RxSwift
import RxCocoa

protocol OrderBookDelegate {
    func getOrderSnapShot()
    var isBuffering: Bool {get set}
    var orderBookArray: BehaviorRelay<[OrderBookEvent]> {get}

}

class OrderBookViewModel: OrderBookDelegate {
    private let ORDER_BOOK_WS_URL = "wss://stream.binance.com:9443/ws/bnbbtc@depth"
    private let SNAPSHOT_URL = "https://api.binance.com/api/v3/depth?symbol=BNBBTC&limit=1000"
    private(set) var orderBookArray: BehaviorRelay<[OrderBookEvent]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    private let networkClient: OrderBookServiceDelegate?
    var isBuffering = true
    private var lastUpdateId: Int?
    private var bufferArray = [OrderBookEvent]()

    init(client: OrderBookServiceDelegate) {
        networkClient = client
        setUpObserverForOrderBookArray()
        networkClient?.connect(urlString: ORDER_BOOK_WS_URL)
        setUpObserverForWebSocketData()
        getOrderSnapShot()
    }
    
    func setUpObserverForOrderBookArray() {
        orderBookArray.subscribe(onNext: {
            [unowned self] array in
            
        }).disposed(by: disposeBag)
    }
    
    func setUpObserverForWebSocketData() {
        networkClient?.message.subscribe(onNext: {
            [unowned self] msg in
            if let data = msg.data(using: .utf8) {
                if let order = try? JSONDecoder().decode(OrderBookEvent.self, from: data) {
                    filterLatestOrderBook(order: order)
                }
            }
        })
        .disposed(by: disposeBag)
    }
        
    private func filterLatestOrderBook(order: OrderBookEvent) {
        if (!isBuffering) {
            guard let updatedId = lastUpdateId else {
                // if last update id is nil we do not filter anymore and display data from Websocket
                self.orderBookArray.accept([order])
                return
            }
            if (order.u <= updatedId + 1) {
                //Drop or skip the event
                return
            }
            orderBookArray.accept([order])
            _ = orderBookArray.value.map { $0.u > updatedId }
            _ = orderBookArray.value.filter{ $0.U <= updatedId + 1 && $0.u >= updatedId + 1}
            // bind array to tableview
        } else {
            orderBookArray.accept([order])
        }
    }
    
    
    func getOrderSnapShot() {
        networkClient?.getSnapshotFromServer(urlString: SNAPSHOT_URL, completion: { (result) in
            switch result {
                case .success(let data):
                    self.lastUpdateId = data.lastUpdateID
                    if let bufferEvent = self.orderBookArray.value.first {
                        if (bufferEvent.u <= data.lastUpdateID + 1) {
                            //remove or drop event from buffer
                            self.orderBookArray.accept([])
                        }
                    }
                    self.isBuffering = false
                case .failure( _):
                    self.isBuffering = false
            }
        })
    }
}
