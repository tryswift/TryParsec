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
public func many(parser: Parser<StringElement>.Function) -> Parser<StringContainer>.Function {
    return { input in
        var result = StringContainer()
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
//public func many(parser: Parser<StringElement>.Function) -> Parser<StringContainer>.Function {
//    return many1(parser) <|> { pure(StringContainer()) }
//}
//
/// Parses one or more occurrences of `parser`.
public func many1(parser: Parser<StringElement>.Function) -> Parser<StringContainer>.Function {
    return cons <^> parser <*> { many(parser) }
}

/// Parses one or more occurrences of `parser` until `end` succeeds,
/// and returns the list of values returned by `parser`.
public func manyTill<Out>(
    parser: Parser<StringElement>.Function,
    _ end: Parser<Out>.Function
    ) -> Parser<StringContainer>.Function
{
    return fix { recur in {
        (end *> { pure(StringContainer()) }) <|> { (cons <^> parser <*> { recur() }) }
        }}()
}

/// Separates zero or more occurrences of `parser` using separator `separator`.
/// - Note: Returning parser never fails.
public func sepBy(
    parser: Parser<StringElement>.Function,
    _ separator: Parser<StringElement>.Function
    ) -> Parser<StringContainer>.Function
{
    return sepBy1(parser, separator) <|> { pure(StringContainer()) }
}

/// Separates one or more occurrences of `parser` using separator `separator`.
public func sepBy1(
    parser: Parser<StringElement>.Function,
    _ separator: Parser<StringElement>.Function
    ) -> Parser<StringContainer>.Function
{
    return cons <^> parser <*> { many(separator *> { parser }) }
}

/// Parses `n` occurrences of `parser`.
public func count(
    n: Int,
    _ parser: Parser<StringElement>.Function
    ) -> Parser<StringContainer>.Function
{
    guard n > 0 else { return pure(StringContainer()) }

    return cons <^> parser <*> { count(n-1, parser) }
}
