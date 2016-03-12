import XCTest

extension XCTestCase
{
    public override func setUp()
    {
        super.setUp()
        print("\n\n")
    }

    public override func tearDown()
    {
        print("\n\n")
        super.tearDown()
    }

    class func loadString(resourceName: String, _ extensionName: String, filename: String = __FILE__, functionName: String = __FUNCTION__, line: Int = __LINE__) -> String
    {
        let jsonString = NSBundle(forClass: self)
            .URLForResource("TestAssets/\(resourceName)", withExtension: extensionName)
            .flatMap { try? String(contentsOfURL: $0, encoding: NSUTF8StringEncoding) }

        if jsonString == nil {
            XCTFail("\(functionName): No file (\(resourceName).\(extensionName)) found.")
        }

        return jsonString!
    }
}
