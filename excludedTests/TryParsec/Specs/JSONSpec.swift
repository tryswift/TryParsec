@testable import TryParsec
import Result
import Quick
import Nimble

class JSONSpec: QuickSpec
{
    override func spec()
    {
        describe("parseJSON") {

            it("succeeds") {

                let jsonString = "{ \"items\": [ { \"hidden\" : true } ] }"

                let expected = JSON.Object([
                    "items" : JSON.Array([
                        JSON.Object([
                            "hidden" : JSON.Bool(true)
                        ])
                    ])
                ])

                let r = parseJSON(jsonString)
                expect(r.value) == expected

                expect(r.value?["items"]?[0]?["hidden"]?.rawBool) == true

            }

            it("succeeds") {

                let jsonString = "{ \"string\" : \"hello\", \"array\" : [1, \"two\", [true, null]] }"

                let expected = JSON.Object([
                    "string" : .String("hello"),
                    "array" : .Array([.Number(1), .String("two"), .Array([.Bool(true), .Null])])
                ])

                let r = parseJSON(jsonString)
                expect(r.value) == expected

                expect(r.value?["string"]?.rawString) == "hello"
                expect(r.value?["array"]?[0]?.rawNumber) == 1
                expect(r.value?["array"]?[1]?.rawString) == "two"
                expect(r.value?["array"]?[2]?[0]?.rawBool) == true
                expect(r.value?["array"]?[2]?[1]?.rawNull) == ()

            }

        }

        describe("JSON (internal)") {

            describe("jsonString") {

                let p = jsonString

                it("succeeds") {
                    let r = parse(p, "\"123\"")._done
                    expect(r?.input) == ""
                    expect(r?.output) == JSON.String("123")
                }

                it("succeeds (partial)") {
                    let r = parse(p, "\"123\nabc\"other")._done
                    expect(r?.input) == "other"
                    expect(r?.output) == JSON.String("123\nabc")
                }

                it("fails") {
                    let r = parse(p, "null")._fail
                    expect(r?.input) == "null"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

            describe("jsonNumber") {

                let p = jsonNumber

                it("succeeds") {
                    let r = parse(p, "1.2")._done
                    expect(r?.input) == ""
                    expect(r?.output) == JSON.Number(1.2)
                }

                it("succeeds (scientific small-e)") {
                    let r = parse(p, "1.2e3")._done
                    expect(r?.input) == ""
                    expect(r?.output) == JSON.Number(1200)
                }

                it("succeeds (scientific large-E)") {
                    let r = parse(p, "-1.2E3")._done
                    expect(r?.input) == ""
                    expect(r?.output) == JSON.Number(-1200)
                }

                it("fails") {
                    let r = parse(p, "null")._fail
                    expect(r?.input) == "null"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

            describe("jsonBool") {

                let p = jsonBool

                it("succeeds (true)") {
                    let r = parse(p, "true")._done
                    expect(r?.input) == ""
                    expect(r?.output) == JSON.Bool(true)
                }

                it("succeeds (false)") {
                    let r = parse(p, "false")._done
                    expect(r?.input) == ""
                    expect(r?.output) == JSON.Bool(false)
                }

                it("fails") {
                    let r = parse(p, "null")._fail
                    expect(r?.input) == "null"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

                it("fails (capital letter)") {
                    let r = parse(p, "True")._fail
                    expect(r?.input) == "True"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

            describe("jsonArray") {

                let p = jsonArray

                it("succeeds") {
                    let r = parse(p, "[ true, false ]")._done
                    expect(r?.input) == ""
                    expect(r?.output) == JSON.Array([JSON.Bool(true), JSON.Bool(false)])
                }

                it("fails") {
                    let r = parse(p, "null")._fail
                    expect(r?.input) == "null"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

            describe("jsonObject") {

                let p = jsonObject

                it("succeeds") {
                    let r = parse(p, "{ \"test\" : true }")._done
                    expect(r?.input) == ""
                    expect(r?.output) == JSON.Object([ "test" : JSON.Bool(true) ])
                }

                it("fails") {
                    let r = parse(p, "null")._fail
                    expect(r?.input) == "null"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

        }

        describe("JSON decode") {

            it("decodes as array") {
                let str = "[1, 2, 3]"
                let r: Result<[Double], JSON.ParseError> = decode(str)
                expect(r.value) == [ 1, 2, 3 ]
            }

            it("decodes as object") {
                let str = "{ \"value\": 5 }"
                let r: Result<[String : Double], JSON.ParseError> = decode(str)
                expect(r.value) == [ "value" : 5 ]
            }

        }

        describe("JSON Files") {

            beforeEach {
                print("------------------------------")
            }

            it("parses JSON files") {
                let files = [ "test1", "test2", "test3", "test4", "test5", "escape" ]

                for file in files {
                    print("file = \(file)")
                    print("")

                    let jsonString = self.dynamicType.loadString(file, "json")
                    print("jsonString = ", jsonString)
                    print("")

                    let jsonAST = parseJSON(jsonString)
                    expect(jsonAST.value).toNot(beNil())
                    print("jsonAST = ", jsonAST)
                    print("")
                }
            }

            it("decodes JSON file as _Model & encode") {
                let jsonString = self.dynamicType.loadString("basic", "json")
                print("jsonString =", jsonString)

                let decoded: Result<_Model, JSON.ParseError> = decode(jsonString)
                expect(decoded.value).toNot(beNil())
                print("decoded =", decoded)

                let encoded = encode(decoded.value!)
                print("encoded =", encoded)
            }

        }

    }
}
