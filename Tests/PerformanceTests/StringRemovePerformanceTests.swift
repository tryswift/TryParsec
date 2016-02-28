import XCTest
import TryParsec

private var _testString = ""
private let _removalLoops = 10

class StringSplitPerformanceTests: XCTestCase
{
    override class func setUp()
    {
        super.setUp()
        for _ in 1...10000 {
            _testString.appendContentsOf("z")
        }
    }

    // Comment-Out: `removeFirst` is VERY SLOW
//    func test_USV_removeFirst()
//    {
//        self.measureBlock {
//            for _ in 1..._numberOfRemovalLoops {
//                var unicodeScalarView = _testString.unicodeScalars
//                for _ in 1..._testString.unicodeScalars.count {
//                    unicodeScalarView.removeFirst()
//                }
//            }
//        }
//    }

    // 0.010sec (fast)
    func test_USV_subscriptTailRange()
    {
        self.measureBlock {
            for _ in 1..._removalLoops {
                var unicodeScalarView = _testString.unicodeScalars
                for _ in 1..._testString.unicodeScalars.count {
                    unicodeScalarView = unicodeScalarView[unicodeScalarView.startIndex.successor()..<unicodeScalarView.endIndex]
                }
            }
        }
    }

    // 0.010sec (fast)
    func test_USV_suffixFrom_startIndexSuccessor()
    {
        self.measureBlock {
            for _ in 1..._removalLoops {
                var unicodeScalarView = _testString.unicodeScalars
                for _ in 1..._testString.unicodeScalars.count {
                    unicodeScalarView = unicodeScalarView.suffixFrom(unicodeScalarView.startIndex.successor())
                }
            }
        }
    }

    // 0.014sec (`advancedBy(1)` is slower than `successor`)
    func test_USV_suffixFrom_startIndexAdvancedBy1()
    {
        self.measureBlock {
            for _ in 1..._removalLoops {
                var unicodeScalarView = _testString.unicodeScalars
                for _ in 1..._testString.unicodeScalars.count {
                    unicodeScalarView = unicodeScalarView.suffixFrom(unicodeScalarView.startIndex.advancedBy(1))
                }
            }
        }
    }

    // Comment-Out: `removeFirst` is VERY SLOW
//    func test_CV_removeFirst()
//    {
//        self.measureBlock {
//            for _ in 1..._numberOfRemoveLoops {
//                var characterView = _testString.characters
//                for _ in 1..._testString.characters.count {
//                    characterView.removeFirst()
//                }
//            }
//        }
//    }

    // 0.068sec
    func test_CV_subscriptTailRange()
    {
        self.measureBlock {
            for _ in 1..._removalLoops {
                var characterView = _testString.characters
                for _ in 1..._testString.characters.count {
                    characterView = characterView[characterView.startIndex.successor()..<characterView.endIndex]
                }
            }
        }
    }

    // 0.066sec
    func test_CV_suffixFrom_startIndexSuccessor()
    {
        self.measureBlock {
            for _ in 1..._removalLoops {
                var characterView = _testString.characters
                for _ in 1..._testString.characters.count {
                    characterView = characterView.suffixFrom(characterView.startIndex.successor())
                }
            }
        }
    }

    // 0.067sec (`advancedBy(1)` is slower than `successor`)
    func test_CV_suffixFrom_startIndexAdvancedBy1()
    {
        self.measureBlock {
            for _ in 1..._removalLoops {
                var characterView = _testString.characters
                for _ in 1..._testString.characters.count {
                    characterView = characterView.suffixFrom(characterView.startIndex.advancedBy(1))
                }
            }
        }
    }

    // 0.031sec
    func test_NSString_substringFromIndex()
    {
        self.measureBlock {
            for _ in 1..._removalLoops {
                var str: NSString = _testString as NSString
                for _ in 1...(_testString as NSString).length {
                    str = str.substringFromIndex(1)
                }
            }
        }
    }

    // 0.015sec
    func test_NSMutableString_deleteCharactersInRange()
    {
        self.measureBlock {
            for _ in 1..._removalLoops {
                let str: NSMutableString = NSMutableString(string: _testString)
                for _ in 1...(_testString as NSString).length {
                    str.deleteCharactersInRange(NSRange(location: 0, length: 1))
                }
            }
        }
    }
}
