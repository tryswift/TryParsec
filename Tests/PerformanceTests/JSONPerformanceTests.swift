import XCTest
import Result
import Curry
import TryParsec

private var _testString = ""
private let _loops = 1000

class JSONPerformanceTests: XCTestCase
{
    override class func setUp()
    {
        _testString = self.loadString("test4", "json")
    }

    func testPerformance_TryParsec()
    {
        self.measureBlock {
            for _ in 1..._loops {
                let _ = parseJSON(_testString)
            }
        }
    }

    func testPerformance_NSJSONSerialization()
    {
        self.measureBlock {
            for _ in 1..._loops {
                let jsonData = _testString.dataUsingEncoding(NSUTF8StringEncoding)!
                let _ = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)) as? NSDictionary
            }
        }
    }
}
