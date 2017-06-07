/// Identity function.
internal func id<A>(_ a: A) -> A
{
    return a
}

/// Constant function.
internal func const<A, B>(_ a: A) -> (B) -> A
{
    return { _ in a }
}

/// Unary negation.
internal func negate<N: SignedNumeric>(_ x: N) -> N
{
    return -x
}

/// Haskell `(:)` (cons operator) for replacing slow `[x] + xs`.
internal func cons<C: RangeReplaceableCollection>(_ x: C.Iterator.Element) -> (C) -> C
{
    return { xs in
        var xs = xs
        xs.insert(x, at: xs.startIndex)
        return xs
    }
}

/// Extracts head and tail of `CollectionType`, returning nil if it is empty.
internal func uncons<C: Collection>(_ xs: C) -> (C.Iterator.Element, C.SubSequence)?
{
    if let head = xs.first {
        return (head, xs.suffix(from: xs.index(after: xs.startIndex)))
    }
    else {
        return nil
    }
}

/// `splitAt(count)(xs)` returns a tuple of `xs.prefixUpTo(count)` and `suffixFrom(count)`,
/// but either of those may be empty.
/// - Precondition: `count >= 0`
internal func splitAt<C: Collection>(_ count: C.IndexDistance) -> (C) -> (C.SubSequence, C.SubSequence)
{
    precondition(count >= 0, "`splitAt(count)` must have `count >= 0`.")

    return { xs in
        let midIndex = xs.index(xs.startIndex, offsetBy: count)
        if count <= xs.count {
            return (xs.prefix(upTo: midIndex), xs.suffix(from: midIndex))
        }
        else {
            return (xs.prefix(upTo: midIndex), xs.suffix(0))
        }
    }
}

internal func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C
{
    return { b in { a in f(a)(b) } }
}

internal func <<< <A, B, C>(f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C
{
    return { f(g($0)) }
}

internal func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C
{
    return { g(f($0)) }
}

/// Fixed-point combinator.
internal func fix<T, U>(_ f: @escaping (@escaping (T) -> U) -> (T) -> U) -> (T) -> U
{
    return { f(fix(f))($0) }
}
