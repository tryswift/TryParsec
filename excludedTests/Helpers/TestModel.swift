import TryParsec
import Result
import Curry

struct _Model: FromJSON, ToJSON
{
    let string: String
    let int: Int
    let double: Double
    let bool: Bool
    let null: Bool?
    let array: [Any]
    let dict: [String : Any]

    // Comment-Out: nested containers are not supported (requires HKT)
//    let arrayOfArray: [[Any]]
//    let dictOfDict: [String : [String : Any]]

    let subModel: _SubModel
    let dummy: Bool?    // dummy value not declared in JSON file

    static func fromJSON(json: JSON) -> Result<_Model, JSON.ParseError>
    {
        return fromJSONObject(json) {
            //
            // NOTE:
            // Too long applicative style writing causes compiler error:
            // "Expression was too complex to be solved in reasonable time",
            // so break them into smaller sub-expressions.
            //
            // See also: https://github.com/thoughtbot/Argo/issues/5
            //
            let r1 = curry(self.init)
                <^> $0 !! "string"
                <*> $0 !! "int"
                <*> $0 !! "double"
                <*> $0 !! "bool"
                <*> $0 !! "null"

            let r2 = r1
                <*> $0 !! "array"
                <*> $0 !! "dict"
//                <*> $0 !! "arrayOfArray"
//                <*> $0 !! "dictOfDict"

            let r3 = r2
                <*> $0 !! "subModel"
                <*> $0 !? "dummy"

            return r3
        }
    }

    static func toJSON(model: _Model) -> JSON
    {
        return toJSONObject([
            "string" ~ model.string,
            "int" ~ model.int,
            "double" ~ model.double,
            "bool" ~ model.bool,
            "null" ~ model.null,
            "array" ~ model.array,
            "dict" ~ model.dict,
//            "arrayOfArray" ~ model.arrayOfArray,
//            "dictOfDict" ~ model.dictOfDict,
            "subModel" ~ model.subModel,
//            "dummy" ~ model.dummy,    // Comment-Out: let's not generate dummy value
        ])
    }
}

struct _SubModel: FromJSON, ToJSON
{
    let string: String
    // ...

    static func fromJSON(json: JSON) -> Result<_SubModel, JSON.ParseError>
    {
        return fromJSONObject(json) {
            curry(self.init)
                <^> $0 !! "string"
        }
    }

    static func toJSON(obj: _SubModel) -> JSON
    {
        return toJSONObject([
            "string" ~ obj.string
        ])
    }
}
