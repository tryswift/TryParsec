import XCTest
import TryParsec

private var _testString = ""
private let _appendCharLoops = 100000
private let _appendStringLoops = 100

class StringAppendPerformanceTests: XCTestCase
{
    override class func setUp()
    {
        super.setUp()
        for _ in 1...10000 {
            _testString.append("z")
        }
    }

    // MARK: Append char

    // 0.005sec (fast)
    func test_String_appendContentsOf_one()
    {
        self.measure {
            var str = _testString
            for _ in 1..._appendCharLoops {
                str.append("z")
            }
        }
    }

    // Comment-Out: `string.append(unicodeScalar)` is not available in Swift 3...
//    // 0.005sec (fast)
//    func test_String_append_unicodeScalar()
//    {
//        self.measure {
//            var str = _testString
//            for _ in 1..._appendCharLoops {
//                str.append("z" as UnicodeScalar)
//            }
//        }
//    }

    // 0.043sec
    func test_String_append_char()
    {
        self.measure {
            var str = _testString
            for _ in 1..._appendCharLoops {
                str.append("z" as Character)
            }
        }
    }

    // 0.023sec
    func test_String_interpolation()
    {
        self.measure {
            var str = _testString
            for _ in 1..._appendCharLoops {
                str = "\(str)z"
            }
        }
    }

    // 0.004sec (fast)
    func test_USV_append()
    {
        self.measure {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._appendCharLoops {
                unicodeScalarView.append("z" as UnicodeScalar)
            }
        }
    }

    // 0.052sec
    func test_CV_append()
    {
        self.measure {
            var characterView = _testString.characters
            for _ in 1..._appendCharLoops {
                characterView.append("z" as Character)
            }
        }
    }

    // MARK: Append string

    // 0.000sec (fast)
    func test_String_appendContentsOf()
    {
        self.measure {
            var str = _testString
            for _ in 1..._appendStringLoops {
                str.append(_testString)
            }
        }
    }

    // 0.048sec
    func test_USV_appendContentsOf()
    {
        self.measure {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._appendStringLoops {
                unicodeScalarView.append(contentsOf: _testString.unicodeScalars)
            }
        }
    }

    // 0.000sec (fast)
    func test_USV_appendContentsOf_viaString()
    {
        let view = _testString.unicodeScalars
        self.measure {
            var str = String(view)
            for _ in 1..._appendStringLoops {
                str.append(String(view))
            }
            let _ = str.unicodeScalars
        }
    }

    // 0.780sec
    func test_CV_appendContentsOf()
    {
        self.measure {
            var characterView = _testString.characters
            for _ in 1..._appendStringLoops {
                characterView.append(contentsOf: _testString.characters)
            }
        }
    }

    // 0.000sec
    func test_CV_appendContentsOf_viaString()
    {
        let view = _testString.characters
        self.measure {
            var str = String(view)
            for _ in 1..._appendStringLoops {
                str.append(String(view))
            }
            let _ = str.characters
        }
    }

    // 0.047sec
    func test_NSString_stringByAppendingString()
    {
        self.measure {
            var str: NSString = _testString as NSString
            for _ in 1..._appendStringLoops {
                str = str.appending(_testString) as NSString
            }
        }
    }

    // 0.001sec
    func test_NSMutableString_appendString()
    {
        self.measure {
            let str: NSMutableString = NSMutableString(string: _testString)
            for _ in 1..._appendStringLoops {
                str.append(_testString)
            }
        }
    }
}
