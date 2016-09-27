import XCTest
import TryParsec

private var _testString = ""
private let _loops = 1000

class ConsPerformanceTests: XCTestCase
{
    override class func setUp()
    {
        super.setUp()
        for _ in 1...10000 {
            _testString.append("z")
        }
    }

    // MARK: cons

    // Current `TryParsec.cons`.
    // 0.024sec (slower than `test_cons_String_appendContentsOf`)
    func test_cons_RRC_insert()
    {
        self.measure {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._loops {
                unicodeScalarView = cons_RRC_insert("z")(unicodeScalarView)
            }
        }
    }

    // 0.389sec
    func test_cons_RRC_append()
    {
        self.measure {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._loops {
                unicodeScalarView = cons_RRC_append("z")(unicodeScalarView)
            }
        }
    }

    // 0.395sec
    func test_cons_USV_append()
    {
        self.measure {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._loops {
                unicodeScalarView = cons_USV_append("z")(unicodeScalarView)
            }
        }
    }

    // 0.347sec
    func test_cons_USV_appendContentsOf()
    {
        self.measure {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._loops {
                unicodeScalarView = cons_USV_appendContentsOf("z".unicodeScalars)(unicodeScalarView)
            }
        }
    }

    // 0.001sec (fast)
    func test_cons_String_appendContentsOf()
    {
        self.measure {
            var str: String = _testString
            for _ in 1..._loops {
                str = cons_String_appendContentsOf("z")(str)
            }
        }
    }

    // 0.002sec (fast)
    func test_cons_NSString_stringByAppendingString()
    {
        self.measure {
            var str: NSString = _testString as NSString
            for _ in 1..._loops {
                str = str.appending("z") as NSString
            }
        }
    }
}

// MARK: Functions

/// Current `TryParsec.cons`.
func cons_RRC_insert<A, C: RangeReplaceableCollection>(_ x: A) -> (C) -> C
    where C.Iterator.Element == A
{
    return { xs in
        var xs = xs
        xs.insert(x, at: xs.startIndex)
        return xs
    }
}

func cons_RRC_append<A, C: RangeReplaceableCollection>(_ x: A) -> (C) -> C
    where C.Iterator.Element == A
{
    return { xs in
        var view = C()
        view.append(x)
        view.append(contentsOf: xs)
        return view
    }
}

func cons_USV_append(_ x: UnicodeScalar) -> (String.UnicodeScalarView) -> String.UnicodeScalarView
{
    return { xs in
        var view = String.UnicodeScalarView()
        view.append(x)
        view.append(contentsOf: xs)
        return view
    }
}

func cons_USV_appendContentsOf(_ xs: String.UnicodeScalarView) -> (String.UnicodeScalarView) -> String.UnicodeScalarView
{
    return { xs2 in
        var xs = xs
        xs.append(contentsOf: xs2)
        return xs
    }
}

func cons_String_appendContentsOf(_ x: UnicodeScalar) -> (String) -> String
{
    return { str2 in
        var str = String(x)
        str.append(str2)
        return str
    }
}
