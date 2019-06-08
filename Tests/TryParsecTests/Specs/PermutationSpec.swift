import TryParsec
import Runes
import Quick
import Nimble

class PermutationSpec: QuickSpec
{
    override func spec()
    {
        describe("Permutation (n=1)") {

            let perm: Permutation<USV, USV> =
                { $0 } <^^> string("abc")

            let p: Parser<USV, USV> = permute(perm)

            it("succeeds") {
                let r = parse(p, "abc123")._done
                expect(r?.input) == "123"
                expect(r?.output) == "abc"
            }

            it("fails (wrong input)") {
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

        describe("Permutation (n=2)") {

            let perm: Permutation<USV, USV> =
                { a in { b in a + "," + b } }
                    <^^> string("abc")
                    <||> string("123")

            let p: Parser<USV, USV> = permute(perm)

            it("succeeds") {
                let r = parse(p, "abc123")._done
                expect(r?.input) == ""
                expect(r?.output) == "abc,123"
            }

            it("succeeds (reordered)") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == ""
                expect(r?.output) == "abc,123"
            }

            it("fails (no input)") {
                let r = parse(p, "")._fail
                expect(r?.input) == ""
                expect(r?.contexts) == []
                expect(r?.message) == "satisfy"
            }

        }

        describe("Permutation (n=2, required + optional)") {

            let perm: Permutation<USV, USV> =
                { a in { b in a + "," + b } }
                    <^^> string("abc")          // `<^^>` or `<||>` as required
                    <|?> ("_", string("123"))   // `<^?>` or `<|?>` as optional

            let p: Parser<USV, USV> = permute(perm)

            it("succeeds") {
                let r = parse(p, "abc123")._done
                expect(r?.input) == ""
                expect(r?.output) == "abc,123"
            }

            it("succeeds (reordered)") {
                let r = parse(p, "123abc")._done
                expect(r?.input) == ""
                expect(r?.output) == "abc,123"
            }

            it("succeeds ('123' is optional)") {
                let r = parse(p, "abc???")._done
                expect(r?.input) == "???"
                expect(r?.output) == "abc,_"
            }

            it("fails ('abc' is required)") {
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

        describe("Permutation (n=3, URL-query example)") {

            /// Extracts "value" from "\(key)=value&...".
            func valueParser(_ key: USV) -> Parser<USV, USV>
            {
                return string(key + "=") *> many1(noneOf("&#")) <* zeroOrOne(char("&"))
            }

            let perm: Permutation<USV, (USV, USV, USV)> =
                { a in { b in { c in (a, b, c) } } }
                    <^?> ("_", valueParser("key1"))
                    <|?> ("_", valueParser("key2"))
                    <|?> ("_", valueParser("key3"))

            let p: Parser<USV, (USV, USV, USV)> = permute(perm)

            it("succeeds") {
                let r = parse(p, "key1=a&key2=b&key3=c#hello")._done
                expect(r?.input) == "#hello"
                expect(r?.output.0) == "a"
                expect(r?.output.1) == "b"
                expect(r?.output.2) == "c"
            }

            it("succeeds (reordered)") {
                let keyValues: [String] = ["key1=a", "key2=b", "key3=c"]
                let patterns = permutations(keyValues)

                for pattern in patterns {
                    /// e.g. "key2=b&key1=a&key3=c"
                    let query: String = pattern.joined(separator: "&")

                    let r = parse(p, query.unicodeScalars)._done
                    expect(r?.input) == ""
                    expect(r?.output.0) == "a"
                    expect(r?.output.1) == "b"
                    expect(r?.output.2) == "c"
                }
            }

            it("succeeds (keyValues are optional)") {
                let r = parse(p, "key3=c&key2=b#hello")._done
                expect(r?.input) == "#hello"
                expect(r?.output.0) == "_"
                expect(r?.output.1) == "b"
                expect(r?.output.2) == "c"
            }

            it("succeeds (no input)") {
                let r = parse(p, "")._done
                expect(r?.input) == ""
                expect(r?.output.0) == "_"
                expect(r?.output.1) == "_"
                expect(r?.output.2) == "_"
            }

        }

    }
}
