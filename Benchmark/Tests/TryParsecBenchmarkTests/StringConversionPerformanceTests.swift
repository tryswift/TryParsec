import XCTest
import TryParsec

private var _testString = ""
private let _arrayConversionLoops = 10
private let _stringConversionLoops = 100000

class StringConversionPerformanceTests: XCTestCase
{
    override class func setUp()
    {
        super.setUp()
        for _ in 1...10000 {
            _testString.append("z")
        }
    }

    // MARK: View <-> Array conversion (slow)

    // 0.011sec
    func test_USV_toArray()
    {
        self.measure {
            for _ in 1..._arrayConversionLoops {
                let _ = [UnicodeScalar](_testString.unicodeScalars)
            }
        }
    }

    // 0.067sec
    func test_CV_toArray()
    {
        self.measure {
            for _ in 1..._arrayConversionLoops {
                let _ = [Character](_testString.characters)
            }
        }
    }

    // 0.076sec
    func test_USV_fromArray()
    {
        let arr = [UnicodeScalar](_testString.unicodeScalars)
        self.measure {
            for _ in 1..._arrayConversionLoops {
                let _ = String.UnicodeScalarView(arr)
            }
        }
    }

    // 0.006sec
    func test_CV_fromArray()
    {
        let arr = [Character](_testString.characters)
        self.measure {
            for _ in 1..._arrayConversionLoops {
                let _ = String.CharacterView(arr)
            }
        }
    }

    // MARK: View <-> String conversion (fast)

    // 0.000sec
    func test_USV_toString()
    {
        let view = _testString.unicodeScalars
        self.measure {
            for _ in 1..._stringConversionLoops {
                let _ = String(view)
            }
        }
    }

    // 0.001sec
    func test_CV_toString()
    {
        let view = _testString.characters
        self.measure {
            for _ in 1..._stringConversionLoops {
                let _ = String(view)
            }
        }
    }

    // 0.000sec
    func test_USV_fromString()
    {
        self.measure {
            for _ in 1..._stringConversionLoops {
                let _ = _testString.unicodeScalars
            }
        }
    }

    // 0.000sec
    func test_CV_fromString()
    {
        self.measure {
            for _ in 1..._stringConversionLoops {
                let _ = _testString.characters
            }
        }
    }
}
