import TryParsec
import Quick
import Nimble

class ParserSpec: QuickSpec
{
    override func spec()
    {
        // MARK: Functor

        describe("Functor") {

            describe("`<^>` (fmap)") {

                it("`f <^> p` succeeds when `p` succeeds") {
                    let p: Parser<String, Int> = { $0 + 1 } <^> pure(1)
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "hello"
                    expect(r?.output) == 2
                }

                it("`f <^> p` fails when `p` fails") {
                    let p: Parser<String, Int> = { $0 + 1 } <^> fail("oops")
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "hello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "oops"
                }

            }

            describe("`<&>` (flip fmap)") {

                it("`p <&> f` succeeds when `p` succeeds") {
                    let p: Parser<String, Int> = pure(1) <&> { $0 + 1 }
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "hello"
                    expect(r?.output) == 2
                }

                it("`p <&> f` fails when `p` fails") {
                    let p: Parser<String, Int> = fail("oops") <&> { $0 + 1 }
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "hello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "oops"
                }

            }

        }

        // MARK: Applicative

        describe("Applicative") {

            describe("`<*>` (ap)") {

                it("`f <*> p` succeeds when both `f` and `p` succeed") {
                    let p: Parser<String, Int> = pure({ $0 + 1 }) <*> pure(1)
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "hello"
                    expect(r?.output) == 2
                }

                it("`f <*> p` fails when `f` succeeds but `p` fails") {
                    let p: Parser<String, Int> = pure({ $0 + 1 }) <*> fail("oops")
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "hello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "oops"
                }

                it("`f <*> p` fails when `f` fails") {
                    let p: Parser<String, Int> = fail("oops") <*> pure(1)
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "hello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "oops"
                }

                it("`f <^> p1 <*> p2` (applicative style) succeeds when `f`, `p1`, and `p2` succeed") {
                    let p = { a in { b in (a, b) } } <^> char("h") <*> char("e")
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "llo"
                    expect(r?.output.0) == "h"
                    expect(r?.output.1) == "e"
                }

            }

            describe("`*>` (sequence, discarding left)") {

                it("`p *> q` succeeds when both `p` and `q` succeed") {
                    let p = char("h") *> char("e")
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "llo"
                    expect(r?.output) == "e"
                }

                it("`p *> q` fails when `p` succeeds but `q` fails") {
                    let p = char("h") *> char("x")
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "ello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

                it("`p *> q` fails when `p` fails") {
                    let p = char("x") *> char("h")
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "hello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

            describe("`<*` (sequence, discarding right)") {

                it("`p <* q` succeeds when both `p` and `q` succeed") {
                    let p = char("h") <* char("e")
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "llo"
                    expect(r?.output) == "h"
                }

                it("`p <* q` fails when `p` succeeds but `q` fails") {
                    let p = char("h") <* char("x")
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "ello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

                it("`p <* q` fails when `p` fails") {
                    let p = char("x") <* char("h")
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "hello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

        }

        // MARK: Alternative

        describe("Alternative") {

            describe("`<|>` (choice, alternation)") {

                it("`p <|> q` succeeds when both `p` and `q` succeed") {
                    let p = string("he") <|> string("hell")
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "llo"
                    expect(r?.output) == "he"
                }

                it("`p <|> q` succeeds when `p` succeeds but `q` fails") {
                    let p = string("hell") <|> string("x")
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "o"
                    expect(r?.output) == "hell"
                }

                it("`p <|> q` succeeds when `p` fails but `q` succeeds") {
                    let p = string("x") <|> string("hell")
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "o"
                    expect(r?.output) == "hell"
                }

                it("`p <|> q` fails when both `p` and `q` fail") {
                    let p = string("x") <|> string("y")
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "hello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

        }

        // MARK: Monad

        describe("Monad") {

            describe(">>- (bind, flatMap)") {

                it("`p >>- f` succeeds when both `p` and `f()` succeeds") {
                    let p = string("he") >>- { pure($0 + ["y"]) }
                    let r = parse(p, "hello")._done
                    expect(r?.input) == "llo"
                    expect(r?.output) == "hey"
                }

                it("`p >>- f` fails when `p` succeeds but `f()` fails") {
                    let p: Parser<USV, USV> = string("he") >>- { _ in fail("oops") }
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "llo"
                    expect(r?.contexts) == []
                    expect(r?.message) == "oops"
                }

                it("`p >>- f` fails when `p` fails") {
                    let p: Parser<USV, USV> = string("x") >>- { _ in pure("I made it!!!") }
                    let r = parse(p, "hello")._fail
                    expect(r?.input) == "hello"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

            }

        }

        // MARK: Peek

        describe("peek") {

            let p: Parser<USV, UnicodeScalar> = peek()

            it("succeeds") {
                let r = parse(p, "abc")._done
                expect(r?.input) == "abc"
                expect(r?.output) == "a"
            }

            it("fails") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "peek"
            }

        }

        describe("endOfInput") {

            let p: Parser<USV, ()> = endOfInput()

            it("succeeds") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output) == ()
            }

            it("fails") {
                let r = parse(p, "abc")._fail
                expect(r?.input) == "abc"
                expect(r?.contexts) == []
                expect(r?.message) == "endOfInput"
            }

        }

    }
}
