/// Parses zero or one occurrence of `parser`.
/// - SeeAlso: Haskell Parsec's `optionMaybe`.
public func zeroOrOne<Out>(parser: Parser<Out>.Function) -> Parser<Out?>.Function {
    return parser <&> Optional<Out>.init // <|> pure(Optional<Out>.None)
}

/// Parses zero or more occurrences of `parser`.
/// - Note: Returning parser never fails.
public func many<Outs: RangeReplaceableCollectionType>(parser: Parser<Outs.Generator.Element>.Function) -> Parser<Outs>.Function {
    return { input in
        var result = Outs()
        var remainder = input
        while true {
            switch parser(remainder) {
            case .Done(let input, let out):
                result.append(out)
                remainder = input
            case .Fail(_, _, _): return .Done(remainder, result)
            }
        }
    }
}
//    return many1(parser) <|> { pure(Outs()) }
//public func many<Outs: RangeReplaceableCollectionType>(parser: Parser<Outs.Generator.Element>.Function) -> Parser<Outs>.Function {
//}
//
/// Parses one or more occurrences of `parser`.
public func many1<Outs: RangeReplaceableCollectionType>(parser: Parser<Outs.Generator.Element>.Function) -> Parser<Outs>.Function {
    return cons <^> parser <*> { many(parser) }
}

/// Parses one or more occurrences of `parser` until `end` succeeds,
/// and returns the list of values returned by `parser`.
public func manyTill<Out, Outs: RangeReplaceableCollectionType>(
    parser: Parser<Outs.Generator.Element>.Function,
    _ end: Parser<Out>.Function
    ) -> Parser<Outs>.Function
{
    return fix { recur in {
        (end *> { pure(Outs()) }) <|> { (cons <^> parser <*> { recur() }) }
    }}()
}

/// Parses zero or more occurrences of `parser`.
/// - Note: Returning parser never fails.
public func skipMany<Out>(parser: Parser<Out>.Function) -> Parser<()>.Function {
    return skipMany1(parser) <|> { pure(()) }
}

/// Parses one or more occurrences of `parser`.
public func skipMany1<Out>(parser: Parser<Out>.Function) -> Parser<()>.Function {
    return parser *> { skipMany(parser) }
}

/// Separates zero or more occurrences of `parser` using separator `separator`.
/// - Note: Returning parser never fails.
public func sepBy<Outs: RangeReplaceableCollectionType, Sep>(
    parser: Parser<Outs.Generator.Element>.Function,
    _ separator: Parser<Sep>.Function
    ) -> Parser<Outs>.Function
{
    return sepBy1(parser, separator) <|> { pure(Outs()) }
}

/// Separates one or more occurrences of `parser` using separator `separator`.
public func sepBy1<Outs: RangeReplaceableCollectionType, Sep>(
    parser: Parser<Outs.Generator.Element>.Function,
    _ separator: Parser<Sep>.Function
    ) -> Parser<Outs>.Function
{
    return cons <^> parser <*> { many(separator *> { parser }) }
}

/// Separates zero or more occurrences of `parser` using optionally-ended separator `separator`.
/// - Note: Returning parser never fails.
public func sepEndBy<Outs: RangeReplaceableCollectionType, Sep>(
    parser: Parser<Outs.Generator.Element>.Function,
    _ separator: Parser<Sep>.Function
    ) -> Parser<Outs>.Function
{
    return sepEndBy1(parser, separator) <|> { pure(Outs()) }
}

/// Separates one or more occurrences of `parser` using optionally-ended separator `separator`.
public func sepEndBy1<Outs: RangeReplaceableCollectionType, Sep>(
    parser: Parser<Outs.Generator.Element>.Function,
    _ separator: Parser<Sep>.Function
    ) -> Parser<Outs>.Function
{
    return parser >>- { x in
        ((separator *> { sepEndBy(parser, separator) }) >>- { xs in
            pure(Outs(x) + xs)
        }) <|> { pure(Outs(x)) }
    }
}

/// Parses `n` occurrences of `parser`.
public func count<Outs: RangeReplaceableCollectionType>(
    n: Int,
    _ parser: Parser<Outs.Generator.Element>.Function
    ) -> Parser<Outs>.Function
{
    guard n > 0 else { return pure(Outs()) }

    return cons <^> parser <*> { count(n-1, parser) }
}

///
/// Parses zero or more occurrences of `p`, separated by `op`
/// which left-associates multiple outputs from `p` by applying its binary operation.
///
/// If there are zero occurrences of `p`, default value `x` is returned.
///
/// - Note: Returning parser never fails.
///
public func chainl<Out>(
    p: Parser<Out>.Function,
    _ op: Parser<(Out, Out) -> Out>.Function,
    _ x: Out
    ) -> Parser<Out>.Function
{
    return chainl1(p, op) <|> { pure(x) }
}

///
/// Parses one or more occurrences of `p`, separated by `op`
/// which left-associates multiple outputs from `p` by applying its binary operation.
///
/// This parser can be used to eliminate left recursion which typically occurs in expression grammars.
///
/// For example (pseudocode):
///
/// ```
/// let expr = chainl1(term, symbol("-") *> pure(-))
/// ```
///
/// can be interpretted as:
///
/// ```
/// // [EBNF] expr = term { - term }
/// let expr = curry({ $1.reduce($0, combine: -) }) <^> term <*> many(symbol("-") *> term)
/// ```
///
/// but more efficient since `chainl1` doesn't use `many` to convert to
/// `RangeReplaceableCollectionType` first and then `reduce`.
///
public func chainl1<Out>(
    p: Parser<Out>.Function,
    _ op: Parser<(Out, Out) -> Out>.Function
    ) -> Parser<Out>.Function
{
    return p >>- { x in
        fix { recur in { x in
            (op >>- { f in
                p >>- { y in
                    recur(f(x, y))
                }
            }) <|> { pure(x)}
        }}(x)
    }
}

///
/// Parses zero or more occurrences of `p`, separated by `op`
/// which right-associates multiple outputs from `p` by applying its binary operation.
///
/// If there are zero occurrences of `p`, default value `x` is returned.
///
/// - Note: Returning parser never fails.
///
public func chainr<Out>(
    p: Parser<Out>.Function,
    _ op: Parser<(Out, Out) -> Out>.Function,
    _ x: Out
    ) -> Parser<Out>.Function
{
    return chainr1(p, op) <|> { pure(x) }
}

/// Parses one or more occurrences of `p`, separated by `op`
/// which right-associates multiple outputs from `p` by applying its binary operation.
public func chainr1<Out>(
    p: Parser<Out>.Function,
    _ op: Parser<(Out, Out) -> Out>.Function
    ) -> Parser<Out>.Function
{
    return fix { recur in {
        p >>- { x in
            (op >>- { f in
                recur() >>- { y in
                    pure(f(x, y))
                }
            }) <|> { pure(x) }
        }
    }}()
}

/// Applies `parser` without consuming any input.
public func lookAhead<Out>(parser: Parser<Out>.Function) -> Parser<Out>.Function
{
    return { input in
        let reply = parser(input)
        switch reply {
        case .Fail:
            return reply
        case let .Done(_, output):
            return .Done(input, output)
        }
    }
}
