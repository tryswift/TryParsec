import TryParsecExperiment

extension Parser
{
    var _done: (input: In, output: Out)?
    {
        switch self {
            case let .Done(input, output):
                return (input, output)
            default:
                return nil
        }
    }

    var _fail: (input: In, contexts: [String], message: String)?
    {
        switch self {
            case let .Fail(input, contexts, message):
                return (input, contexts, message)
            default:
                return nil
        }
    }
}

typealias USV = String.UnicodeScalarView
