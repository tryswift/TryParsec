import Foundation
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

func startBenchmark<T>(_ f: (String) -> T, _ filename: String, _ fileExt: String)
{
    let jsonString = loadString(filename, fileExt)

    let startTime = now()
    for _ in 1...1000 {

        _ = f(jsonString)

    }
    let diffTime = now() - startTime
    print(diffTime)
}

func loadString(_ resourceName: String, _ extensionName: String, _ filename: String = #file, _ functionName: String = #function, _ line: Int = #line) -> String
{
#if SWIFT_PACKAGE
    let resourceDir = "../../../TestAssets"
#else
    let resourceDir = "TestAssets"
#endif

    let jsonString = Bundle.main
        .url(forResource: "\(resourceDir)/\(resourceName)", withExtension: extensionName)
        .flatMap { try? String(contentsOf: $0, encoding: .utf8) }

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
