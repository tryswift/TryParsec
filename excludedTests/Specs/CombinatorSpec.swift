import TryParsec
import Quick
import Nimble

class CombinatorSpec: QuickSpec
{
    override func spec()
    {
        describe("many") {

            let p: Parser<USV, USV> = many(digit)

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "123"
            }

            it("succeeds (zero digit)") {
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

        describe("many1") {

            let p: Parser<USV, USV> = many1(digit)

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "123"
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

        describe("manyTill") {

            let p: Parser<USV, USV> = manyTill(any, string("="))

            it("succeeds") {
                let r = parse(p, "123=abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "123"
            }

            it("fails") {
                let r = parse(p, "123abc")._fail
                expect(r?.input) == ""
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

        describe("skipMany") {

            let p: Parser<USV, ()> = skipMany(digit)

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

        describe("skipMany1") {

            let p: Parser<USV, ()> = skipMany1(digit)

            it("succeeds") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == ()
            }

            it("fails (zero occurrence)") {
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

        describe("sepBy") {

            let p: Parser<USV, [UnicodeScalar]> = sepBy(digit, char(","))

            it("succeeds") {
                let r = parse(p, "1,2,3")._done
                expect(r?.input) == ""
                expect(r?.output) == ["1", "2", "3"]
            }

            it("succeeds (tail-comma is NOT CONSUMED)") {
                let r = parse(p, "1,2,3,")._done
                expect(r?.input) == ","
                expect(r?.output) == ["1", "2", "3"]
            }

            it("succeeds (zero occurrence of digit-then-comma)") {
                let r = parse(p, ",1,2,3")._done
                expect(r?.input) == ",1,2,3"
                expect(r?.output) == []
            }

            it("succeeds (no input)") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output) == []
            }

        }

        describe("sepBy1") {

            let p: Parser<USV, [UnicodeScalar]> = sepBy1(digit, char(","))

            it("succeeds") {
                let r = parse(p, "1,2,3")._done
                expect(r?.input) == ""
                expect(r?.output) == ["1", "2", "3"]
            }

            it("succeeds (tail-comma is NOT CONSUMED)") {
                let r = parse(p, "1,2,3,")._done
                expect(r?.input) == ","
                expect(r?.output) == ["1", "2", "3"]
            }

            it("fails (zero occurrence of digit-then-comma)") {
                let r = parse(p, ",1,2,3")._fail
                expect(r?.input) == ",1,2,3"
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

        describe("sepEndBy") {

            let p: Parser<USV, [UnicodeScalar]> = sepEndBy(digit, char(","))

            it("succeeds") {
                let r = parse(p, "1,2,3")._done
                expect(r?.input) == ""
                expect(r?.output) == ["1", "2", "3"]
            }

            it("succeeds (tail-comma IS CONSUMED)") {
                let r = parse(p, "1,2,3,")._done
                expect(r?.input) == ""
                expect(r?.output) == ["1", "2", "3"]
            }

            it("succeeds (zero occurrence of digit-then-comma)") {
                let r = parse(p, ",1,2,3")._done
                expect(r?.input) == ",1,2,3"
                expect(r?.output) == []
            }

            it("succeeds (no input)") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output) == []
            }

        }

        describe("sepEndBy1") {

            let p: Parser<USV, [UnicodeScalar]> = sepEndBy1(digit, char(","))

            it("succeeds") {
                let r = parse(p, "1,2,3")._done
                expect(r?.input) == ""
                expect(r?.output) == ["1", "2", "3"]
            }

            it("succeeds (tail-comma IS CONSUMED)") {
                let r = parse(p, "1,2,3,")._done
                expect(r?.input) == ""
                expect(r?.output) == ["1", "2", "3"]
            }

            it("fails (zero occurrence of digit-then-comma)") {
                let r = parse(p, ",1,2,3")._fail
                expect(r?.input) == ",1,2,3"
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

        describe("count") {

            let p: Parser<USV, [USV]> = count(3, string("123"))

            it("succeeds") {
                let r = parse(p, "123123123123")._done
                expect(r?.input) == "123"
                expect(r?.output) == ["123", "123", "123"]
            }

            it("fails") {
                let r = parse(p, "123123xyz123")._fail
                expect(r?.input) == "xyz123"
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

        describe("chainl") {

            let p: Parser<USV, Double> = chainl(number, char("-") *> pure(-), 999)

            it("succeeds (left-association)") {
                let r = parse(p, "1-2-3")._done
                expect(r?.input) == ""
                expect(r?.output) == -4
            }

            it("succeeds (zero occurrence)") {
                let r = parse(p, "=1-2-3")._done
                expect(r?.input) == "=1-2-3"
                expect(r?.output) == 999
            }

            it("succeeds (no input)") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output) == 999            }

        }

        describe("chainl1") {

            let p: Parser<USV, Double> = chainl1(number, char("-") *> pure(-))

            it("succeeds (left-association)") {
                let r = parse(p, "1-2-3")._done
                expect(r?.input) == ""
                expect(r?.output) == -4
            }

            it("fails (zero occurrence)") {
                let r = parse(p, "=1-2-3")._fail
                expect(r?.input) == "=1-2-3"
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

        describe("chainr") {

            let p: Parser<USV, Double> = chainr(number, char("-") *> pure(-), 999)

            it("succeeds (right-association)") {
                let r = parse(p, "1-2-3")._done
                expect(r?.input) == ""
                expect(r?.output) == 2
            }

            it("succeeds (zero occurrence)") {
                let r = parse(p, "=1-2-3")._done
                expect(r?.input) == "=1-2-3"
                expect(r?.output) == 999
            }

            it("succeeds (no input)") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output) == 999            }

        }

        describe("chainr1") {

            let p: Parser<USV, Double> = chainr1(number, char("-") *> pure(-))

            it("succeeds (right-association)") {
                let r = parse(p, "1-2-3")._done
                expect(r?.input) == ""
                expect(r?.output) == 2
            }

            it("fails (zero occurrence)") {
                let r = parse(p, "=1-2-3")._fail
                expect(r?.input) == "=1-2-3"
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

        describe("lookAhead") {

            let p: Parser<USV, UnicodeScalar> = lookAhead(any)

            it("succeeds") {
                let r = parse(p, "abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "a"
            }

            it("fails") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
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
