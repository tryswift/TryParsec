/// Parses zero or one occurrence of `p`.
/// - SeeAlso: Haskell Parsec's `optionMaybe`.
public func zeroOrOne<In, Out>(p: Parser<In, Out>) -> Parser<In, Out?>
{
    return (p <&> { Optional($0) }) <|> pure(nil)
}

/// Parses zero or more occurrences of `p`.
/// - Note: Returning parser never fails.
public func many<In, Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(p: Parser<In, Out>) -> Parser<In, Outs>
{
    return many1(p) <|> pure(Outs())
}

/// Parses one or more occurrences of `p`.
public func many1<In, Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(p: Parser<In, Out>) -> Parser<In, Outs>
{
    return cons <^> p <*> many(p)
}

/// Parses one or more occurrences of `p` until `end` succeeds,
/// and returns the list of values returned by `p`.
public func manyTill<In, Out, Out2, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(
    p: Parser<In, Out>,
    _ end: Parser<In, Out2>
    ) -> Parser<In, Outs>
{
    return fix { recur in {
        (end *> pure(Outs())) <|> (cons <^> p <*> recur())
    }}()
}

/// Skips zero or more occurrences of `p`.
/// - Note: Returning parser never fails.
public func skipMany<In, Out>(p: Parser<In, Out>) -> Parser<In, ()>
{
    return skipMany1(p) <|> pure(())
}

/// Skips one or more occurrences of `p`.
public func skipMany1<In, Out>(p: Parser<In, Out>) -> Parser<In, ()>
{
    return p *> skipMany(p)
}

/// Separates zero or more occurrences of `p` using separator `sep`.
/// - Note: Returning parser never fails.
public func sepBy<In, Out, Outs: RangeReplaceableCollectionType, Sep where Outs.Generator.Element == Out>(
    p: Parser<In, Out>,
    _ separator: Parser<In, Sep>
    ) -> Parser<In, Outs>
{
    return sepBy1(p, separator) <|> pure(Outs())
}

/// Separates one or more occurrences of `p` using separator `sep`.
public func sepBy1<In, Out, Outs: RangeReplaceableCollectionType, Sep where Outs.Generator.Element == Out>(
    p: Parser<In, Out>,
    _ separator: Parser<In, Sep>
    ) -> Parser<In, Outs>
{
    return cons <^> p <*> many(separator *> p)
}

/// Separates zero or more occurrences of `p` using optionally-ended separator `sep`.
/// - Note: Returning parser never fails.
public func sepEndBy<In, Out, Outs: RangeReplaceableCollectionType, Sep where Outs.Generator.Element == Out>(
    p: Parser<In, Out>,
    _ separator: Parser<In, Sep>
    ) -> Parser<In, Outs>
{
    return sepEndBy1(p, separator) <|> pure(Outs())
}

/// Separates one or more occurrences of `p` using optionally-ended separator `sep`.
public func sepEndBy1<In, Out, Outs: RangeReplaceableCollectionType, Sep where Outs.Generator.Element == Out>(
    p: Parser<In, Out>,
    _ separator: Parser<In, Sep>
    ) -> Parser<In, Outs>
{
    return p >>- { x in
        ((separator *> sepEndBy(p, separator)) >>- { xs in
            pure(Outs(x) + xs)
        }) <|> pure(Outs(x))
    }
}

/// Parses `n` occurrences of `p`.
public func count<In, Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(
    n: Int,
    _ p: Parser<In, Out>
    ) -> Parser<In, Outs>
{
    guard n > 0 else { return pure(Outs()) }

    return cons <^> p <*> count(n-1, p)
}

///
/// Parses zero or more occurrences of `p`, separated by `op`
/// which left-associates multiple outputs from `p` by applying its binary operation.
///
/// If there are zero occurrences of `p`, default value `x` is returned.
///
/// - Note: Returning parser never fails.
///
public func chainl<In, Out>(
    p: Parser<In, Out>,
    _ op: Parser<In, (Out, Out) -> Out>,
    _ x: Out
    ) -> Parser<In, Out>
{
    return chainl1(p, op) <|> pure(x)
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
public func chainl1<In, Out>(
    p: Parser<In, Out>,
    _ op: Parser<In, (Out, Out) -> Out>
    ) -> Parser<In, Out>
{
    return p >>- { x in
        fix { recur in { x in
            (op >>- { f in
                p >>- { y in
                    recur(f(x, y))
                }
            }) <|> pure(x)
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
public func chainr<In, Out>(
    p: Parser<In, Out>,
    _ op: Parser<In, (Out, Out) -> Out>,
    _ x: Out
    ) -> Parser<In, Out>
{
    return chainr1(p, op) <|> pure(x)
}

/// Parses one or more occurrences of `p`, separated by `op`
/// which right-associates multiple outputs from `p` by applying its binary operation.
public func chainr1<In, Out>(
    p: Parser<In, Out>,
    _ op: Parser<In, (Out, Out) -> Out>
    ) -> Parser<In, Out>
{
    return fix { recur in {
        p >>- { x in
            (op >>- { f in
                recur() >>- { y in
                    pure(f(x, y))
                }
            }) <|> pure(x)
        }
    }}()
}

/// Applies `p` without consuming any input.
public func lookAhead<In, Out>(p: Parser<In, Out>) -> Parser<In, Out>
{
    return Parser { input in
        let reply = parse(p, input)
        switch reply {
            case .Fail:
                return reply
            case let .Done(_, output):
                return .Done(input, output)
        }
    }
}

/// Folds `parsers` using Alternative's `<|>`.
public func choice<In, Out, S: SequenceType where S.Generator.Element == Parser<In, Out>>(parsers: S) -> Parser<In, Out>
{
    return parsers.reduce(empty(), combine: { $0 <|> $1 })
}
