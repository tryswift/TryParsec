/// Haskell `infixl 1` (Control.Lens)
precedencegroup TryParsecFlipMapPrecedence {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

/// Haskell `infixr 1`
precedencegroup TryParsecCompositionPrecedence {
    associativity: right
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

/// Haskell `infixl 0`
precedencegroup TryParsecLabelPrecedence {
    associativity: left
    lowerThan: TernaryPrecedence
    higherThan: AssignmentPrecedence
}

infix operator <&> : TryParsecFlipMapPrecedence

infix operator >>> : TryParsecCompositionPrecedence
infix operator <<< : TryParsecCompositionPrecedence

infix operator <?> : TryParsecLabelPrecedence
