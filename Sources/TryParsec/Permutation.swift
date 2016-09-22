import Runes

public struct Permutation<In, Out>
{
    fileprivate let output: Out?
    fileprivate let branches: [Branch<In, Out>]

    fileprivate func map<Out2>(_ f: @escaping (Out) -> Out2) -> Permutation<In, Out2>
    {
        return Permutation<In, Out2>(output: self.output.map(f), branches: self.branches.map { $0.map(f) })
    }
}

private struct Branch<In, Out>
{
    fileprivate let perm: Permutation<In, (Any) -> Out>
    fileprivate let parser: Parser<In, Any>

    fileprivate func map<Out2>(_ f: @escaping (Out) -> Out2) -> Branch<In, Out2>
    {
        return Branch<In, Out2>(perm: self.perm.map { f <<< $0 }, parser: self.parser)
    }
}

public func permute<In, Out>(_ perm: Permutation<In, Out>) -> Parser<In, Out>
{
    let empty: [Parser<In, Out>] = perm.output.map { [pure($0)] } ?? []

    let nonempty = perm.branches.map { b in
        b.parser >>- { x in
            permute(b.perm) >>- { f in
                pure(f(x))
            }
        }
    }

    return choice(nonempty + empty)
}

/// Creates new `Permutation` with `f`, and adds `parser`.
public func <^^> <In, Out, Out2>(f: @escaping (Out) -> Out2, parser: Parser<In, Out>) -> Permutation<In, Out2>
{
    return _new(f) <||> parser
}

/// Adds `parser` to `perm`.
public func <||> <In, Out, Out2>(perm: Permutation<In, (Out) -> Out2>, parser: Parser<In, Out>) -> Permutation<In, Out2>
{
    return _add(perm, parser)
}

/// Creates new `Permutation` with `f`,
/// and _optionally_ adds parser `tuple.1` with fallback value `tuple.0`.
public func <^?> <In, Out, Out2>(f: @escaping (Out) -> Out2, tuple: (Out, Parser<In, Out>)) -> Permutation<In, Out2>
{
    return _new(f) <|?> tuple
}

/// _Optionally_ adds parser `tuple.1` with fallback value `tuple.0`.
public func <|?> <In, Out, Out2>(perm: Permutation<In, (Out) -> Out2>, tuple: (Out, Parser<In, Out>)) -> Permutation<In, Out2>
{
    return _addOpt(perm, tuple.0, tuple.1)
}

// MARK: Private

/// Creates new `Permutation` with `output` only (no branches).
private func _new<In, Out>(_ output: Out) -> Permutation<In, Out>
{
    return Permutation(output: output, branches: [])
}

/// Adds `parser` to `perm`.
private func _add<In, Out, Out2>(_ perm: Permutation<In, (Out) -> Out2>, _ parser: Parser<In, Out>) -> Permutation<In, Out2>
{
    let b = Branch<In, Out2>(perm: perm.map(_toAny), parser: _toAny(parser))
    let bs = perm.branches.map {
        Branch<In, Out2>(perm: _add($0.perm.map(flip), parser), parser: $0.parser)
    }

    return Permutation<In, Out2>(output: nil, branches: cons(b)(bs))
}

/// Adds _optional_ `parser` to `perm`.
/// If `p` can not be applied, the fallback value `x` will be used instead.
private func _addOpt<In, Out, Out2>(_ perm: Permutation<In, (Out) -> Out2>, _ x: Out, _ parser: Parser<In, Out>) -> Permutation<In, Out2>
{
    let b = Branch<In, Out2>(perm: perm.map(_toAny), parser: _toAny(parser))    // workaround for existential type
    let bs = perm.branches.map {
        Branch<In, Out2>(perm: _addOpt($0.perm.map(flip), x, parser), parser: $0.parser)
    }

    return Permutation<In, Out2>(output: perm.output?(x), branches: cons(b)(bs))
}

/// Converts `parser`'s `Out` type to `Any`.
private func _toAny<In, Out>(_ parser: Parser<In, Out>) -> Parser<In, Any>
{
    return { $0 } <^> parser
}

/// Converts `A -> B` to `Any -> B`.
private func _toAny<A, B>(_ f: @escaping (A) -> B) -> (Any) -> B
{
    return { f($0 as! A) }  // swiftlint:disable:this force_cast
}
