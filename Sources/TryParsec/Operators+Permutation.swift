/// Haskell `infixl 2`
precedencegroup TryParsecPermutationMapPrecedence {
    associativity: left
    lowerThan: LogicalConjunctionPrecedence
    higherThan: TryParsecPermutationApplyPrecedence, LogicalDisjunctionPrecedence
}

/// Haskell `infixl 1`
precedencegroup TryParsecPermutationApplyPrecedence {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

infix operator <^^> : TryParsecPermutationMapPrecedence
infix operator <^?> : TryParsecPermutationMapPrecedence

infix operator <||> : TryParsecPermutationApplyPrecedence
infix operator <|?> : TryParsecPermutationApplyPrecedence
