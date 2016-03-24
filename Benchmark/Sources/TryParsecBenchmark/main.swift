import Foundation
import Result
import TryParsec

func now() -> Double
{
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    return CFAbsoluteTimeGetCurrent()
#else
    var tv = timeval()
    gettimeofday(&tv, nil)
    return Double(tv.tv_sec) + Double(tv.tv_usec) * 1e-6
#endif
}

func startBenchmark<T>(f: String -> T, _ filename: String, _ fileExt: String)
{
    let jsonString = loadString(filename, fileExt)

    let startTime = now()
    for _ in 1...1000 {

        f(jsonString)

    }
    let diffTime = now() - startTime
    print(diffTime)
}

func loadString(resourceName: String, _ extensionName: String, filename: String = #file, functionName: String = #function, line: Int = #line) -> String
{
#if SWIFT_PACKAGE
    let resourceDir = "../../../TestAssets"
#else
    let resourceDir = "TestAssets"
#endif

    let jsonString = NSBundle.mainBundle()
        .URLForResource("\(resourceDir)/\(resourceName)", withExtension: extensionName)
        .flatMap { try? String(contentsOfURL: $0, encoding: NSUTF8StringEncoding) }

    if jsonString == nil {
        fatalError("\(functionName): No file (\(resourceName).\(extensionName)) found.")
    }

    return jsonString!
}

//--------------------------------------------------
// MARK: - main
//--------------------------------------------------

startBenchmark(parseJSON, "test4", "json")
//startBenchmark(parseXML, "test4", "xml")
