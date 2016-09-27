import XCTest
import TryParsec

private var _testString = ""
private let _firstLoops = 100000
private let _unconsLoops = 10000

class UnconsPerformanceTests: XCTestCase
{
    override class func setUp()
    {
        super.setUp()
        for _ in 1...10000 {
            _testString.append("z")
        }
    }

    // MARK: First

    // 0.056sec
    func test_first_String()
    {
        self.measure {
            for _ in 1..._firstLoops {
                let _ = _testString[_testString.startIndex]
            }
        }
    }

    // 0.004sec (fast)
    func test_first_UnicodeScalarView()
    {
        self.measure {
            for _ in 1..._firstLoops {
//                let _ = _testString.unicodeScalars.first    // 0.004sec
                let _ = _testString.unicodeScalars[_testString.unicodeScalars.startIndex]   // 0.004sec
            }
        }
    }

    // 0.048sec
    func test_first_CharacterView()
    {
        self.measure {
            for _ in 1..._firstLoops {
//                let _ = _testString.characters.first    // 0.072sec (this is slow... interesting)
                let _ = _testString.characters[_testString.characters.startIndex]   // 0.048sec

            }
        }
    }

    // 0.016sec
    func test_first_NSString()
    {
        let str = _testString as NSString
        self.measure {
            for _ in 1..._firstLoops {
                let _ = str.substring(to: 1)
            }
        }
    }

    // MARK: Uncons

    // Current `TryParsec.uncons`.
    // 0.001sec (fast)
    func test_uncons_UnicodeScalarView()
    {
        self.measure {
            for _ in 1..._unconsLoops {
                let _ = uncons_first_suffixFrom(_testString.unicodeScalars)
            }
        }
    }

    /// 0.012sec
    func test_uncons_CharacterView()
    {
        self.measure {
            for _ in 1..._unconsLoops {
                let _ = uncons_first_suffixFrom(_testString.characters)
            }
        }
    }

    // Comment-Out: `removeFirst` is VERY SLOW
//    // 0.033sec for `_loops=100`
//    func test_uncons_removeFirst_UnicodeScalarView()
//    {
//        self.measure {
//            for _ in 1..._unconsLoops {
//                let _ = uncons_removeFirst(_testString.unicodeScalars)
//            }
//        }
//    }

    // MARK: Split

    // 0.002sec (fast)
    func test_split_UnicodeScalarView()
    {
        self.measure {
            for _ in 1..._unconsLoops {
                let _ = split_ranges(_testString.unicodeScalars)
            }
        }
    }

    // 0.020sec
    func test_split_CharacterView()
    {
        self.measure {
            for _ in 1..._unconsLoops {
                let _ = split_ranges(_testString.characters)
            }
        }
    }

    // 0.004sec (fast)
    func test_split_NSString()
    {
        let str: NSString = _testString as NSString
        self.measure {
            for _ in 1..._unconsLoops {
                let _ = (str.substring(to: 1), str.substring(from: 1))
            }
        }
    }
}

// MARK: Functions

/// Current `TryParsec.uncons`.
func uncons_first_suffixFrom<C: Collection>(_ xs: C) -> (C.Iterator.Element, C.SubSequence)?
{
    if let head = xs.first {
        return (head, xs.suffix(from: xs.index(after: xs.startIndex)))
    }
    else {
        return nil
    }
}

func uncons_removeFirst<A, C: RangeReplaceableCollection>(_ xs: C) -> (A, C)?
    where C.Iterator.Element == A
{
    if xs.first != nil {
        var xs = xs
        let head = xs.removeFirst()
        return (head, xs)
    }
    else {
        return nil
    }
}

func split_ranges<A, C: Collection>(_ xs: C) -> (C.SubSequence, C.SubSequence)?
    where C.Iterator.Element == A
{
    if xs.first != nil {
        let index1 = xs.index(after: xs.startIndex)
        return (xs[xs.startIndex..<index1], xs[index1..<xs.endIndex])
    }
    else {
        return nil
    }
}
