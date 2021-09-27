import XCTest
import RxCocoa
import RxSwift
@testable import Binance_Order_Book

class OrderBookViewModelTests: XCTestCase {
    
    fileprivate var orderVm: OrderBookDelegate?
    let mockWs = MockWebSocket()
    
    override func setUp() {
        orderVm = OrderBookViewModel(client: mockWs)
    }
    
    override func tearDown() {
        
    }
    
    func testWebSocketObserverWhenBuffering() {
        orderVm?.isBuffering = true
        mockWs.feedMessageFromWebSocket()
        XCTAssertEqual(orderVm?.orderBookArray.value.count, 1)
    }
    
    func testOrderEventOlderThanLastUpdatedId() {
        orderVm?.getOrderSnapShot()
        mockWs.checkWithNewEvents = false
        mockWs.feedMessageFromWebSocket()
        XCTAssertEqual(orderVm?.orderBookArray.value.count, 0)

    }
    
    func testOrderEventsFilter() {
        orderVm?.getOrderSnapShot()
        mockWs.checkWithNewEvents = true
        mockWs.feedMessageFromWebSocket()
        XCTAssertEqual(orderVm?.orderBookArray.value.count, 1)
    }
}

class MockWebSocket: OrderBookServiceDelegate {
    
    var checkWithNewEvents = false
    
    func getSnapshotFromServer(urlString: String, completion: @escaping (Result<OrderBookSnapshot, Error>) -> Void) {
        let snapshot = """
                                        {"lastUpdateId":2224895241,"bids":[["0.00840800","0.13000000"],["0.00839900","20.75500000"]],
                                        "asks":[["0.00841800","10.89200000"]]}
                                 """
        if let data = snapshot.data(using: .utf8) {
            if let apiSnapshot = try? JSONDecoder().decode(OrderBookSnapshot.self, from: data) {
                completion(.success(apiSnapshot))
            }
        }
    }


    func connect(urlString : String) {

    }

    var message: BehaviorRelay<String> = BehaviorRelay<String>(value:"")

    func feedMessageFromWebSocket() {
        var payload = ""
        if (!checkWithNewEvents)  {
            payload = """
                                        {"e": "depthUpdate","E": 123456789,"s": "BNBBTC","U": 157,"u": 2224893798,"b": [["0.0024","10"]],
                                        "a": [["0.0026","100"]]}
                                """
        } else {
            payload = """
                                        {"e": "depthUpdate","E": 1632647909917,"s": "BNBBTC","U": 2225053024,"u": 2225053076,"b": [["0.0024","10"]],
                                        "a": [["0.0026","100"]]}
                                """

        }

        message.accept(payload)
    }
}
