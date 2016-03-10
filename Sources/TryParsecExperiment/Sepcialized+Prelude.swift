///// Haskell `(:)` (cons operator) for replacing slow `[x] + xs`.
//internal func cons(x: StringElement) -> StringContainer -> StringContainer {
//    return { xs in
//        var xs = xs
//        xs.insert(x, atIndex: xs.startIndex)
//        return xs
//    }
//}
//
///// Extracts head and tail of `CollectionType`, returning nil if it is empty.
//internal func uncons(xs: StringContainer) -> (StringElement, StringContainer)? {
//    if let head = xs.first {
//        return (head, xs.dropFirst())
//    } else {
//        return nil
//    }
//}
//
internal func cons(x: StringElement) -> StringContainer -> StringContainer
{
    return { xs in
        var x = StringContainer(x)
        x.appendContentsOf(xs)
        return x
    }
}

/// Parses zero or more occurrences of `parser`.
/// - Note: Returning parser never fails.
public func many(parser: Result<StringElement>.Parser) -> Result<StringContainer>.Parser {
    return many1(parser) <|> { pure(StringContainer()) }
}

/// Parses one or more occurrences of `parser`.
public func many1(parser: Result<StringElement>.Parser) -> Result<StringContainer>.Parser {
    return cons <^> parser <*> { many(parser) }
}

/// Parses one or more occurrences of `parser` until `end` succeeds,
/// and returns the list of values returned by `parser`.
public func manyTill<Out>(
    parser: Result<StringElement>.Parser,
    _ end: Result<Out>.Parser
    ) -> Result<StringContainer>.Parser
{
    return fix { recur in {
        (end *> { pure(StringContainer()) }) <|> { (cons <^> parser <*> { recur() }) }
        }}()
}

/// Separates zero or more occurrences of `parser` using separator `separator`.
/// - Note: Returning parser never fails.
public func sepBy(
    parser: Result<StringElement>.Parser,
    _ separator: Result<StringElement>.Parser
    ) -> Result<StringContainer>.Parser
{
    return sepBy1(parser, separator) <|> { pure(StringContainer()) }
}

/// Separates one or more occurrences of `parser` using separator `separator`.
public func sepBy1(
    parser: Result<StringElement>.Parser,
    _ separator: Result<StringElement>.Parser
    ) -> Result<StringContainer>.Parser
{
    return cons <^> parser <*> { many(separator *> { parser }) }
}

/// Parses `n` occurrences of `parser`.
public func count(
    n: Int,
    _ parser: Result<StringElement>.Parser
    ) -> Result<StringContainer>.Parser
{
    guard n > 0 else { return pure(StringContainer()) }

    return cons <^> parser <*> { count(n-1, parser) }
}
