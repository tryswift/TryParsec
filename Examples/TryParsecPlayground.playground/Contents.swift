/*:
### Note

To run Xcode playground,

1. Fetch all dependencies (including `Curry`, test-dependency)
2. Open `Tryparsec.xcworkspace`
3. Build `TryParsecBenchmark` (contains `Curry`) with `destination = Mac`

or, use https://github.com/fastlane/fastlane :

1. `fastlane play`
*/

import Cocoa
import Result
import Curry  // test-dependency
import TryParsec

//--------------------------------------------------
// Arithmetic
//--------------------------------------------------

func testArithmetic()
{
    let result = parseArithmetic(" ( 12 + 3 )         * 4+5").value!
    print("arith =", result, "\n")
}
testArithmetic()

//--------------------------------------------------
// CSV
//--------------------------------------------------

func testCSV()
{
    let result = parseCSV("foo,bar,baz\r\n1,22,333\r\n").value!
    print("csv =", result, "\n")
}
testCSV()

//--------------------------------------------------
// XML
//--------------------------------------------------

func testXML()
{
    let result = parseXML("<p class=\"welcome\"><a href=\"underground.html\" target=\"_blank\">Hello</a><?php echo ' Cruel'; ?> World<!-- 💀 --><![CDATA[💣->😇]]></p>").value!
    print("xml =", result, "\n")
}
testXML()

//--------------------------------------------------
// JSON
//--------------------------------------------------

struct Model: FromJSON, ToJSON
{
    let string: String
    let array: [Any]?

    static func fromJSON(json: JSON) -> Result<Model, JSON.ParseError>
    {
        return curry(self.init)
            <^> json !! "string"
            <*> json !? "array"
    }

    static func toJSON(model: Model) -> JSON
    {
        return toJSONObject([
            "string" ~ model.string,
            "array" ~ model.array
        ])
    }
}

func testJSON()
{
    let jsonString = "{ \"string\" : \"hello\", \"array\" : [1, \"two\", [true, null]] }"

    // JSON String -> JSON AST
    let json = parseJSON(jsonString).value!
    print("json =", json, "\n")

    // JSON AST -> JSON String
    let jsonEncoded: String = encode(json)
    print("encode(json) =", jsonEncoded, "\n")

    // JSON String -> Model
    let decoded: Result<Model, JSON.ParseError> = decode(jsonString)
    print("decoded =", decoded.value!, "\n")

    // Model -> JSON String
    let modelEncoded: String = encode(decoded.value!)
    print("encode(decoded) =", modelEncoded, "\n")
}
testJSON()
