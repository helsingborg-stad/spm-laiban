import XCTest
import Combine
@testable import SharedActivities

final class SharedActivitiesTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    func testExample() {
        let expectation = XCTestExpectation(description: "asynctest")
        
        SharedActivity.fetch().sink { c in
            switch c {
            case .failure(let err): XCTFail(err.localizedDescription)
            case .finished: break;
            }
        } receiveValue: { activities in
            XCTAssertTrue(activities.count == 2)
            if let a = activities.first {
                XCTAssertTrue(a.tags.contains("undpGoal1"))
            } else {
                XCTFail("missing tag undpGoal1")
            }
            expectation.fulfill()
        }.store(in: &cancellables)
        wait(for: [expectation], timeout: 10.0)
    }
}
