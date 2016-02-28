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
            _testString.appendContentsOf("z")
        }
    }

    // MARK: cons

    // Current `TryParsec.cons`.
    // 0.024sec (slower than `test_cons_String_appendContentsOf`)
    func test_cons_RRC_insert()
    {
        self.measureBlock {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._loops {
                unicodeScalarView = cons_RRC_insert("z")(unicodeScalarView)
            }
        }
    }

    // 0.389sec
    func test_cons_RRC_append()
    {
        self.measureBlock {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._loops {
                unicodeScalarView = cons_RRC_append("z")(unicodeScalarView)
            }
        }
    }

    // 0.395sec
    func test_cons_USV_append()
    {
        self.measureBlock {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._loops {
                unicodeScalarView = cons_USV_append("z")(unicodeScalarView)
            }
        }
    }

    // 0.347sec
    func test_cons_USV_appendContentsOf()
    {
        self.measureBlock {
            var unicodeScalarView = _testString.unicodeScalars
            for _ in 1..._loops {
                unicodeScalarView = cons_USV_appendContentsOf("z".unicodeScalars)(unicodeScalarView)
            }
        }
    }

    // 0.001sec (fast)
    func test_cons_String_appendContentsOf()
    {
        self.measureBlock {
            var str: String = _testString
            for _ in 1..._loops {
                str = cons_String_appendContentsOf("z")(str)
            }
        }
    }

    // 0.002sec (fast)
    func test_cons_NSString_stringByAppendingString()
    {
        self.measureBlock {
            var str: NSString = _testString
            for _ in 1..._loops {
                str = str.stringByAppendingString("z")
            }
        }
    }
}

// MARK: Functions

/// Current `TryParsec.cons`.
func cons_RRC_insert<A, C: RangeReplaceableCollectionType where C.Generator.Element == A>(x: A) -> C -> C
{
    return { xs in
        var xs = xs
        xs.insert(x, atIndex: xs.startIndex)
        return xs
    }
}

func cons_RRC_append<A, C: RangeReplaceableCollectionType where C.Generator.Element == A>(x: A) -> C -> C
{
    return { xs in
        var view = C()
        view.append(x)
        view.appendContentsOf(xs)
        return view
    }
}

func cons_USV_append(x: UnicodeScalar) -> String.UnicodeScalarView -> String.UnicodeScalarView
{
    return { xs in
        var view = String.UnicodeScalarView()
        view.append(x)
        view.appendContentsOf(xs)
        return view
    }
}

func cons_USV_appendContentsOf(xs: String.UnicodeScalarView) -> String.UnicodeScalarView -> String.UnicodeScalarView
{
    return { xs2 in
        var xs = xs
        xs.appendContentsOf(xs2)
        return xs
    }
}

func cons_String_appendContentsOf(x: UnicodeScalar) -> String -> String
{
    return { str in
        var str = String(x)
        str.appendContentsOf(str)
        return str
    }
}
