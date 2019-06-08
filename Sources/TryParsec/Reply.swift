import Runes

/// Reply of `parse()`.
public enum Reply<In, Out>
{
    /// Failure with associated values `(remainingInput, contexts, message)`.
    case fail(In, [String], String)

    /// Success with associated values `(remainingInput, output)`.
    case done(In, Out)

    // TODO: Incremental input (requires Higher Kinded Types)
//    case Partial(In -> Reply<In, Out>)
}

extension Reply
{
    public var result: Result<Out, ParseError>
    {
        switch self {
            case let .fail(_, labels, message):
                if labels.count > 0 {
                    let labelString = labels.joined(separator: " > ")
                    return .failure(.message("[\(labelString)] Failed reading: \(message)"))
                }
                else {
                    return .failure(.message("Failed reading: \(message)"))
                }
            case let .done(_, output):
                return .success(output)
//            case .Partial(_):
//                return .failure(.Partial)
        }
    }
}

/// Haskell's `<$>` or `fmap`.
public func <^> <In, Out1, Out2>(f: (Out1) -> Out2, reply: Reply<In, Out1>) -> Reply<In, Out2>
{
    switch reply {
        case let .fail(input, labels, message):
            return .fail(input, labels, message)
        case let .done(input, output):
            return .done(input, f(output))
//        case let .Partial(g):
//            return .Partial({ f <^> g($0) })
    }
}
