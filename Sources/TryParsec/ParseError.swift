public enum ParseError: Error
{
    case message(String)
//    case NotEnoughInput
}

extension ParseError: Equatable {}

public func == (lhs: ParseError, rhs: ParseError) -> Bool
{
    switch (lhs, rhs) {
        case let (.message(msg1), .message(msg2)):
            return msg1 == msg2
//        default:
//            return false
    }
}
