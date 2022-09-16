import XCTest
import Combine
@testable import UDPipe

final class UDPipeTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    func testUDPipeAnalyze() {
        let expectation = XCTestExpectation(description: "testUDPipeAnalyze")
        UDPipe.latest(language: "swedish", modelName: "lines").sink { model in
            model?.analyze(["Hej detta är ett test","Testar igen"]).sink(receiveCompletion: { err in
                XCTFail(String(describing: err))
            }, receiveValue: { response in
                XCTAssert(response.filter({ $0.response != nil}).count == 2)
                expectation.fulfill()
            }).store(in: &self.cancellables)
        }.store(in: &self.cancellables)
        wait(for: [expectation], timeout: 10.0)
    }
}
