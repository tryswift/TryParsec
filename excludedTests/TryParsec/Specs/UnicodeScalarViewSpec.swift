import TryParsec
import Quick
import Nimble

class UnicodeScalarViewSpec: QuickSpec
{
    override func spec()
    {
        describe("satisfy") {

            let p = satisfy { $0 == "1" }

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "23abc"
                expect(r?.output) == "1"
            }

            it("fails") {
                let r = parse(p, "abcdef")._fail
                expect(r?.input) == "abcdef"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("skip") {

            let p = skip { $0 == "1" }

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "23abc"
                expect(r?.output) == ()
            }

            it("fails") {
                let r = parse(p, "abcdef")._fail
                expect(r?.input) == "abcdef"
                expect(r?.contexts) == []
                expect(r?.message) == "skip"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "skip"
            }

        }

        describe("skipWhile") {

            let p = skipWhile(isDigit)

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == ()
            }

            it("succeeds (zero occurrence)") {
                let r = parse(p, "abcdef")._done
                expect(r?.input) == "abcdef"
                expect(r?.output) == ()
            }

            it("succeeds (no input)") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output) == ()
            }

        }

        describe("take") {

            let p = take(3)

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "123"
            }

            it("fails (input is too short)") {
                let r = parse(p, "12")._fail
                expect(r?.input) == "12"
                expect(r?.contexts) == []
                expect(r?.message) == "take(3)"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "take(3)"
            }

        }

        describe("takeWhile") {

            let p = takeWhile(isDigit)

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "123"
            }

            it("succeeds (zero occurrence)") {
                let r = parse(p, "abcdef")._done
                expect(r?.input) == "abcdef"
                expect(r?.output) == ""
            }

            it("succeeds (no input)") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output) == ""
            }

        }

        describe("any") {

            let p = any

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "23abc"
                expect(r?.output) == "1"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("not") {

            let p = not("a")

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "23abc"
                expect(r?.output) == "1"
            }

            it("fails") {
                let r = parse(p, "abcdef")._fail
                expect(r?.input) == "abcdef"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("oneOf") {

            let p = oneOf("123") // same as `oneOf(["1", "2", "3"])`

            it("succeeds") {
                let r = parse(p, "1abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "1"
            }

            it("fails") {
                let r = parse(p, "abc")._fail
                expect(r?.input) == "abc"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("noneOf") {

            let p = noneOf("123") // same as `oneOf(["1", "2", "3"])`

            it("succeeds") {
                let r = parse(p, "abc")._done
                expect(r?.input) == "bc"
                expect(r?.output) == "a"
            }

            it("fails") {
                let r = parse(p, "1abc")._fail
                expect(r?.input) == "1abc"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("digit") {

            let p = digit

            it("succeeds") {
                let r = parse(p, "123")._done
                expect(r?.input) == "23"
                expect(r?.output) == "1"
            }

            it("fails") {
                let r = parse(p, "abc")._fail
                expect(r?.input) == "abc"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("lowerAlphabet") {

            let p = lowerAlphabet

            it("succeeds") {
                let r = parse(p, "abc")._done
                expect(r?.input) == "bc"
                expect(r?.output) == "a"
            }

            it("fails") {
                let r = parse(p, "ABC")._fail
                expect(r?.input) == "ABC"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("upperAlphabet") {

            let p = upperAlphabet

            it("succeeds") {
                let r = parse(p, "ABC")._done
                expect(r?.input) == "BC"
                expect(r?.output) == "A"
            }

            it("fails") {
                let r = parse(p, "abc")._fail
                expect(r?.input) == "abc"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("alphabet") {

            let p = alphabet

            it("succeeds (uppercase)") {
                let r = parse(p, "ABC")._done
                expect(r?.input) == "BC"
                expect(r?.output) == "A"
            }

            it("succeeds (lowercase)") {
                let r = parse(p, "abc")._done
                expect(r?.input) == "bc"
                expect(r?.output) == "a"
            }

            it("fails") {
                let r = parse(p, "123")._fail
                expect(r?.input) == "123"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("alphaNum") {

            let p = alphaNum

            it("succeeds (uppercase)") {
                let r = parse(p, "ABC")._done
                expect(r?.input) == "BC"
                expect(r?.output) == "A"
            }

            it("succeeds (lowercase)") {
                let r = parse(p, "abc")._done
                expect(r?.input) == "bc"
                expect(r?.output) == "a"
            }

            it("succeeds (numeric)") {
                let r = parse(p, "123")._done
                expect(r?.input) == "23"
                expect(r?.output) == "1"
            }

            it("fails") {
                let r = parse(p, "!@#")._fail
                expect(r?.input) == "!@#"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("space") {

            let p = space

            it("succeeds (space)") {
                let r = parse(p, " abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == " "
            }

            it("succeeds (\\t)") {
                let r = parse(p, "\tabc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "\t"
            }

            it("succeeds (\\n)") {
                let r = parse(p, "\nabc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "\n"
            }

            it("succeeds (\\r)") {
                let r = parse(p, "\rabc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "\r"
            }

            it("fails (no spaces)") {
                let r = parse(p, "abc")._fail
                expect(r?.input) == "abc"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("skipSpaces") {

            let p = skipSpaces

            it("succeeds") {
                let r = parse(p, " \t\n\rabc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == ()
            }

            it("succeeds (no spaces)") {
                let r = parse(p, "123")._done
                expect(r?.input) == "123"
                expect(r?.output) == ()
            }

            it("succeeds (no input)") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output) == ()
            }

        }

        describe("char") {

            let p = char("a")

            it("succeeds") {
                let r = parse(p, "abc")._done
                expect(r?.input) == "bc"
                expect(r?.output) == "a"
            }

            it("fails") {
                let r = parse(p, "1abc")._fail
                expect(r?.input) == "1abc"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("string") {

            let p = string("ab")

            it("succeeds") {
                let r = parse(p, "abc")._done
                expect(r?.input) == "c"
                expect(r?.output) == "ab"
            }

            it("fails") {
                let r = parse(p, "1abc")._fail
                expect(r?.input) == "1abc"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("asciiCI") {

            let p = asciiCI("ab")

            it("succeeds") {
                let r = parse(p, "aBc")._done
                expect(r?.input) == "c"
                expect(r?.output) == "aB"
            }

            it("fails") {
                let r = parse(p, "1aBc")._fail
                expect(r?.input) == "1aBc"
                expect(r?.contexts) == []
                expect(r?.message) == "_string"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "_string"
            }

        }

        describe("number") {

            let p = number

            it("succeeds") {
                let r = parse(p, "123")._done
                expect(r?.input) == ""
                expect(r?.output) == 123
            }

            it("succeeds (float)") {
                let r = parse(p, "123.45")._done
                expect(r?.input) == ""
                expect(r?.output) == 123.45
            }

            it("succeeds (float + zero_start)") {
                let r = parse(p, "0.25")._done
                expect(r?.input) == ""
                expect(r?.output) == 0.25
            }

            it("succeeds (float + two zero_starts)") {
                let r = parse(p, "00.25")._done
                expect(r?.input) == ""
                expect(r?.output) == 0.25
            }

            it("succeeds (scientific)") {
                let r = parse(p, "123.45e2")._done
                expect(r?.input) == ""
                expect(r?.output) == 12345
            }

            it("succeeds ('+' prefix)") {
                let r = parse(p, "+12.5e-1")._done
                expect(r?.input) == ""
                expect(r?.output) == 1.25
            }

            it("succeeds ('-' prefix)") {
                let r = parse(p, "-12.5e-1")._done
                expect(r?.input) == ""
                expect(r?.output) == -1.25
            }

            it("succeeds (partial)") {
                let r = parse(p, "-12.34.5e-1")._done
                expect(r?.input) == ".5e-1"
                expect(r?.output) == -12.34
            }

            it("fails") {
                let r = parse(p, "=1")._fail
                expect(r?.input) == "=1"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("endOfLine") {

            let p = endOfLine

            it("succeeds (\\n)") {
                let r = parse(p, "\n")._done
                expect(r?.input) == ""
                expect(r?.output) == ()
            }

            it("succeeds (\\r\\n)") {
                let r = parse(p, "\r\n")._done
                expect(r?.input) == ""
                expect(r?.output) == ()
            }

            it("fails") {
                let r = parse(p, "abc")._fail
                expect(r?.input) == "abc"
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

    }
}
