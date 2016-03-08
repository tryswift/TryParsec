# TryParsec

Monadic Parser Combinator for [try! Swift](http://www.tryswiftconf.com/).

- Inspired by Haskell [Attoparsec](https://hackage.haskell.org/package/attoparsec) & [Aeson](https://hackage.haskell.org/package/aeson), Swift  [Argo](https://github.com/thoughtbot/Argo).
- Supports CSV, XML, JSON (+ mapping)
- Doesn't `try`, but please try :)

**NOTE:** This library is still in early development. Please see [TODO & FIXME](#todo--fixme).

## Quick Play

Open `Examples/TryParsecPlayground.playground`.

```bash
$ sudo gem install fastlane
$ fastlane play   # prepares Xcode Playground
```


## How to use

```swift
// Simple Arithmetic
let ans = parseArithmetic(" ( 12 + 3 )         * 4+5").value
expect(ans) == 65

// CSV
let csv = parseCSV("foo,bar,baz\r\n1,22,333\r\n").value
expect(csv) == [["foo", "bar", "baz"], ["1", "22", "333"]]

// XML
let xmlString = "<p class=\"welcome\"><a href=\"underground.html\" target=\"_blank\">Hello</a><?php echo ' Cruel'; ?> World<!-- 💀 --><![CDATA[💣->😇]]></p>"
let xml = parseXML(xmlString).value
expect(xml) == [.Element("p", [XML.Attribute("class", "welcome")], [.Element("a", [XML.Attribute("href", "underground.html"), XML.Attribute("target", "_blank")], [.Text("Hello")]), .ProcessingInstruction("php echo ' Cruel'; "), .Text(" World"), .Comment(" 💀 "), .Text("💣->😇")])]

// JSON
let jsonString = "{ \"string\" : \"hello\", \"array\" : [1, \"two\", [true, null]] }"
let json = parseJSON(jsonString).value
expect(json) == JSON.Object([
    "string" : .String("hello"),
    "array" : .Array([.Number(1), .String("two"), .Array([.Bool(true), .Null])])
])
```

### JSON Decoding & Encoding

```swift
import Curry

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

let jsonString = "{ \"string\" : \"hello\", \"array\" : [1, \"two\", [true, null]] }"

// JSON String -> Model
let decoded: Result<Model, JSON.ParseError> = decode(jsonString)

// Model -> JSON String
let encoded: String = encode(decoded.value!)
```

For `curry`ing, see [thoughtbot/Curry](https://github.com/thoughtbot/Curry) for more information.


## Supported functions

- **Basic Operators:** `>>-`, `<^>`, `<*>`, `*>`, `<*`, `<|>`, `<?>`
- **Combinators:** `zeroOrOne`, `many`, `many1`, `manyTill`, `skipMany`, `skipMany1`, `sepBy`, `sepBy1`, `sepEndBy`, `sepEndBy1`, `count`, `chainl`, `chainl1`, `chainr`, `chainr1`
- **Text (UnicodeScalarView):** `peek`, `endOfInput`, `satisfy`, `skip`, `skipWhile`, `take`, `takeWhile`, `any`, `char`, `not`, `string`, `asciiCI`, `oneOf`, `noneOf`, `digit`, `hexDigit`, `lowerAlphabet`, `upperAlphabet`, `alphabet`, `alphaNum`, `space`, `skipSpaces`, `endOfLine`, `number`


## TODO & FIXME

- **Improve overall performance**
  - Current JSON parsing is 70x~ slower than `NSJSONSerialization` (even with whole-module-optimization)
- Improve error reporting
- Support indent parser (e.g. YAML)
- Once [apple/swift](https://github.com/apple/swift) supports [Higher Kinded Types](https://en.wikipedia.org/wiki/Kind_(type_theory))...
  - Support incremental input
  - Remove workarounds e.g. reflection-based JSON encoding


## Acknowledgement

This library is heavily inspired by following developers & libraries:

- Bryan O'Sullivan: Author of [Attoparsec](https://hackage.haskell.org/package/attoparsec) & [Aeson] (https://hackage.haskell.org/package/aeson) (Haskell)
- Daan Leijen: Author of [Parsec](https://hackage.haskell.org/package/parsec) (Haskell)
- thoughtbot: Author of [Argo](https://github.com/thoughtbot/Argo) (Swift JSON decoding library)


## References

- [Parser Combinator in Swift // Speaker Deck](https://speakerdeck.com/inamiy/parser-combinator-in-swift)


## Licence

[MIT](LICENSE)
