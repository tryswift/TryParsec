import XCTest
import TryParsecExperiment

private var _testString = ""
private let _loops = 100

class ParsecTests: XCTestCase {
    
    func testExample() {
        let r = parseArithmetic("1")
        XCTAssertEqual(r, 1)
    }

    override class func setUp() {
        _testString = self.loadString("test4", "json")
    }

    func testPerformance_TryParsecExperiment() {
        self.measureBlock {
            for _ in 1..._loops {
                let _ = parseJSON(_testString)
            }
        }
    }

    func testPerformance_NSJSONSerialization() {
        self.measureBlock {
            for _ in 1..._loops {
                let jsonData = _testString.dataUsingEncoding(NSUTF8StringEncoding)!
                let _ = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)) as? NSDictionary
            }
        }
    }
}
