import XCTest
import Curry
import TryParsec

private var _testString = ""
private let _loops = 100

class JSONPerformanceTests: XCTestCase
{
    override class func setUp()
    {
        _testString = self.loadString("test4", "json")
    }

    func testPerformance_TryParsec()
    {
        self.measure {
            for _ in 1..._loops {
                let _ = parseJSON(_testString)
            }
        }
    }

    func testPerformance_NSJSONSerialization()
    {
        self.measure {
            for _ in 1..._loops {
                let jsonData = _testString.data(using: .utf8)!
                let _ = (try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)) as? NSDictionary
            }
        }
    }
}
