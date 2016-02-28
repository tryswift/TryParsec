import Result

/// Reply of `parse()`.
public enum Reply<In, Out>
{
    /// Failure with associated values `(remainingInput, contexts, message)`.
    case Fail(In, [String], String)

    /// Success with associated values `(remainingInput, output)`.
    case Done(In, Out)

    // TODO: Incremental input (requires Higher Kinded Types)
//    case Partial(In -> Reply<In, Out>)
}

extension Reply
{
    public var result: Result<Out, ParseError>
    {
        switch self {
            case let .Fail(_, labels, message):
                if labels.count > 0 {
                    let labelString = labels.joinWithSeparator(" > ")
                    return .Failure(.Message("[\(labelString)] Failed reading: \(message)"))
                }
                else {
                    return .Failure(.Message("Failed reading: \(message)"))
                }
            case let .Done(_, output):
                return .Success(output)
//            case .Partial(_):
//                return .Failure(.Partial)
        }
    }
}

/// Haskell's `<$>` or `fmap`.
public func <^> <In, Out1, Out2>(f: Out1 -> Out2, reply: Reply<In, Out1>) -> Reply<In, Out2>
{
    switch reply {
        case let .Fail(input, labels, message):
            return .Fail(input, labels, message)
        case let .Done(input, output):
            return .Done(input, f(output))
//        case let .Partial(g):
//            return .Partial({ f <^> g($0) })
    }
}
