import TryParsecExperiment
import Quick
import Nimble

class ArithmeticSpec: QuickSpec
{
    override func spec()
    {
        describe("parseArithmetic") {

            it("`1` = 1") {
                let r = parseArithmetic("1")
                expect(r.value) == 1
            }

            it("`1+2` = 3") {
                let r = parseArithmetic("1+2")
                expect(r.value) == 3
            }

            it("`1-2` = -1") {
                let r = parseArithmetic("1-2")
                expect(r.value) == -1
            }

            it("`2*3` = 6") {
                let r = parseArithmetic("2*3")
                expect(r.value) == 6
            }

            it("`2/3` = 0  (float not supported)") {
                let r = parseArithmetic("2/3")
                expect(r.value) == 0
            }

            it("`1-2-3` = -4  (left-associative)") {
                let r = parseArithmetic("1-2-3")
                expect(r.value) == -4
            }

            it("`1/2*2` = 0  (`1/2` will be zero)") {
                let r = parseArithmetic("1/2*2")
                expect(r.value) == 0
            }

            it("`(1+2)*3` = 9") {
                let r = parseArithmetic("(1+2)*3")
                expect(r.value) == 9
            }

            it("` ( 12 + 3 )         * 4+5` = 65") {
                let r = parseArithmetic(" ( 12 + 3 )         * 4+5")
                expect(r.value) == 65
            }
        }

        describe("Not Supported") {

            it("`1.2` fails (float is not supported yet)") {
                let r = parseArithmetic("1.2")
                expect(r.value).to(beNil())
                expect(r.error).notTo(beNil())
            }

        }
    }
}
