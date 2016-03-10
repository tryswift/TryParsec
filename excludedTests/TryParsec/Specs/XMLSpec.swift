@testable import TryParsec
import Quick
import Nimble

class XMLSpec: QuickSpec
{
    override func spec()
    {
        describe("parseXML") {

            it("succeeds") {

                let xmlString = "<p class=\"welcome\"><a href=\"underground.html\" target=\"_blank\">Hello</a><?php echo ' Cruel'; ?> World<!-- 💀 --><![CDATA[💣->😇]]></p>"

                let expected: [XML] = [
                    .Element(
                        "p",
                        [XML.Attribute("class", "welcome")],
                        [
                            .Element(
                                "a",
                                [
                                    XML.Attribute("href", "underground.html"),
                                    XML.Attribute("target", "_blank")
                                ],
                                [.Text("Hello")]
                            ),
                            .ProcessingInstruction("php echo ' Cruel'; "),
                            .Text(" World"),
                            .Comment(" 💀 "),
                            .Text("💣->😇")
                        ]
                    )
                ]

                let r = parseXML(xmlString)
                expect(r.value) == expected

            }

            it("succeeds") {

                let xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!--I love Swift-->\n<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n<?php /* I love Swift */ ?>\n\n<p class=\"intro\"><a href=\"somewhere\" target=\"_blank\"  >Hello</a> World<![CDATA[if (c<10)]]></p>"

                let expected: [XML] = [
                    .XMLDeclaration(" version=\"1.0\" encoding=\"UTF-8\""),
                    .Comment("I love Swift"),
                    .DOCTYPE(" HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\""),
                    .ProcessingInstruction("php /* I love Swift */ "),
                    .Element(
                        "p",
                        [XML.Attribute("class", "intro")],
                        [
                            .Element(
                                "a",
                                [XML.Attribute("href", "somewhere"), XML.Attribute("target", "_blank")],
                                [.Text("Hello")]
                            ),
                            .Text("World"),
                            .Text("if (c<10)")
                        ]
                    )
                ]

                let r = parseXML(xmlString)
                expect(r.value) == expected

            }

        }

        describe("XML (internal)") {

            describe("DOCTYPE") {

                let p = doctype

                it("succeeds") {
                    let str: USV = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == .DOCTYPE(" HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\"")
                }

            }

            describe("xmlDeclaration") {

                let p = xmlDeclaration

                it("succeeds") {
                    let str: USV = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == .XMLDeclaration(" version=\"1.0\" encoding=\"UTF-8\"")
                }

            }

            describe("processingInstruction") {

                let p = processingInstruction

                it("succeeds") {
                    let str: USV = "<?php /* I love Swift */ ?>"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == .ProcessingInstruction("php /* I love Swift */ ")
                }

            }

            describe("manyMisc") {

                let p = manyMisc

                it("succeeds") {
                    let str: USV = "<!--I love Swift--><?php /* I love Swift */ ?><!--I love Swift-->"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == [
                        .Comment("I love Swift"),
                        .ProcessingInstruction("php /* I love Swift */ "),
                        .Comment("I love Swift")
                    ]
                }

            }

            describe("attrValue") {

                let p = attrValue

                it("succeeds (double quote)") {
                    let str: USV = "\"_blank\""

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == "_blank"
                }

                it("succeeds (single quote)") {
                    let str: USV = "'_blank'"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == "_blank"
                }

                it("succeeds (with reference)") {
                    let str: USV = "'&amp;'"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == "&amp;"
                }

                it("fails (no quotes)") {
                    let str: USV = "_blank"

                    let r = parse(p, str)._fail
                    expect(r?.input) == "_blank"
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }

                it("fails (tag is not allowed)") {
                    let str: USV = "\"<hr />\""

                    let r = parse(p, str)._fail
                    expect(r?.input) == "\"<hr />\""
                    expect(r?.contexts) == []
                    expect(r?.message) == "satisfy"
                }
            }

            describe("attribute") {

                let p = attribute

                it("succeeds") {
                    let str: USV = "target=\"_blank\""

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == XML.Attribute("target", "_blank")
                }

            }

            describe("xmlElement") {

                let p = xmlElement

                it("succeeds (emptyElementTag)") {
                    let str: USV = "<img src=\"somewhere\" />"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == .EmptyElement("img", [ XML.Attribute("src", "somewhere") ])
                }

                it("succeeds (emptyElementTag + multiple attributes)") {
                    let str: USV = "<img src=\"somewhere\" alt=\"...\"/>"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == .EmptyElement("img", [
                        XML.Attribute("src", "somewhere"),
                        XML.Attribute("alt", "...")
                    ])
                }

                it("succeeds (non-emptyElementTag)") {
                    let str: USV = "<a href=\"somewhere\" target=\"_blank\">Hello</a>"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == .Element(
                        "a",
                        [
                            XML.Attribute("href", "somewhere"),
                            XML.Attribute("target", "_blank")
                        ],
                        [.Text("Hello")]
                    )
                }

            }

            describe("entityRef") {

                let p = entityRef

                it("succeeds (`&copy;`)") {
                    let str: USV = "&copy;"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == "&copy;"
                }

            }

            describe("charRef") {

                let p = charRef

                it("succeeds (`&#xa9;`)") {
                    let str: USV = "&#xa9;"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == "&#xa9;"
                }

                it("succeeds (`&#169;`)") {
                    let str: USV = "&#169;"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == "&#169;"
                }

            }

            describe("prolog") {

                let p = prolog

                it("succeeds") {
                    let str: USV = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!--I love Swift--><!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\"><!--I ♡ Swift--><?php /* I love Swift */ ?>"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == [
                        .XMLDeclaration(" version=\"1.0\" encoding=\"UTF-8\""),
                        .Comment("I love Swift"),
                        .DOCTYPE(" HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\""),
                        .Comment("I ♡ Swift"),
                        .ProcessingInstruction("php /* I love Swift */ "),
                    ]
                }

            }

            describe("xmlContent") {

                let p = xmlContent

                it("succeeds (CharData only)") {
                    let str: USV = "abc"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == [ .Text("abc") ]
                }

                it("succeeds (CharData + Comment)") {
                    let str: USV = "abc<!-- comment -->"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == [
                        .Text("abc"),
                        .Comment(" comment ")
                    ]
                }

                it("succeeds (CharData + PI + CharData)") {
                    let str: USV = "Hello<?php echo \" Cruel\"; ?> World!"

                    let r = parse(p, str)._done
                    expect(r?.input) == ""
                    expect(r?.output) == [
                        .Text("Hello"),
                        .ProcessingInstruction("php echo \" Cruel\"; "),
                        .Text(" World!")
                    ]
                }

            }

            describe("xmlDocument") {

                it("succeeds") {
                    let str = self.dynamicType.loadString("test4", "xml")
//                    let str = "<param-value>/content/admin/remove?cache=pages&amp;id=</param-value>"

                    let p = xmlDocument
                    let r = parse(p, str.unicodeScalars)._done
                    expect(r?.input) == ""

                    // Comment-Out: Constructing AST takes too long to compile...
//                    expect(r?.output) == [ ... ]
                }

            }

        }

        describe("XML Files") {

            beforeEach {
                print("------------------------------")
            }

            it("parses XML files") {
                let files = [ "test1", "test2", "test3", "test4", "test5" ]

                for file in files {
                    print("file = \(file)")
                    print("")

                    let xmlString = self.dynamicType.loadString(file, "xml")
                    //print("xmlString = ", xmlString)
                    print("")

                    let xmlAST = parseXML(xmlString)
                    expect(xmlAST.value).toNot(beNil())
                    print("xmlAST = ", xmlAST)
                    print("")
                }
            }

        }
    }
}
