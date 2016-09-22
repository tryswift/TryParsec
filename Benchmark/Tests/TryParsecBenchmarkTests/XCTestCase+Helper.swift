import XCTest

extension XCTestCase
{
    open override func setUp()
    {
        super.setUp()
        print("\n\n")
    }

    open override func tearDown()
    {
        print("\n\n")
        super.tearDown()
    }

    class func loadString(_ resourceName: String, _ extensionName: String, filename: String = #file, functionName: String = #function, line: Int = #line) -> String
    {
        let jsonString = Bundle(for: self)
            .url(forResource: "TestAssets/\(resourceName)", withExtension: extensionName)
            .flatMap { try? String(contentsOf: $0, encoding: .utf8) }

        if jsonString == nil {
            XCTFail("\(functionName): No file (\(resourceName).\(extensionName)) found.")
        }

        return jsonString!
    }
}
