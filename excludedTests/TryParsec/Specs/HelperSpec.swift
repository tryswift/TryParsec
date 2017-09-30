@testable import TryParsec
import Result
import Quick
import Nimble

class HelperSpec: QuickSpec
{
    override func spec()
    {
        describe("splitAt") {

            it("splitAt(1)") {
                let (heads, tails) = splitAt(1)("abc" as USV)
                expect(String(heads).unicodeScalars) == ["a"]
                expect(String(tails).unicodeScalars) == ["b", "c"]
            }

            it("splitAt(0)") {
                let (heads, tails) = splitAt(0)("abc" as USV)
                expect(String(heads).unicodeScalars) == []
                expect(String(tails).unicodeScalars) == ["a", "b", "c"]
            }

            it("splitAt(999)") {
                let (heads, tails) = splitAt(999)("abc" as USV)
                expect(String(heads).unicodeScalars) == ["a", "b", "c"]
                expect(String(tails).unicodeScalars) == []
            }

            it("splitAt(0)(\"\")") {
                let (heads, tails) = splitAt(0)("" as USV)
                expect(String(heads).unicodeScalars) == []
                expect(String(tails).unicodeScalars) == []
            }

        }

        describe("trim") {

            it("trims head & tail whitespaces") {
                let trimmed = trim("   Trim me!   ")
                expect(trimmed) == "Trim me!"
            }

            it("doesn't trim middle whitespaces") {
                let trimmed = trim("Dooooon't    trrrrrim     meeeee!")
                expect(trimmed) == "Dooooon't    trrrrrim     meeeee!"
            }

        }

        describe("RangeReplaceableCollectionType (RRC)") {

            it("any RRC e.g. `ArraySlice` can initialize with SequenceType") {
                let arr = ArraySlice<UnicodeScalar>("abc" as USV)
                expect(Array(arr)) == Array(["a", "b", "c"])
            }

        }
    }
}
