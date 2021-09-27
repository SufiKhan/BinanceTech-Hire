//
//  Services.swift
//  Binance Order Book
//
//  Created by sarfaraz.d.khan on 22/9/2021.
//

import Starscream
import RxSwift
import RxCocoa

protocol OrderBookServiceDelegate {
    var message: BehaviorRelay<String> {get}
    func connect(urlString: String)
    func getSnapshotFromServer(urlString: String, completion:@escaping (Result<OrderBookSnapshot, Error>) -> Void)
}

class OrderBookClient: WebSocketDelegate, OrderBookServiceDelegate {
    
    
    var message: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    private var websocket: WebSocket?
    private var isConnected = false
    
    func connect(urlString: String) {
        var request = URLRequest(url: URL(string: urlString)!)
        request.timeoutInterval = 5
        websocket = WebSocket(request: request)
        websocket?.delegate = self
        websocket?.connect()
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            isConnected = true
        case .disconnected( _,  _):
            isConnected = false
            websocket?.connect()
        case .text(let string):
            message.accept(string)
        case .binary(_): break
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            websocket?.disconnect()
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print("Error: \(String(describing: error))")
        }
    }
    
    func getSnapshotFromServer(urlString: String, completion: @escaping (Result<OrderBookSnapshot, Error>) -> Void) {
        let req = URLRequest.init(url: URL(string: urlString)!)
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if error != nil {
                completion(.failure(error!))
            }
            guard let rawData = data else {
                completion(.failure(NSError(domain:"", code:200, userInfo:nil)))
                return
            }
            guard let snapshot = try? JSONDecoder().decode(OrderBookSnapshot.self, from: rawData) else {
                return
            }
            completion(.success(snapshot))
        }.resume()
    }
}

