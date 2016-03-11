import TryParsecExperiment
import Quick
import Nimble

class CSVSpec: QuickSpec
{
    override func spec()
    {
        describe("parseCSV") {

            it("succeeds (\\r\\n)") {
                let r = parseCSV("foo,bar,baz\r\n1,22,333\r\n")
                expect(r.value) == [ ["foo", "bar", "baz"], ["1", "22", "333"] ]
            }

            it("succeeds (\\n)") {
                let r = parseCSV("foo,bar,baz\n1,22,333\n")
                expect(r.value) == [ ["foo", "bar", "baz"], ["1", "22", "333"] ]
            }

            it("succeeds (\\n + no end break)") {
                let r = parseCSV("foo,bar,baz\n1,22,333")
                expect(r.value) == [ ["foo", "bar", "baz"], ["1", "22", "333"] ]
            }

        }

        describe("parseCSV (separator = \t)") {

            it("succeeds (\\r\\n)") {
                let r = parseCSV(separator: "\t", "foo\tbar\tbaz\r\n1\t22\t333\r\n")
                expect(r.value) == [ ["foo", "bar", "baz"], ["1", "22", "333"] ]
            }

            it("succeeds (\\n)") {
                let r = parseCSV(separator: "\t", "foo\tbar\tbaz\n1\t22\t333\n")
                expect(r.value) == [ ["foo", "bar", "baz"], ["1", "22", "333"] ]
            }

            it("succeeds (\\n + no end break)") {
                let r = parseCSV(separator: "\t", "foo\tbar\tbaz\n1\t22\t333")
                expect(r.value) == [ ["foo", "bar", "baz"], ["1", "22", "333"] ]
            }

        }
    }
}
