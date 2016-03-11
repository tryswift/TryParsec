import Result

public typealias StringContainer = String.UnicodeScalarView
public typealias StringElement = String.UnicodeScalarView.Generator.Element

extension StringContainer {
    /// Faster override
    func dropFirst() -> SubSequence {
        return suffixFrom(startIndex.successor())
    }
}

/// Runs a parser `p`.
/// - Returns: `Reply<In, Out>`
public func parse<Out>(parser: Parser<Out>.Function, _ input: StringContainer) -> Parser<Out> {
    return parser(input)
}

/// Runs a parser `p` that cannot be resupplied via a 'Partial' reply.
/// - Returns: `Parser<Out, ParseError>`
public func parseOnly<Out>(p: Parser<Out>.Function, _ input: StringContainer) -> Result<Out, ParseError> {
    return parse(p, input).result
}

/// MARK: Result
public enum Parser<Out> {
    /// The parse failed
    /// - Parameter In: the input that had not yet been consumed when failure occured
    /// - Parameter [String]: a list of contexts in which error occured
    /// - Parameter String: the message describing the error
    case Fail(StringContainer, [String], String)

    /// The parse succeeded
    /// - Parameter In: the input that had not yet been consumed
    case Done(StringContainer, Out)

    public typealias In = StringContainer
    public typealias Function = StringContainer -> Parser<Out>
}

extension Parser {
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

    public func map<Out2>(f: Out -> Out2) -> Parser<Out2> {
        switch self {
        case let .Fail(input, contexts, message):
            return .Fail(input, contexts, message)
        case let .Done(input, output):
            return .Done(input, f(output))
        }
    }
}

/// Haskell's `<$>` or `fmap`, Swift's `map`.
//public func <^> <Out1, Out2>(f: Out1 -> Out2, result: Parser<Out1>) -> Parser<Out2> {
//    return result.map(f)
//}

// MARK: Monad

public func fail<Out>(message: String) -> Parser<Out>.Function {
    return { .Fail($0, [], message) }
}

/// Haskell's `>>=` & Swift's `flatMap`.
public func >>- <Out1, Out2>(parser: Parser<Out1>.Function, f: Out1 -> Parser<Out2>.Function) -> Parser<Out2>.Function {
    return { input in
        switch parser(input) {
        case let .Fail(input2, contexts, message):
            return .Fail(input2, contexts, message)
        case let .Done(input2, output):
            return f(output)(input2)
        }
    }
}

// MARK: Alternative

/// The identity of `<|>`.
public func empty<Out>() -> Parser<Out>.Function {
    return fail("empty")
}

/// Alternation, choice.
/// Uses `q` only if `p` failed.
public func <|> <Out>(parser1: Parser<Out>.Function, parser2: () -> Parser<Out>.Function) -> Parser<Out>.Function {
    return { input in
        let result = parser1(input)
        switch result {
        case .Fail:
            return parser2()(input)
        case .Done:
            return result
        }
    }
}

// MARK: Applicative

/// Lifts `output` to `Parser`.
public func pure<Out>(output: Out) -> Parser<Out>.Function {
    return { .Done($0, output) }
}

/// Sequential application.
public func <*> <Out1, Out2>(parser1: Parser<Out1 -> Out2>.Function, parser2: () -> Parser<Out1>.Function) -> Parser<Out2>.Function {
    return { input in
        switch parser1(input) {
        case let .Fail(input2, contexts, message):
            return .Fail(input2, contexts, message)
        case let .Done(input2, f):
            switch parser2()(input2) {
            case let .Fail(input3, contexts, message):
                return .Fail(input3, contexts, message)
            case let .Done(input3, output3):
                return .Done(input3, f(output3))
            }
        }
    }
}

/// Sequence actions, discarding right (value of the second argument).
public func <* <Out1, Out2>(parser1: Parser<Out1>.Function, parser2: () -> Parser<Out2>.Function) -> Parser<Out1>.Function {
    return { input in
        switch parser1(input) {
        case let .Fail(input2, contexts, message):
            return .Fail(input2, contexts, message)
        case let .Done(input2, output2):
            switch parser2()(input2) {
            case let .Fail(input3, contexts, message):
                return .Fail(input3, contexts, message)
            case let .Done(input3, _):
                return .Done(input3, output2)
            }
        }
    }
}

/// Sequence actions, discarding left (value of the first argument).
public func *> <Out1, Out2>(parser1: Parser<Out1>.Function, parser2: () -> Parser<Out2>.Function) -> Parser<Out2>.Function {
    return { input in
        switch parser1(input) {
        case let .Fail(input2, contexts, message):
            return .Fail(input2, contexts, message)
        case let .Done(input2, _):
            return parser2()(input2)
        }
    }
}

// MARK: Functor

/// Haskell's `<$>` or `fmap`, Swift's `map`.
public func <^> <Out1, Out2>(f: Out1 -> Out2, parser: Parser<Out1>.Function) -> Parser<Out2>.Function {
    return { input in
        switch parser(input) {
        case let .Fail(input2, contexts, message):
            return .Fail(input2, contexts, message)
        case let .Done(input2, output):
            return .Done(input2, f(output))
        }
    }
}

/// Argument-flipped `<^>`, i.e. `flip(<^>)`.
public func <&> <Out1, Out2>(parser: Parser<Out1>.Function, f: Out1 -> Out2) -> Parser<Out2>.Function {
    return f <^> parser
}

// MARK: Label

/// Adds name to parser.
public func <?> <Out>(parser: Parser<Out>.Function, @autoclosure(escaping) label: () -> String) -> Parser<Out>.Function {
    return { input in
        let reply = parser(input)
        switch reply {
        case .Done:
            return reply
        case let .Fail(input2, labels, message2):
            return .Fail(input2, [label()] + labels, message2)
        }
    }
}

// MARK: Peek

/// Matches any first element to perform lookahead.
public func peek() -> Parser<StringElement>.Function {
    return { input in
        if let head = input.first {
            return .Done(input, head)
        } else {
            return .Fail(input, [], "peek")
        }
    }
}

/// Matches only if all input has been consumed.
public func endOfInput() -> Parser<()>.Function {
    return { input in
        if input.isEmpty {
            return .Done(input, ())
        } else {
            return .Fail(input, [], "endOfInput")
        }
    }
}
