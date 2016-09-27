/// Haskell `infixl 9`
precedencegroup TryParsecJSONExtractionPrecedence {
    associativity: left
    higherThan: BitwiseShiftPrecedence
}

/// Haskell `infixl 9`
precedencegroup TryParsecJSONKeyValuePrecedence {
    associativity: left
    higherThan: BitwiseShiftPrecedence
}

infix operator !! : TryParsecJSONExtractionPrecedence
infix operator !? : TryParsecJSONExtractionPrecedence

infix operator ~  : TryParsecJSONKeyValuePrecedence
