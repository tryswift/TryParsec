import Foundation

public typealias StringContainer = String.UnicodeScalarView
public typealias StringElement = String.UnicodeScalarView.Generator.Element

extension StringContainer {
    /// Faster override
    func dropFirst() -> SubSequence {
        return suffixFrom(startIndex.successor())
    }
}

extension StringContainer: StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self = value.unicodeScalars
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = value.unicodeScalars
    }

    public init(unicodeScalarLiteral value: String) {
        self = value.unicodeScalars
    }
}

/// Runs a parser `p`.
/// - Returns: `Reply<In, Out>`
public func parse<Out>(parser: Result<Out>.Parser, _ input: StringContainer) -> Result<Out> {
    return parser(input)
}

/// Runs a parser `p` that cannot be resupplied via a 'Partial' reply.
/// - Returns: `Result<Out, ParseError>`
public func parseOnly<Out>(p: Result<Out>.Parser, _ input: StringContainer) -> Out? {
    return parse(p, input).result
}

/// MARK: Result
public enum Result<Out> {
    /// The parse failed
    /// - Parameter In: the input that had not yet been consumed when failure occured
    /// - Parameter [String]: a list of contexts in which error occured
    /// - Parameter String: the message describing the error
    case Fail(In, [String], String)

    /// The parse succeeded
    /// - Parameter In: the input that had not yet been consumed
    case Done(In, Out)

    public typealias In = StringContainer
    public typealias Parser = In -> Result<Out>
}

extension Result {
    var result: Out? {
        guard case let .Done(_, output) = self else { return nil }
        return output
    }

    public func map<Out2>(f: Out -> Out2) -> Result<Out2> {
        switch self {
        case let .Fail(input, contexts, message):
            return .Fail(input, contexts, message)
        case let .Done(input, output):
            return .Done(input, f(output))
        }
    }
}

/// Haskell's `<$>` or `fmap`, Swift's `map`.
public func <^> <Out1, Out2>(f: Out1 -> Out2, result: Result<Out1>) -> Result<Out2> {
    return result.map(f)
}

// MARK: Monad

public func fail<Out>(message: String) -> Result<Out>.Parser {
    return { .Fail($0, [], message) }
}

/// Haskell's `>>=` & Swift's `flatMap`.
public func >>- <Out1, Out2>(parser: Result<Out1>.Parser, f: Out1 -> Result<Out2>.Parser) -> Result<Out2>.Parser {
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
public func empty<Out>() -> Result<Out>.Parser {
    return fail("empty")
}

/// Alternation, choice.
/// Uses `q` only if `p` failed.
public func <|> <Out>(parser1: Result<Out>.Parser, parser2: () -> Result<Out>.Parser) -> Result<Out>.Parser {
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
public func pure<Out>(output: Out) -> Result<Out>.Parser {
    return { .Done($0, output) }
}

/// Sequential application.
public func <*> <Out1, Out2>(parser1: Result<Out1 -> Out2>.Parser, parser2: () -> Result<Out1>.Parser) -> Result<Out2>.Parser {
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
public func <* <Out1, Out2>(parser1: Result<Out1>.Parser, parser2: () -> Result<Out2>.Parser) -> Result<Out1>.Parser {
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
public func *> <Out1, Out2>(parser1: Result<Out1>.Parser, parser2: () -> Result<Out2>.Parser) -> Result<Out2>.Parser {
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
public func <^> <Out1, Out2>(f: Out1 -> Out2, parser: Result<Out1>.Parser) -> Result<Out2>.Parser {
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
public func <&> <Out1, Out2>(parser: Result<Out1>.Parser, f: Out1 -> Out2) -> Result<Out2>.Parser {
    return f <^> parser
}

// MARK: Label

/// Adds name to parser.
public func <?> <Out>(parser: Result<Out>.Parser, label: () -> String) -> Result<Out>.Parser {
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
public func peek() -> Result<StringElement>.Parser {
    return { input in
        if let head = input.first {
            return .Done(input, head)
        } else {
            return .Fail(input, [], "peek")
        }
    }
}

/// Matches only if all input has been consumed.
public func endOfInput() -> Result<()>.Parser {
    return { input in
        if input.isEmpty {
            return .Done(input, ())
        } else {
            return .Fail(input, [], "endOfInput")
        }
    }
}
