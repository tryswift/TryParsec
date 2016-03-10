public enum ParseError: ErrorType
{
    case Message(String)
//    case NotEnoughInput
}

extension ParseError: Equatable {}

public func == (lhs: ParseError, rhs: ParseError) -> Bool
{
    switch (lhs, rhs) {
        case let (.Message(msg1), .Message(msg2)):
            return msg1 == msg2
//        default:
//            return false
    }
}
