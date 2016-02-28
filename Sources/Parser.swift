import Result

/// Monadic parser type.
public struct Parser<In, Out>
{
    // Comment-Out: Stack overflows. Tail-recursion optimization seems not working.
//    public typealias Failure = (In, [String], String) -> Reply<In, Any>
//    public typealias Success = (In, Out) -> Reply<In, Any>
//
//    internal let _parse: (In, Failure, Success) -> Reply<In, Any>

    private let _parse: In -> Reply<In, Out>

    public init(_ parse: In -> Reply<In, Out>)
    {
        self._parse = parse
    }
}

/// Runs a parser `p`.
/// - Returns: `Reply<In, Out>`
public func parse<In, Out>(p: Parser<In, Out>, _ input: In) -> Reply<In, Out>
{
    return p._parse(input)
}

/// Runs a parser `p` that cannot be resupplied via a 'Partial' reply.
/// - Returns: `Result<Out, ParseError>`
public func parseOnly<In, Out>(p: Parser<In, Out>, _ input: In) -> Result<Out, ParseError>
{
    return parse(p, input).result
}

// TODO: Incremental input (requires Higher Kinded Types)
//public func feed<In: RangeReplaceableCollectionType, Out>(reply: Reply<In, Out>, _ input: In) -> Reply<In, Out>
//{
//}

// MARK: Monad

public func fail<In, Out>(message: String) -> Parser<In, Out>
{
    return Parser { .Fail($0, [], message) }
}

/// Haskell's `>>=` & Swift's `flatMap`.
public func >>- <In, Out1, Out2>(p: Parser<In, Out1>, f: (Out1 -> Parser<In, Out2>)) -> Parser<In, Out2>
{
    return Parser { input in
        switch parse(p, input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, output):
                return parse(f(output), input2)
        }
    }
}

// MARK: Alternative

/// The identity of `<|>`.
public func empty<In, Out>() -> Parser<In, Out>
{
    return fail("empty")
}

/// Alternation, choice.
/// Uses `q` only if `p` failed.
public func <|> <In, Out>(p: Parser<In, Out>, @autoclosure(escaping) q: () -> Parser<In, Out>) -> Parser<In, Out>
{
    return Parser { input in
        let reply = parse(p, input)
        switch reply {
            case .Fail:
                return parse(q(), input)
            case .Done:
                return reply
        }
    }
}

// MARK: Applicative

/// Lifts `output` to `Parser`.
public func pure<In, Out>(output: Out) -> Parser<In, Out>
{
    return Parser { .Done($0, output) }
}

/// Sequential application.
public func <*> <In, Out1, Out2>(p: Parser<In, Out1 -> Out2>, @autoclosure(escaping) q: () -> Parser<In, Out1>) -> Parser<In, Out2>
{
    // Comment-Out: slower
//    return p >>- { f in f <^> q() }

    return Parser { input in
        switch parse(p, input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, f):
                switch parse(q(), input2) {
                    case let .Fail(input3, labels, message):
                        return .Fail(input3, labels, message)
                    case let .Done(input3, output3):
                        return .Done(input3, f(output3))
                }
        }
    }
}

/// Sequence actions, discarding right (value of the second argument).
public func <* <In, Out1, Out2>(p: Parser<In, Out1>, @autoclosure(escaping) q: () -> Parser<In, Out2>) -> Parser<In, Out1>
{
    // Comment-Out: slower
//    return const <^> p <*> q

    return Parser { input in
        switch parse(p, input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, output2):
                switch parse(q(), input2) {
                    case let .Fail(input3, labels, message):
                        return .Fail(input3, labels, message)
                    case let .Done(input3, _):
                        return .Done(input3, output2)
                }
        }
    }
}

/// Sequence actions, discarding left (value of the first argument).
public func *> <In, Out1, Out2>(p: Parser<In, Out1>, @autoclosure(escaping) q: () -> Parser<In, Out2>) -> Parser<In, Out2>
{
    // Comment-Out: slower
//    return const(id) <^> p <*> q

    return Parser { input in
        switch parse(p, input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, _):
                switch parse(q(), input2) {
                    case let .Fail(input3, labels, message):
                        return .Fail(input3, labels, message)
                    case let .Done(input3, output3):
                        return .Done(input3, output3)
                }
        }
    }
}

// MARK: Functor

/// Haskell's `<$>` or `fmap`, Swift's `map`.
public func <^> <In, Out1, Out2>(f: Out1 -> Out2, p: Parser<In, Out1>) -> Parser<In, Out2>
{
    // Comment-Out: slower
//    return p >>- { a in pure(f(a)) }

    return Parser { input in
        switch parse(p, input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, output):
                return .Done(input2, f(output))
        }
    }
}

/// Argument-flipped `<^>`, i.e. `flip(<^>)`.
public func <&> <In, Out1, Out2>(p: Parser<In, Out1>, f: Out1 -> Out2) -> Parser<In, Out2>
{
    return f <^> p
}

// MARK: Label

/// Adds name to parser.
public func <?> <In, Out>(p: Parser<In, Out>, @autoclosure(escaping) label: () -> String) -> Parser<In, Out>
{
    return Parser { input in
        let reply = parse(p, input)
        switch reply {
            case .Done:
                return reply
            case let .Fail(input2, labels, message2):
                return .Fail(input2, cons(label())(labels), message2)
        }
    }
}

// MARK: Peek

/// Matches any first element to perform lookahead.
public func peek<In: CollectionType, Out where In.Generator.Element == Out>() -> Parser<In, Out>
{
    return Parser { input in
        if let head = input.first {
            return .Done(input, head)
        }
        else {
            return .Fail(input, [], "peek")
        }
    }
}

/// Matches only if all input has been consumed.
public func endOfInput<In: CollectionType>() -> Parser<In, ()>
{
    return Parser { input in
        if input.isEmpty {
            return .Done(input, ())
        }
        else {
            return .Fail(input, [], "endOfInput")
        }
    }
}
