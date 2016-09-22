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
            _testString.append("z")
        }
    }

    // Comment-Out: `removeFirst` is VERY SLOW
//    func test_USV_removeFirst()
//    {
//        self.measure {
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
        self.measure {
            for _ in 1..._removalLoops {
                var unicodeScalarView = _testString.unicodeScalars
                for _ in 1..._testString.unicodeScalars.count {
                    let index1 = unicodeScalarView.index(after: unicodeScalarView.startIndex)
                    unicodeScalarView = unicodeScalarView[index1..<unicodeScalarView.endIndex]
                }
            }
        }
    }

    // 0.010sec (fast)
    func test_USV_suffixFrom_startIndexSuccessor()
    {
        self.measure {
            for _ in 1..._removalLoops {
                var unicodeScalarView = _testString.unicodeScalars
                for _ in 1..._testString.unicodeScalars.count {
                    let index1 = unicodeScalarView.index(after: unicodeScalarView.startIndex)
                    unicodeScalarView = unicodeScalarView.suffix(from: index1)
                }
            }
        }
    }

    // 0.014sec (`advancedBy(1)` is slower than `successor`)
    func test_USV_suffixFrom_startIndexAdvancedBy1()
    {
        self.measure {
            for _ in 1..._removalLoops {
                var unicodeScalarView = _testString.unicodeScalars
                for _ in 1..._testString.unicodeScalars.count {
                    let index1 = unicodeScalarView.index(unicodeScalarView.startIndex, offsetBy: 1)
                    unicodeScalarView = unicodeScalarView.suffix(from: index1)
                }
            }
        }
    }

    // Comment-Out: `removeFirst` is VERY SLOW
//    func test_CV_removeFirst()
//    {
//        self.measure {
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
        self.measure {
            for _ in 1..._removalLoops {
                var characterView = _testString.characters
                for _ in 1..._testString.characters.count {
                    let index1 = characterView.index(after: characterView.startIndex)
                    characterView = characterView[index1..<characterView.endIndex]
                }
            }
        }
    }

    // 0.066sec
    func test_CV_suffixFrom_startIndexSuccessor()
    {
        self.measure {
            for _ in 1..._removalLoops {
                var characterView = _testString.characters
                for _ in 1..._testString.characters.count {
                    let index1 = characterView.index(after: characterView.startIndex)
                    characterView = characterView.suffix(from: index1)
                }
            }
        }
    }

    // 0.067sec (`advancedBy(1)` is slower than `successor`)
    func test_CV_suffixFrom_startIndexAdvancedBy1()
    {
        self.measure {
            for _ in 1..._removalLoops {
                var characterView = _testString.characters
                for _ in 1..._testString.characters.count {
                    let index1 = characterView.index(characterView.startIndex, offsetBy: 1)
                    characterView = characterView.suffix(from: index1)
                }
            }
        }
    }

    // 0.031sec
    func test_NSString_substringFromIndex()
    {
        self.measure {
            for _ in 1..._removalLoops {
                var str: NSString = _testString as NSString
                for _ in 1...(_testString as NSString).length {
                    str = str.substring(from: 1) as NSString
                }
            }
        }
    }

    // 0.015sec
    func test_NSMutableString_deleteCharactersInRange()
    {
        self.measure {
            for _ in 1..._removalLoops {
                let str: NSMutableString = NSMutableString(string: _testString)
                for _ in 1...(_testString as NSString).length {
                    str.deleteCharacters(in: NSRange(location: 0, length: 1))
                }
            }
        }
    }
}
