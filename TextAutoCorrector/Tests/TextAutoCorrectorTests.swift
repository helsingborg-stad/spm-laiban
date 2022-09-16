    import XCTest
    @testable import TextAutoCorrector

    final class TextAutoCorrectorTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            let locale = Locale(identifier: "sv")
            var db = [Locale:[String]]()
            db[locale] = ["pynka"]
            let a = TextAutoCorrector(ignore:db)
            let val = a.correct(text:"Hej,mitt namm är Tomas Green och jag har fått pynka på cykeln",locale: locale)
            let val2 = "Hej, mitt namn är Tomas Green och jag har fått pynka på cykeln."
            print(val)
            XCTAssertTrue(val == val2)
        }
    }
