import TryParsec
import Quick
import Nimble

class CSVSpec: QuickSpec
{
    override func spec()
    {
        describe("parseCSV") {

            it("succeeds (\\r\\n)") {
                let r = parseCSV("foo,bar,baz\r\n1,22,333\r\n")
                expect(r.value?[0]) == ["foo", "bar", "baz"]
                expect(r.value?[1]) == ["1", "22", "333"]
                expect(r.value?.count) == 2
            }

            it("succeeds (\\n)") {
                let r = parseCSV("foo,bar,baz\n1,22,333\n")
                expect(r.value?[0]) == ["foo", "bar", "baz"]
                expect(r.value?[1]) == ["1", "22", "333"]
                expect(r.value?.count) == 2
            }

            it("succeeds (\\n + no end break)") {
                let r = parseCSV("foo,bar,baz\n1,22,333")
                expect(r.value?[0]) == ["foo", "bar", "baz"]
                expect(r.value?[1]) == ["1", "22", "333"]
                expect(r.value?.count) == 2
            }

        }

        describe("parseCSV (separator = \t)") {

            it("succeeds (\\r\\n)") {
                let r = parseCSV(separator: "\t", "foo\tbar\tbaz\r\n1\t22\t333\r\n")
                expect(r.value?[0]) == ["foo", "bar", "baz"]
                expect(r.value?[1]) == ["1", "22", "333"]
                expect(r.value?.count) == 2
            }

            it("succeeds (\\n)") {
                let r = parseCSV(separator: "\t", "foo\tbar\tbaz\n1\t22\t333\n")
                expect(r.value?[0]) == ["foo", "bar", "baz"]
                expect(r.value?[1]) == ["1", "22", "333"]
                expect(r.value?.count) == 2
            }

            it("succeeds (\\n + no end break)") {
                let r = parseCSV(separator: "\t", "foo\tbar\tbaz\n1\t22\t333")
                expect(r.value?[0]) == ["foo", "bar", "baz"]
                expect(r.value?[1]) == ["1", "22", "333"]
                expect(r.value?.count) == 2
            }

        }
    }
}
