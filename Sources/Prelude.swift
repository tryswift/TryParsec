/// Identity function.
internal func id<A>(a: A) -> A
{
    return a
}

/// Constant function.
internal func const<A, B>(a: A) -> B -> A
{
    return { _ in a }
}

/// Unary negation.
internal func negate<N: SignedNumberType>(x: N) -> N
{
    return -x
}

/// Haskell `(:)` (cons operator) for replacing slow `[x] + xs`.
internal func cons<C: RangeReplaceableCollectionType>(x: C.Generator.Element) -> C -> C
{
    return { xs in
        var xs = xs
        xs.insert(x, atIndex: xs.startIndex)
        return xs
    }
}

/// Extracts head and tail of `CollectionType`, returning nil if it is empty.
internal func uncons<C: CollectionType>(xs: C) -> (C.Generator.Element, C.SubSequence)?
{
    if let head = xs.first {
        return (head, xs.suffixFrom(xs.startIndex.successor()))
    }
    else {
        return nil
    }
}

/// `splitAt(count)(xs)` returns a tuple of `xs.prefixUpTo(count)` and `suffixFrom(count)`,
/// but either of those may be empty.
/// - Precondition: `count >= 0`
internal func splitAt<C: CollectionType>(count: C.Index.Distance) -> C -> (C.SubSequence, C.SubSequence)
{
    precondition(count >= 0, "`splitAt(count)` must have `count >= 0`.")

    return { xs in
        let midIndex = xs.startIndex.advancedBy(count)
        if count <= xs.count {
            return (xs.prefixUpTo(midIndex), xs.suffixFrom(midIndex))
        }
        else {
            return (xs.prefixUpTo(midIndex), xs.suffix(0))
        }
    }
}

/// Fixed-point combinator.
internal func fix<T, U>(f: (T -> U) -> T -> U) -> T -> U
{
    return { f(fix(f))($0) }
}
